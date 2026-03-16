import Foundation

public struct Response: Codable, Sendable {
    public let status: ResponseStatus
    public let data: ResponseData?
    public let reason: String?
    public let local: Service?
    public let updates: Service?
    public let authorizationUpdates: Service?
    
    public init(
        status: ResponseStatus,
        data: ResponseData? = nil,
        reason: String? = nil,
        local: Service? = nil,
        updates: Service? = nil,
        authorizationUpdates: Service? = nil
    ) {
        self.status = status
        self.data = data
        self.reason = reason
        self.local = local
        self.updates = updates
        self.authorizationUpdates = authorizationUpdates
    }
}

public struct ResponseData: Codable, Sendable {
    public let addr: String?
    public let keyId: Int?
    public let services: [Service]?
    
    public init(addr: String? = nil, keyId: Int? = nil, services: [Service]? = nil) {
        self.addr = addr
        self.keyId = keyId
        self.services = services
    }
}

public enum ResponseStatus: String, Codable, Sendable {
    case approved = "APPROVED"
    case declined = "DECLINED"
    case pending = "PENDING"
}