import Foundation
public extension FCL {
    /// Non-actor-isolated strategy interface. Concrete providers can be @MainActor.
    internal protocol FCLStrategy {
        func execService(
            service: FCL.Service,
            request: (any Encodable & Sendable)?
        ) async throws -> FCL.Response

        func execService(
            url: URL,
            method: FCL.ServiceType,
            request: (any Encodable & Sendable)?
        ) async throws -> FCL.Response
    }
}
