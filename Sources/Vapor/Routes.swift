import Vapor
import FCLCore
import Flow

/// Example Vapor routes demonstrating FCL integration
public func routes(_ app: Application) throws {
    
    // Configure FCL
    let fclConfig = FCLVapor.Configuration(
        accessNodeURL: "https://access-testnet.onflow.org",
        chainID: .testnet,
        appMetadata: Metadata(
            appName: "FCL Vapor Demo",
            appDescription: "Server-side Flow blockchain integration",
            appIcon: URL(string: "https://example.com/icon.png")!,
            location: URL(string: "https://example.com")!
        ),
        serverAccount: FCLVapor.ServerAccount(
            address: Flow.Address(hex: "0x123"), // Replace with actual address
            privateKey: "your-private-key" // Replace with actual key
        )
    )
    
    app.configureFCL(fclConfig)
    
    // MARK: - API Routes
    
    // Health check
    app.get { req async -> String in
        "FCL Vapor server is running"
    }
    
    // Query Flow blockchain
    app.get("api", "query") { req async throws -> String in
        guard let fcl = req.fcl else {
            throw Abort(.internalServerError, reason: "FCL not configured")
        }
        
        let script = """
            pub fun main(): Int {
                return 42
            }
        """
        
        let response = try await fcl.query(script: script)
        return "Query result: \(response)"
    }
    
    // Get account information
    app.get("api", "account", ":address") { req async throws -> String in
        guard let fcl = req.fcl else {
            throw Abort(.internalServerError, reason: "FCL not configured")
        }
        
        guard let addressString = req.parameters.get("address") else {
            throw Abort(.badRequest, reason: "Invalid address")
        }
        let address = Flow.Address(hex: addressString)
        
        let account = try await fcl.getAccount(address: address)
        return "Account: \(account)"
    }
    
    // Get latest block
    app.get("api", "block", "latest") { req async throws -> String in
        guard let fcl = req.fcl else {
            throw Abort(.internalServerError, reason: "FCL not configured")
        }
        
        let block = try await fcl.getLatestBlock()
        return "Latest block: \(block)"
    }
    
    // Execute transaction (requires server account)
    app.post("api", "transaction") { req async throws -> String in
        guard let fcl = req.fcl else {
            throw Abort(.internalServerError, reason: "FCL not configured")
        }
        
        struct TransactionRequest: Content {
            let transaction: String
            let arguments: [String]?
        }
        
        let txRequest = try req.content.decode(TransactionRequest.self)
        
        // This would execute a transaction signed by the server account
        // For demo purposes, we'll just return a message
        return "Transaction would be executed: \(txRequest.transaction)"
    }
}