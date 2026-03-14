// Models/AuthnRequest.swift

import Foundation

public struct BaseConfigRequest: Encodable {
    @MainActor
    private static func defaultApp() -> [String: String] {
        fcl.config.configLens("^app\\.detail\\.")
    }

    @MainActor
    private static func defaultService() -> [String: String] {
        fcl.config.configLens("^service\\.")
    }

    @MainActor
    private static func defaultAppId() -> String {
        fcl.config.get(.appId) ?? ""
    }

    @MainActor
    private static func defaultNonce() -> String {
        fcl.config.get(.nonce) ?? ""
    }

    var app: [String: String] = BaseConfigRequest.defaultApp()
    var service: [String: String] = BaseConfigRequest.defaultService()
    var client = ClientInfo()

    var appIdentifier: String = BaseConfigRequest.defaultAppId()
    var accountProofNonce: String = BaseConfigRequest.defaultNonce()

    var config = AppConfig()
}

public struct AppConfig: Encodable {
    @MainActor
    private static func defaultApp() -> [String: String] {
        fcl.config.configLens("^app\\.detail\\.")
    }

    var app: [String: String] = AppConfig.defaultApp()
}

public struct ClientInfo: Encodable {
    @MainActor
    private static func defaultVersion() -> String {
        fcl.version
    }

    var fclVersion: String = ClientInfo.defaultVersion()
    var fclLibrary = URL(string: "https://github.com/Outblock/fcl-swift")!
}
