import Vapor
import FCLCore
@preconcurrency import Flow

/// Vapor integration for FCL - enables server-side Flow blockchain interactions
public struct FCLVapor {
    /// Configuration for FCL in a Vapor application
    public struct Configuration: Sendable {
        public let accessNodeURL: String
        public let chainID: Flow.ChainID
        public let appMetadata: Metadata
        public let serverAccount: ServerAccount?

        public init(
            accessNodeURL: String,
            chainID: Flow.ChainID,
            appMetadata: Metadata,
            serverAccount: ServerAccount? = nil
        ) {
            self.accessNodeURL = accessNodeURL
            self.chainID = chainID
            self.appMetadata = appMetadata
            self.serverAccount = serverAccount
        }
    }

    /// Server-side account configuration for signing transactions
    public struct ServerAccount: Sendable {
        public let address: Flow.Address
        public let privateKey: String
        public let keyIndex: Int

        public init(address: Flow.Address, privateKey: String, keyIndex: Int = 0) {
            self.address = address
            self.privateKey = privateKey
            self.keyIndex = keyIndex
        }
    }

    /// FCL service for Vapor applications
    public final class Service: Sendable {
        private let core: FCLCore
        private let configuration: Configuration

        public init(configuration: Configuration) {
            self.configuration = configuration
            self.core = FCLCore.shared

            // Configure the core service
            Task {
                await core.configure(
                    metadata: configuration.appMetadata,
                    env: configuration.chainID,
                    provider: .flowWallet // Default provider for server-side
                )
            }
        }

        // MARK: - Server-side Operations

        /// Execute a Cadence script on the blockchain
        public func query(
            script: String,
            arguments: [Flow.Cadence.FValue] = []
        ) async throws -> Flow.ScriptResponse {
            var deepCopiedArguments: [Flow.Cadence.FValue] = []
            for argument in arguments {
                deepCopiedArguments.append(argument)
            }
            return try await core.query(script: script, args: deepCopiedArguments)
        }

        /// Execute a transaction (requires server account for signing)
        public func mutate(
            transaction: String,
            arguments: [Flow.Cadence.FValue] = [],
            proposer: Flow.Address? = nil,
            authorizers: [Flow.Address]? = nil,
            payer: Flow.Address? = nil
        ) async throws -> Flow.ID {
            guard let serverAccount = configuration.serverAccount else {
                throw FCLError.unauthenticated
            }

            // Build and sign transaction with server account
            return try await signAndSendTransaction(
                transaction: transaction,
                arguments: arguments,
                proposer: proposer ?? serverAccount.address,
                authorizers: authorizers ?? [serverAccount.address],
                payer: payer ?? serverAccount.address,
                signer: serverAccount
            )
        }

        /// Get account information
        public func getAccount(address: Flow.Address) async throws -> Flow.Account {
            let flow = Flow.shared
            return try await flow.accessAPI.getAccountAtLatestBlock(address: address)
        }

        /// Get the latest block
        public func getLatestBlock() async throws -> Flow.Block {
            let flow = Flow.shared
            return try await flow.accessAPI.getLatestBlock()
        }

        // MARK: - Private Methods

        private func signAndSendTransaction(
            transaction: String,
            arguments: [Flow.Cadence.FValue],
            proposer: Flow.Address,
            authorizers: [Flow.Address],
            payer: Flow.Address,
            signer: ServerAccount
        ) async throws -> Flow.ID {
            // This is a simplified implementation
            // In a real implementation, you would:
            // 1. Build the transaction
            // 2. Get the latest block for reference
            // 3. Sign with the server account
            // 4. Submit to the network

            throw FCLError.generic
        }
    }
}

// MARK: - Vapor Integration

public extension Application {
    private struct FCLKey: StorageKey {
        public typealias Value = FCLVapor.Service
    }

    /// Configure FCL for this Vapor application
    func configureFCL(_ configuration: FCLVapor.Configuration) {
        let fclService = FCLVapor.Service(configuration: configuration)
        storage[FCLKey.self] = fclService
    }

    /// Get the FCL service
    var fcl: FCLVapor.Service? {
        storage[FCLKey.self]
    }
}

public extension Request {
    /// Get the FCL service from the request
    var fcl: FCLVapor.Service? {
        application.fcl
    }
}
