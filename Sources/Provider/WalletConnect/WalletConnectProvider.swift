	//
	//  WalletConnectProvider.swift
	//

import Combine
@preconcurrency import Flow
import Foundation
import Starscream

#if canImport(UIKit)
import UIKit
#endif

@preconcurrency import WalletConnectKMS
import WalletConnectPairing
@preconcurrency import WalletConnectSign
@preconcurrency import WalletConnectPairing
@preconcurrency import WalletConnectUtils
import WalletConnectUtils
import Gzip

	// MARK: - WebSocket wrapper

final class WCWebSocket: WebSocketConnecting {
	private let underlying: WebSocket

	init(url: URL) {
		self.underlying = WebSocket(url: url)
	}

	var isConnected: Bool { underlying.isConnected }

	var onConnect: (() -> Void)?
	var onDisconnect: ((Error?) -> Void)?
	var onText: ((String) -> Void)?

	var request: URLRequest {
		get { underlying.request }
		set { underlying.request = newValue }
	}

	var delegate: WebSocketDelegate? {
		get { underlying.delegate }
		set { underlying.delegate = newValue }
	}

	func connect() {
		underlying.connect()
	}

	func disconnect() {
		underlying.disconnect(forceTimeout: nil, closeCode: CloseCode.normal.rawValue)
	}

	func disconnect(closeCode: UInt16) {
		underlying.disconnect(forceTimeout: nil, closeCode: closeCode)
	}

	func write(string: String, completion: (() -> Void)? = nil) {
		underlying.write(string: string, completion: completion)
	}

	func write( data: Data, completion: (() -> Void)? = nil) {
		underlying.write(data: data, completion: completion)
	}
}

internal final class SocketFactory: WebSocketFactory {
	var socket: WebSocketConnecting?

	func create(with url: URL) -> WebSocketConnecting {
		let socket = WCWebSocket(url: url)
		self.socket = socket
		return socket
	}
}

	// MARK: - WalletConnect provider

public extension FCL {

	enum WCMethod: String, CaseIterable {
		case authn = "flow_authn"
		case authz = "flow_authz"
		case preAuthz = "flow_pre_authz"
		case userSignature = "flow_user_sign"
		case unknow

		public init(service: ServiceType) {
			switch service {
				case .authn:
					self = .authn
				case .authz:
					self = .authz
				case .userSignature:
					self = .userSignature
				case .preAuthz:
					self = .preAuthz
				default:
					self = .unknow
			}
		}
	}

	enum WCFlowBlockchain: String, CaseIterable {
		case mainnet
		case testnet

		var blockchain: Blockchain? {
			switch self {
				case .mainnet:
					return Blockchain("flow:mainnet")
				case .testnet:
					return Blockchain("flow:testnet")
			}
		}
	}
	@MainActor
	final class WalletConnectProvider: FCLStrategy {

		nonisolated func execService(
			service _: FCL.Service,
			request _: (any Encodable & Sendable)?
		) async throws -> FCL.Response {
			throw FCLError.invaildService  // or route to execService(url:...)
		}

		func execService(
			url _: URL,
			method: FCL.ServiceType,
			request: (any Encodable & Sendable)?
		) async throws -> FCL.Response {
			return try await Task { @MainActor in
				guard let env = fcl.config.get(.env),
					  let network = WCFlowBlockchain.allCases.first(where: { $0.rawValue == env }),
					  let blockchain = network.blockchain
				else {
					throw FCLError.invaildNetwork
				}

				if method == .authn {
					return try await execAuthn(blockchain: blockchain)
				} else {
					return try await execAuthorized(
						blockchain: blockchain,
						method: method,
						request: request
					)
				}
			}.value
		}

		var sessions: [Session] = []
		var pairings: [Pairing] = []
		var currentProposal: Session.Proposal?
		var currentSession: Session?
		private var publishers = Set<AnyCancellable>()

		private let signClient: SignClient
		private let pairingClient: any PairingInteracting

		public init() {
			self.signClient = Sign.instance
			self.pairingClient = Pair.instance

			setUpWCSubscribing()
			reloadSession()
			reloadPair()
		}

