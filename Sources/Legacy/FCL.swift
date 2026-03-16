#if canImport(UIKit)
import Foundation
import FCLCore
import FCLiOS
import Flow

/// Legacy FCL module for backward compatibility
/// This module re-exports functionality from FCLCore and FCLiOS
/// while maintaining the original API surface
@available(*, deprecated, message: "Use FCLCore for cross-platform or FCLiOS for iOS-specific functionality")
@MainActor
public let fcl = FCL.shared

@available(*, deprecated, message: "Use FCLCore for cross-platform or FCLiOS for iOS-specific functionality")
@MainActor
public final class FCL: NSObject, ObservableObject {
    public static let shared = FCL()
    
    private let core: FCLCore
    private let ios: FCLiOS
    
    @Published public var currentUser: User?
    @Published public var currentEnv: Flow.ChainID = .mainnet
    @Published public var currentProvider: Provider?
    
    public var delegate: FCLDelegate?
    public var config = Config()
    public let version = "@outblock/fcl-swift@1.0.0-legacy"
    
    private override init() {
        self.core = FCLCore.shared
        self.ios = FCLiOS.shared
        super.init()
        setupBindings()
    }
    
    private func setupBindings() {
        Task {
            await MainActor.run {
                self.currentUser = self.ios.currentUser
                self.currentEnv = self.ios.currentEnv
                self.currentProvider = self.ios.currentProvider
            }
        }
    }
    
    // MARK: - Legacy API
    
    public func config(metadata: Metadata, env: Flow.ChainID, provider: Provider) {
        Task {
            await ios.configure(metadata: metadata, env: env, provider: provider)
        }
    }
    
    public func authenticate() async throws -> Response {
        return try await ios.authenticate()
    }
    
    public func unauthenticate() async throws {
        try await ios.unauthenticate()
    }
    
    public func query(script: String, args: [Flow.Cadence.FValue] = []) async throws -> Flow.ScriptResponse {
        return try await ios.query(script: script, args: args)
    }
    
    public func mutate(transaction: String, args: [Flow.Cadence.FValue] = []) async throws -> Flow.ID {
        return try await ios.mutate(transaction: transaction, args: args)
    }
    
    public func generateNonce() -> String {
        return ios.generateNonce()
    }
    
    public func openDiscovery() {
        // Legacy discovery UI would be shown here
        // For now, this is a placeholder
    }
    
    public func closeDiscoveryIfNeed(completion: (() -> Void)? = nil) {
        completion?()
    }
}

// MARK: - Legacy Supporting Types

@available(*, deprecated, message: "Use FCLCore types instead")
public extension FCL {
    typealias Metadata = FCLCore.Metadata
    typealias User = FCLCore.User
    typealias Provider = FCLCore.Provider
    typealias Response = FCLCore.Response
    typealias Service = FCLCore.Service
    typealias Config = FCLCore.Config
}

// MARK: - Legacy Delegate Protocol

@available(*, deprecated, message: "Use modern async/await APIs instead")
public protocol FCLDelegate: AnyObject {
    func showLoading()
    func hideLoading()
}
#endif
