	//
	//  FCL.swift
	//

import AuthenticationServices
import BigInt
import Combine
import Flow
import Starscream
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

import WalletConnectKMS
import WalletConnectNetworking
import WalletConnectPairing
import WalletConnectRelay
import WalletConnectSign

@MainActor
public let fcl = FCL.shared

@MainActor
public final class FCL: NSObject, ObservableObject {

	public static let shared = FCL()

	public var delegate: FCLDelegate?

	public var config = Config()

	private var providers: [FCL.Provider] = [.flowWallet, .blocto]

	public let version = "@outblock/fcl-swift@0.0.9"

	@Published
	public var currentUser: User?

	lazy var defaultAddressRegistry = AddressRegistry()

	@Published
	public var currentEnv: Flow.ChainID = .mainnet

	@Published
	public var currentProvider: FCL.Provider?

	internal var httpProvider = FCL.HTTPProvider()
	internal var wcProvider: FCL.WalletConnectProvider?
	internal var preAuthz: FCL.Response?
	internal var keychain = KeychainStorage(serviceIdentifier: "@outblock/fcl-swift")
	internal var perferenceStorage = UserDefaults.standard

		// MARK: - Init / Back Channel

	override public init() {
		super.init()

		if let providerId = perferenceStorage.string(forKey: FCL.PreferenceKey.provider.rawValue),
		   let provider = FCL.Provider(id: providerId),
		   provider.supportAutoConnect {
			currentProvider = provider

			if let data = try? keychain.readData(key: .StorageKey.currentUser.rawValue),
			   let user = try? JSONDecoder().decode(FCL.User.self, from: data) {
				currentUser = user
			}

			if let envName = perferenceStorage.string(forKey: FCL.PreferenceKey.env.rawValue) {
				let env = Flow.ChainID(name: envName)
				try? changeProvider(provider: provider, env: env)
			}
		}
	}

		// MARK: - Config

	public func config(
		metadata: FCL.Metadata,
		env: Flow.ChainID,
		provider: FCL.Provider
	) {
		let walletProvider = provider.provider(chainId: env)

		_ = config
			.put(.title, value: metadata.appName)
			.put(.description, value: metadata.appDescription)
			.put(.icon, value: metadata.appIcon.absoluteString)
			.put(.location, value: metadata.location.absoluteString)
			.put(.authn, value: walletProvider.endpoint(chainId: env))
			.put(.env, value: env.name)
			.put(.providerMethod, value: walletProvider.method.rawValue)

		if let accountProof = metadata.accountProof {
			_ = config
				.put(.nonce, value: accountProof.nonce)
				.put(.appId, value: accountProof.appIdentifier)
		}

		if let walletConnect = metadata.walletConnectConfig {
			_ = config
				.put(.projectID, value: walletConnect.projectID)
				.put(.urlSheme, value: walletConnect.urlScheme)
			setupWalletConnect()
		}

		currentProvider = provider
		currentEnv = env

		if metadata.autoConnect {
			perferenceStorage.removeObject(forKey: FCL.PreferenceKey.provider.rawValue)
			perferenceStorage.removeObject(forKey: FCL.PreferenceKey.env.rawValue)
		} else if provider.supportAutoConnect {
			perferenceStorage.set(provider.id, forKey: FCL.PreferenceKey.provider.rawValue)
			perferenceStorage.set(env.name, forKey: FCL.PreferenceKey.env.rawValue)
		}
	}

		// MARK: - WalletConnect setup

	private func setupWalletConnect() {
		guard let name = config.get(.title),
			  let description = config.get(.description),
			  let icon = config.get(.icon),
			  let projectID = config.get(.projectID),
			  let urlScheme = config.get(.urlSheme)
		else {
			return
		}

		let appMetadata = AppMetadata(
			name: name,
			description: description,
			url: urlScheme,
			icons: [icon]
		)

		Pair.configure(metadata: appMetadata)
		Networking.configure(projectId: projectID, socketFactory: SocketFactory())
		wcProvider = FCL.WalletConnectProvider()
	}

		// MARK: - Provider switching