			// MARK: - FCLStrategy

		

			//		func execService(
			//			url _: URL,
			//			method: FCL.ServiceType,
			//			request: AnyEncodable?
			//		) async throws -> FCL.Response {
			//			guard let env = fcl.config.get(.env),
			//				  let network = WCFlowBlockchain.allCases.first(where: { $0.rawValue == env }),
			//				  let blockchain = network.blockchain
			//			else {
			//				throw FCLError.invaildNetwork
			//			}
			//
			//			if method == .authn {
			//				return try await execAuthn(blockchain: blockchain)
			//			} else {
			//				return try await execAuthorized(
			//					blockchain: blockchain,
			//					method: method,
			//					request: request
			//				)
			//			}
			//		}

			// MARK: - Authn flow

		private func execAuthn(
			blockchain: Blockchain
		) async throws -> FCL.Response {
			do {
				currentProposal = nil
				try await connectToWallet()

				let response = try await signClient.sessionSettlePublisher.async()
				currentSession = response

				if let topicData = response.topic.data(using: .utf8) {
					try? fcl.keychain.add(data: topicData,
										  forKey: .StorageKey.wcSession.rawValue
					)
				}

				let baseConfig = BaseConfigRequest()
				guard let cfgData = try? JSONEncoder().encode(baseConfig),
					  let dataString = String( data: cfgData, encoding: .utf8)
				else {
					throw FCLError.encodeFailure
				}

				let authnRequest = WalletConnectSign.Request(
					topic: response.topic,
					method: WCMethod.authn.rawValue,
					params: AnyCodable(any: [dataString]),
					chainId: blockchain
				)

				try await signClient.request(params: authnRequest)
				let authnResponse = try await signClient.sessionResponsePublisher.async()

				let decoder = JSONDecoder()
				decoder.keyDecodingStrategy = .convertFromSnakeCase

				guard case let .response(value) = authnResponse.result,
					  let json = try? value.asJSONEncodedString(),
					  let responseData = json.data(using: .utf8),
					  let model = try? decoder.decode(FCL.Response.self, from: responseData)
				else {
					throw FCLError.decodeFailure
				}

				return model
			} catch {
				try? fcl.keychain.deleteAll()
				await disconnectAll()
				print("authn error ===> \(error)")
				throw error
			}
		}

			// MARK: - Authorized flow

		private func execAuthorized(
			blockchain: Blockchain,
			method: FCL.ServiceType,
			request: (any Encodable & Sendable)?
		) async throws -> FCL.Response {
			guard let stored = try? fcl.keychain.readData(key: .StorageKey.wcSession.rawValue),
				  let sessionTopic = String(data: stored, encoding: .utf8)
			else {
				throw FCLError.unauthenticated
			}

			guard let request = request,
				  let encoded = try? JSONEncoder().encode(request),
				  let compressed = try? encoded.gzipped(level: .bestCompression)
			else {
				throw FCLError.encodeFailure
			}

			let dataString = compressed.base64EncodedString()

			let wcRequest = WalletConnectSign.Request(
				topic: sessionTopic,
				method: WCMethod(service: method).rawValue,
				params: AnyCodable(any: [dataString]),
				chainId: blockchain
			)

			try await signClient.request(params: wcRequest)
			try connectWithExampleWallet()

			let authzResponse = try await signClient.sessionResponsePublisher.async()

			guard case let .response(value) = authzResponse.result else {
				throw FCLError.invaildAuthzReponse
			}

			let json = try value.asJSONEncodedString()
			let responseData = json.data(using: .utf8)!
			let model = try JSONDecoder().decode(FCL.Response.self, from: responseData)
			return model
		}

			// MARK: - Sessions & Pairings

		private func reloadSessionAndPair() {
			pairings = pairingClient.getPairings()
			sessions = signClient.getSessions()
		}

		private func reloadSession() {
			pairings = pairingClient.getPairings()
		}

		private func reloadPair() {
			sessions = signClient.getSessions()
		}

		public func disconnect(topic: String? = nil) async throws {
			if let topic {
				try await pairingClient.disconnect(topic: topic)
			} else if let currentSession {
				try await pairingClient.disconnect(topic: currentSession.topic)
			}
		}

