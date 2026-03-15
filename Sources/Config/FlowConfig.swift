	//
	//  Config.swift
	//
	//  Created by Nicholas Reich on 03-15-2026.
	//

import Flow
import Foundation

public extension FCL {

		/// Actor-isolated configuration store; safe under Swift 6 strict concurrency.
	@MainActor
	final class Config: @unchecked Sendable {

		private var dict = [String: String]()

		public enum Key: String, CaseIterable {
			case accessNode = "accessNode.api"
			case icon = "app.detail.icon"
			case title = "app.detail.title"
			case description = "app.detail.description"
			case env
			case location
			case autoConnect
			case domainTag = "fcl.appDomainTag"
			case authn

				// Wallet Provider
			case providerMethod

				// Account Proof
			case appId = "appIdentifier"
			case nonce = "accountProofNonce"

				// Wallet Connect
			case projectID
			case urlSheme
		}

		public init() {}

			// MARK: - Lens

		public func configLens(_ regex: String) -> [String: String] {
			let matches = dict.filter { item in
				item.key.range(of: regex, options: .regularExpression) != nil
			}

			let newDict = Dictionary(
				uniqueKeysWithValues: matches.map { key, value in
					(
						key.replacingOccurrences(
							of: regex,
							with: "",
							options: [.regularExpression]
						),
						value
					)
				}
			)

			return newDict
		}

			// MARK: - Keyed access (enum Key)

		public func get(_ key: Key) -> String? {
			dict[key.rawValue]
		}

		@discardableResult
		public func put(_ key: Key, value: String?) -> Self {
			guard let value else { return self }
			return put(key.rawValue, value: value)
		}

		@discardableResult
		public func remove(key: Key) -> Config {
			dict.removeValue(forKey: key.rawValue)
			return self
		}

			// MARK: - String-keyed access

		public func get(_ key: String) -> String? {
			dict[key]
		}

		@discardableResult
		public func put(_ key: String, value: String) -> Self {
			dict[key] = value

				// If env changed, update Flow chainID for accessAPI.
			if key == "env", let chainID = envToChainID(env: value) {
				flow.configure(chainID: chainID)
			}

			return self
		}

		@discardableResult
		public func remove(_ key: String) -> Config {
			dict.removeValue(forKey: key)
			return self
		}

		@discardableResult
		public func clear() -> Config {
			dict.removeAll()
			return self
		}
	}
}

@MainActor
extension FCL.Config {
	private func envToChainID(env: String) -> Flow.ChainID? {
		switch env.lowercased() {
				case "testnet":
				return .testnet
				case "mainnet":
				return .mainnet
				case "canarynet":
				return .canarynet
				case "emulator":
				return .emulator
				default:
				return nil
		}
	}
}
