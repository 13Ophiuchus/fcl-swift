@preconcurrency import Flow
import Foundation

public protocol HTTPProviderProtocol: Sendable {
    func executeScript(script: String, args: [Flow.Cadence.FValue]) async throws -> Flow.ScriptResponse
    func sendTransaction(transaction: String, args: [Flow.Cadence.FValue]) async throws -> Flow.ID
    func getAccount(address: Flow.Address) async throws -> Flow.Account
    func getLatestBlock() async throws -> Flow.Block
}

public actor HTTPProvider: HTTPProviderProtocol {
    private let flow: Flow

    public init(flow: Flow = .shared) {
        self.flow = flow
    }

    public func executeScript(script: String, args: [Flow.Cadence.FValue]) async throws -> Flow.ScriptResponse {
        let script = Flow.Script(text: script)
        var arguments: [Flow.Cadence.FValue] = []
        for arg in args {
            arguments.append(arg)
        }
        return try await flow.accessAPI.executeScriptAtLatestBlock(script: script, arguments: arguments)
    }

    public func sendTransaction(transaction: String, args: [Flow.Cadence.FValue]) async throws -> Flow.ID {
        // This is a simplified implementation - in a real implementation,
        // you would need to handle transaction signing and submission
        throw FCLError.generic
    }

    public func getAccount(address: Flow.Address) async throws -> Flow.Account {
        return try await flow.accessAPI.getAccountAtLatestBlock(address: address)
    }

    public func getLatestBlock() async throws -> Flow.Block {
        return try await flow.accessAPI.getLatestBlock()
    }
}