		public func disconnectAll() async {
			await withTaskGroup(of: Void.self) { group in
				signClient.getSessions().forEach { session in
					group.addTask { [pairingClient] in
						try? await pairingClient.disconnect(topic: session.topic)
					}
				}

				pairingClient.getPairings().forEach { pair in
					group.addTask { [pairingClient] in
						try? await pairingClient.disconnect(topic: pair.topic)
					}
				}
			}
		}

			// MARK: - Connect

		private func connectToWallet() async throws {
			reloadSessionAndPair()
			let methods: Set<String> = Set(WCMethod.allCases.map { $0.rawValue })

			guard let env = fcl.config.get(.env),
				  let network = WCFlowBlockchain.allCases.first(where: { $0.rawValue == env }),
				  let blockchain = network.blockchain
			else {
				throw FCLError.invaildNetwork
			}

			guard let endpoint = fcl.config.get(.authn) else {
				throw Flow.FError.urlEmpty
			}

			var topic: String?
			if let existingPairing = pairings.first(where: { $0.peer?.url == endpoint }) {
				topic = existingPairing.topic
			} else if let stored = try? fcl.keychain.readData(key: .StorageKey.wcSession.rawValue),
					  let sessionTopic = String(data: stored, encoding: .utf8) {
				topic = sessionTopic
			}

			let chains: Set<Blockchain> = [blockchain]
			let namespaces: [String: ProposalNamespace] = [
				blockchain.namespace: ProposalNamespace(
					chains: chains,
					methods: methods,
					events: Set()
				)
			]

			if let topic {
				try await signClient.connect(requiredNamespaces: namespaces, topic: topic)
				try connectWithExampleWallet(uri: nil)
			} else {
				let uri = try await pairingClient.create()
				try await signClient.connect(requiredNamespaces: namespaces, topic: uri.topic)
				try connectWithExampleWallet(uri: uri)
			}
		}

			// MARK: - Open wallet

#if canImport(UIKit)
		private func connectWithExampleWallet(uri: WalletConnectURI? = nil) throws {
			guard let endpoint = fcl.config.get(.authn) else {
				throw Flow.FError.urlEmpty
			}

			var url = URL(string: endpoint)
			if let encodedURI = uri?.absoluteString
				.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
				url = URL(string: "\(endpoint)/wc?uri=\(encodedURI)")
			}

			if let url {
				UIApplication.shared.open(url, options: [:])
			}
		}
#else
		private func connectWithExampleWallet(uri _: WalletConnectURI? = nil) throws {
			guard fcl.config.get(.authn) != nil else {
				throw Flow.FError.urlEmpty
			}
		}
#endif

			// MARK: - Subscriptions

		private func setUpWCSubscribing() {
			signClient.socketConnectionStatusPublisher
				.receive(on: DispatchQueue.main)
				.sink { status in
					if status == .connected {
						print("Client connected")
					}
				}
				.store(in: &publishers)

			signClient.sessionResponsePublisher
				.receive(on: DispatchQueue.main)
				.sink { response in
					print("Session Response ===> \(response)")
				}
				.store(in: &publishers)

			signClient.sessionProposalPublisher
				.receive(on: DispatchQueue.main)
				.sink { [weak self] payload in
					print("[RESPONDER] WC: Did receive session proposal")
					self?.currentProposal = payload.proposal
					self?.reloadSessionAndPair()
				}
				.store(in: &publishers)

			signClient.sessionSettlePublisher
				.receive(on: DispatchQueue.main)
				.sink { [weak self] session in
					print("Session Settle ===> \(session)")
					self?.reloadSessionAndPair()
				}
				.store(in: &publishers)

			signClient.sessionRequestPublisher
				.receive(on: DispatchQueue.main)
				.sink { _ in
					print("[RESPONDER] WC: Did receive session request")
				}
				.store(in: &publishers)

			signClient.sessionDeletePublisher
				.receive(on: DispatchQueue.main)
				.sink { [weak self] _ in
					self?.reloadSessionAndPair()
				}
				.store(in: &publishers)
		}
	}
}
