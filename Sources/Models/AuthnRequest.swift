	// Models/AuthnRequest.swift

import Foundation

@MainActor
public struct BaseConfigRequest: Encodable {
	var app: [String: String]
	var service: [String: String]
	var client: ClientInfo

	var appIdentifier: String
	var accountProofNonce: String

	var config: AppConfig

	public init() {
		self.app = fcl.config.configLens("^app\\.detail\\.")
		self.service = fcl.config.configLens("^service\\.")
		self.client = ClientInfo()
		self.appIdentifier = fcl.config.get(.appId) ?? ""
		self.accountProofNonce = fcl.config.get(.nonce) ?? ""
		self.config = AppConfig()
	}
}

@MainActor
public struct AppConfig: Encodable {
	var app: [String: String]

	public init() {
		self.app = fcl.config.configLens("^app\\.detail\\.")
	}
}

@MainActor
public struct ClientInfo: Encodable {
	var fclVersion: String
	var fclLibrary: URL

	public init() {
		self.fclVersion = fcl.version
		self.fclLibrary = URL(string: "https://github.com/Outblock/fcl-swift")!
	}
}
