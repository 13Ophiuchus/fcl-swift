@preconcurrency import Flow
import Foundation

/// Core FCL implementation that is cross-platform compatible
/// This class is thread-safe and conforms to Swift 6 concurrency requirements
public actor FCLCore {
    public static let shared = FCLCore()
    
    public let version = "@outblock/fcl-swift@1.0.0"
    
    // Configuration
    public private(set) var config = Config()
    
    // Current state
    public private(set) var currentUser: User?
    public private(set) var currentEnv: Flow.ChainID = .mainnet
    public private(set) var currentProvider: Provider?
    
    // Services
    private var addressRegistry = AddressRegistry()
    private let httpProvider = HTTPProvider()
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Configuration
    
    public func configure(
        metadata: Metadata,
        env: Flow.ChainID,
        provider: Provider
    ) {
        var newConfig = Config()
        newConfig.put(.title, value: metadata.appName)
        newConfig.put(.description, value: metadata.appDescription)
        newConfig.put(.icon, value: metadata.appIcon.absoluteString)
        newConfig.put(.location, value: metadata.location.absoluteString)
        if let endpoint = provider.endpoint(env) {
            newConfig.put(.authn, value: endpoint.absoluteString)
        }
        newConfig.put(.env, value: env.name)
        
        if let accountProof = metadata.accountProof {
            newConfig.put(.nonce, value: accountProof.nonce)
            newConfig.put(.appId, value: accountProof.appIdentifier)
        }
        
        self.config = newConfig
        self.currentProvider = provider
        self.currentEnv = env
    }
    
    public func changeProvider(provider: Provider, env: Flow.ChainID) async throws {
        guard provider.supportNetwork.contains(env) else {
            throw FCLError.unsupportedNetwork
        }
        
        if let endpoint = provider.endpoint(env) {
            self.config.put(.authn, value: endpoint.absoluteString)
        }
        self.config.put(.env, value: env.name)
        
        self.currentProvider = provider
        self.currentEnv = env
    }
    
    // MARK: - Core Operations
    
    public func query(script: String, args: [Flow.Cadence.FValue] = []) async throws -> Flow.ScriptResponse {
        let processedScript = self.addressRegistry.processScript(script: script, chainId: self.currentEnv)
        var arguments: [Flow.Cadence.FValue] = []
        for arg in args {
            arguments.append(arg)
        }
        return try await httpProvider.executeScript(script: processedScript, args: arguments)
    }
    
    public func mutate(transaction: String, args: [Flow.Cadence.FValue] = []) async throws -> Flow.ID {
        let processedTx = self.addressRegistry.processScript(script: transaction, chainId: self.currentEnv)
        var arguments: [Flow.Cadence.FValue] = []
        for arg in args {
            arguments.append(arg)
        }
        return try await httpProvider.sendTransaction(transaction: processedTx, args: arguments)
    }
    
    // MARK: - Utilities
    
    public func generateNonce() -> String {
        let letters = "0123456789abcdef"
        return String((0 ..< 64).map { _ in letters.randomElement()! })
    }
}
