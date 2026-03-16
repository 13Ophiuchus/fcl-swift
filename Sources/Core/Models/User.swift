@preconcurrency import Flow
import Foundation

public struct User: Codable, Sendable {
    public let addr: Flow.Address
    public let keyId: Int
    public let loggedIn: Bool
    public let services: [Service]?

    public init(addr: Flow.Address, keyId: Int, loggedIn: Bool, services: [Service]? = nil) {
        self.addr = addr
        self.keyId = keyId
        self.loggedIn = loggedIn
        self.services = services
    }
}

public struct Service: Codable, Sendable {
    public let type: ServiceType
    public let endpoint: URL?
    public let method: ServiceMethod
    public let uid: String?
    public let identity: Identity?
    public let provider: ProviderInfo?
    public let params: [String: String]?

    public init(
        type: ServiceType,
        endpoint: URL? = nil,
        method: ServiceMethod,
        uid: String? = nil,
        identity: Identity? = nil,
        provider: ProviderInfo? = nil,
        params: [String: String]? = nil
    ) {
        self.type = type
        self.endpoint = endpoint
        self.method = method
        self.uid = uid
        self.identity = identity
        self.provider = provider
        self.params = params
    }
}

public struct Identity: Codable, Sendable {
    public let address: String?
    public let keyId: Int?

    public init(address: String? = nil, keyId: Int? = nil) {
        self.address = address
        self.keyId = keyId
    }
}

public struct ProviderInfo: Codable, Sendable {
    public let address: Flow.Address?
    public let name: String?

    public init(address: Flow.Address? = nil, name: String? = nil) {
        self.address = address
        self.name = name
    }
}

public enum ServiceType: String, Codable, Sendable {
    case authn
    case authz
    case preAuthz
    case userSignature
    case accountProof
}

public enum ServiceMethod: String, Codable, Sendable {
    case httpPost = "HTTP/POST"
    case httpGet = "HTTP/GET"
    case iframe = "IFRAME/RPC"
    case walletConnect = "WC/RPC"
    case httpConvert = "HTTP/POST/AUTHN"
}
