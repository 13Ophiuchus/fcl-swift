import Foundation

public struct Config: Sendable {
    private var storage: [String: String] = [:]

    public init() {}

    @discardableResult
    public mutating func put(_ key: Key, value: String) -> Config {
        storage[key.rawValue] = value
        return self
    }

    public func get(_ key: Key) -> String? {
        return storage[key.rawValue]
    }

    public var dict: [String: String] {
        return storage
    }

    public enum Key: String, CaseIterable, Sendable {
        case title = "app.detail.title"
        case description = "app.detail.description"
        case icon = "app.detail.icon"
        case location = "location"
        case authn = "discovery.wallet"
        case env = "env"
        case providerMethod = "fcl.method"
        case nonce = "app.detail.nonce"
        case appId = "app.detail.id"
        case projectID = "walletconnect.projectid"
        case urlSheme = "walletconnect.urlscheme"
    }
}
