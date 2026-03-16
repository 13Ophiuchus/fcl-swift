# FCL Swift - Flow Client Library

A Swift library for building applications on the Flow blockchain, now with cross-platform support and server-side capabilities.

## 🚀 Features

- **Cross-platform**: Works on iOS, macOS, and Linux
- **Swift 6 Compatible**: Full concurrency support with `Sendable` conformance
- **Modular Architecture**: Separate modules for core functionality, iOS-specific features, and Vapor server integration
- **Type-safe**: Comprehensive error handling and type safety
- **Async/Await**: Modern Swift concurrency patterns

## 📦 Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/outblock/fcl-swift.git", from: "1.0.0")
]
```

## 🏗️ Module Structure

### FCLCore
Cross-platform core functionality:
```swift
import FCLCore

let fcl = FCLCore.shared
await fcl.configure(
    metadata: Metadata(
        appName: "My App",
        appDescription: "My Flow App",
        appIcon: URL(string: "https://example.com/icon.png")!,
        location: URL(string: "https://example.com")!
    ),
    env: .testnet,
    provider: .flowWallet
)

// Query the blockchain
let result = try await fcl.query(script: "pub fun main(): Int { return 42 }")
```

### FCLiOS
iOS-specific features with UI integration:
```swift
import FCLiOS

let fcl = FCLiOS.shared
await fcl.configure(
    metadata: metadata,
    env: .testnet,
    provider: .flowWallet
)

// Authenticate with wallet
let response = try await fcl.authenticate()
```

### FCLVapor
Server-side Flow blockchain integration:
```swift
import Vapor
import FCLVapor

// Configure FCL in your Vapor app
app.configureFCL(FCLVapor.Configuration(
    accessNodeURL: "https://access-testnet.onflow.org",
    chainID: .testnet,
    appMetadata: Metadata(...),
    serverAccount: ServerAccount(address: ..., privateKey: ...)
))

// Use in routes
app.get("api", "query") { req async throws in
    guard let fcl = req.fcl else {
        throw Abort(.internalServerError)
    }
    
    return try await fcl.query(script: "pub fun main(): Int { return 42 }")
}
```

## 🔧 Usage Examples

### iOS App Configuration

```swift
import SwiftUI
import FCLiOS

@main
struct MyFlowApp: App {
    @StateObject private var fcl = FCLiOS.shared
    
    init() {
        setupFCL()
    }
    
    func setupFCL() {
        Task {
            let metadata = Metadata(
                appName: "My Flow App",
                appDescription: "A decentralized app on Flow",
                appIcon: URL(string: "https://example.com/icon.png")!,
                location: URL(string: "https://example.com")!
            )
            
            await fcl.configure(
                metadata: metadata,
                env: .testnet,
                provider: .flowWallet
            )
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fcl)
        }
    }
}
```

### Vapor Server Configuration

```swift
import Vapor
import FCLVapor

@main
struct App: Application {
    func configure(_ app: Application) throws {
        // Configure FCL
        let fclConfig = FCLVapor.Configuration(
            accessNodeURL: "https://access-testnet.onflow.org",
            chainID: .testnet,
            appMetadata: Metadata(
                appName: "My Flow API",
                appDescription: "Server-side Flow integration",
                appIcon: URL(string: "https://api.example.com/icon.png")!,
                location: URL(string: "https://api.example.com")!
            ),
            serverAccount: FCLVapor.ServerAccount(
                address: Flow.Address(hex: "0x1234567890abcdef"),
                privateKey: "your-private-key",
                keyIndex: 0
            )
        )
        
        app.configureFCL(fclConfig)
        
        // Register routes
        try routes(app)
    }
    
    func routes(_ app: Application) throws {
        app.get("api", "account", ":address") { req async throws -> AccountResponse in
            guard let fcl = req.fcl else {
                throw Abort(.internalServerError, reason: "FCL not configured")
            }
            
            guard let addressString = req.parameters.get("address"),
                  let address = Flow.Address(hex: addressString) else {
                throw Abort(.badRequest, reason: "Invalid address")
            }
            
            let account = try await fcl.getAccount(address: address)
            return AccountResponse(account: account)
        }
        
        app.post("api", "execute") { req async throws -> ExecuteResponse in
            guard let fcl = req.fcl else {
                throw Abort(.internalServerError, reason: "FCL not configured")
            }
            
            let executeRequest = try req.content.decode(ExecuteRequest.self)
            
            let result = try await fcl.query(
                script: executeRequest.script,
                arguments: executeRequest.arguments ?? []
            )
            
            return ExecuteResponse(result: result)
        }
    }
}

struct AccountResponse: Content {
    let account: Flow.Account
}

struct ExecuteRequest: Content {
    let script: String
    let arguments: [Flow.Cadence.FValue]?
}

struct ExecuteResponse: Content {
    let result: Flow.ScriptResponse
}
```

## 🔄 Migration from 0.x

### Breaking Changes

1. **Module Structure**: The library is now modular. Import the specific module you need:
   - `import FCLCore` for cross-platform functionality
   - `import FCLiOS` for iOS-specific features
   - `import FCLVapor` for server-side integration

2. **Concurrency**: All APIs now use `async/await` instead of callbacks:
   ```swift
   // Old
   fcl.authenticate { result in
       // Handle result
   }
   
   // New
   let result = try await fcl.authenticate()
   ```

3. **Configuration**: Configuration is now done through the `configure` method:
   ```swift
   // Old
   fcl.config(metadata: metadata, env: env, provider: provider)
   
   // New (Core)
   await fcl.configure(metadata: metadata, env: env, provider: provider)
   
   // New (iOS)
   await fcl.configure(metadata: metadata, env: env, provider: provider)
   ```

### Backward Compatibility

The legacy `FCL` module is available for backward compatibility but is deprecated:
```swift
import FCL // Deprecated, use specific modules instead
```

## 🧪 Testing

Run tests for all platforms:
```bash
swift test
```

Run tests for specific modules:
```bash
swift test --filter FCLCoreTests
swift test --filter FCLiOSTests
swift test --filter FCLVaporTests
```

## 🚀 Deployment

### iOS/macOS
The library supports iOS 13+, macOS 10.15+, and Linux. Build for your target platform:
```bash
swift build -c release
```

### Linux Server
Deploy your Vapor application with FCL integration:
```bash
swift build -c release
./.build/release/YourApp
```

## 📚 Documentation

- [API Documentation](https://outblock.github.io/fcl-swift/)
- [Flow Blockchain Documentation](https://docs.onflow.org/)
- [Vapor Documentation](https://docs.vapor.codes/)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flow blockchain team for the excellent infrastructure
- Vapor team for the amazing server-side Swift framework
- The Flow community for continuous support and feedback