	public func changeProvider(
		provider: FCL.Provider,
		env: Flow.ChainID
	) throws {
		if !provider.supportNetwork.contains(env) {
			throw FCLError.unsupportNetwork
		}

		let walletProvider = provider.provider(chainId: env)

		config
			.put(.authn, value: walletProvider.endpoint(chainId: env))
			.put(.providerMethod, value: walletProvider.method.rawValue)
			.put(.env, value: env.name)

		currentProvider = provider
		currentEnv = env

		if provider.supportAutoConnect {
			perferenceStorage.set(provider.id, forKey: FCL.PreferenceKey.provider.rawValue)
			perferenceStorage.set(env.name, forKey: FCL.PreferenceKey.env.rawValue)
		}
	}

		// MARK: - Discovery (UIKit)

#if canImport(UIKit)
	public func openDiscovery() {
		let discoveryVC = UIHostingController(rootView: DiscoveryView())
		discoveryVC.view.backgroundColor = .clear
		discoveryVC.modalPresentationStyle = .overFullScreen
		UIApplication.shared.topMostViewController?
			.present(discoveryVC, animated: true)
	}

	public func closeDiscoveryIfNeed(completion: (() -> Void)? = nil) {
		guard let vc = UIApplication.shared.topMostViewController as? UIHostingController<DiscoveryView> else {
			return
		}
		vc.dismiss(animated: true, completion: completion)
	}
#endif

		// MARK: - Util

	public func generateNonce() -> String {
		let letters = "0123456789abcdef"
		return String((0 ..< 64).map { _ in letters.randomElement()! })
	}

	internal func getStategy() throws -> any FCLStrategy {
		guard let methodString = config.get(.providerMethod),
			  let method = FCL.ServiceMethod(rawValue: methodString)
		else {
			throw FCLError.invalidWalletProvider
		}

		switch method {
			case .httpPost, .httpGet:
				return httpProvider
			case .walletConnect:
				return wcProvider ?? FCL.WalletConnectProvider()
		}
	}

	internal func serviceOfType(
		services: [FCL.Service]?,
		type: FCL.ServiceType
	) -> FCL.Service? {
		services?.first(where: { $0.type == type })
	}
}

// MARK: - Nested enums / helpers

public extension FCL {

	enum PreferenceKey: String {
		case provider
		case env
	}

	struct WalletProvider: Equatable {
		let id: String
		let name: String
		let endpointFormat: String
		let method: ServiceMethod
		let supportAutoConnect: Bool
		let supportNetwork: [Flow.ChainID]

		func endpoint(chainId: Flow.ChainID) -> String {
			endpointFormat.replacingOccurrences(of: "{chainId}", with: chainId.name)
		}
	}

	enum Provider: CaseIterable {
		case flowWallet
		case blocto

		public init?(id: String) {
			switch id {
				case "dapper", "flow-wallet":
					self = .flowWallet
				case "blocto":
					self = .blocto
				default:
					return nil
			}
		}

		@MainActor
		public var supportAutoConnect: Bool {
			provider(chainId: .mainnet).supportAutoConnect
		}

		@MainActor
		public var supportNetwork: [Flow.ChainID] {
			provider(chainId: .mainnet).supportNetwork
		}

		@MainActor
		public var id: String {
			provider(chainId: .mainnet).id
		}

		@MainActor
		public var name: String {
			provider(chainId: .mainnet).name
		}

		@MainActor
		public func provider(
			chainId: Flow.ChainID = fcl.currentEnv
		) -> FCL.WalletProvider {
			switch self {
				case .blocto:
					return FCL.WalletProvider(
						id: "blocto",
						name: "Blocto",
						endpointFormat: "https://wallet-v2.blocto.app/{chainId}",
						method: .httpPost,
						supportAutoConnect: true,
						supportNetwork: [.mainnet, .testnet]
					)
				case .flowWallet:
					return FCL.WalletProvider(
						id: "dapper",
						name: "Flow Wallet",
						endpointFormat: "https://flow-wallet.blocto.app/{chainId}",
						method: .httpPost,
						supportAutoConnect: true,
						supportNetwork: [.mainnet, .testnet]
					)
			}
		}
	}
}
