import XCTest
import FCLCore
@preconcurrency import Flow

@MainActor
final class FCLCoreTests: XCTestCase {
    func testCoreInitialization() async {
        let fcl = FCLCore()

        // Test initial state
        let currentUser = await fcl.currentUser
        let currentEnv = await fcl.currentEnv
        let currentProvider = await fcl.currentProvider
        XCTAssertNil(currentUser)
        XCTAssertEqual(currentEnv, .mainnet)
        XCTAssertNil(currentProvider)
    }

    func testConfiguration() async {
        let fcl = FCLCore()

        let metadata = Metadata(
            appName: "Test App",
            appDescription: "Test Description",
            appIcon: URL(string: "https://example.com/icon.png")!,
            location: URL(string: "https://example.com")!
        )

        await fcl.configure(
            metadata: metadata,
            env: .testnet,
            provider: .flowWallet
        )

        let currentEnv = await fcl.currentEnv
        let currentProvider = await fcl.currentProvider
        XCTAssertEqual(currentEnv, .testnet)
        XCTAssertEqual(currentProvider, .flowWallet)
    }

    func testNonceGeneration() async {
        let fcl = FCLCore()
        let nonce1 = await fcl.generateNonce()
        let nonce2 = await fcl.generateNonce()

        XCTAssertEqual(nonce1.count, 64)
        XCTAssertEqual(nonce2.count, 64)
        XCTAssertNotEqual(nonce1, nonce2)
    }

    func testScriptProcessing() async {
        let fcl = FCLCore()

        let metadata = Metadata(
            appName: "Test App",
            appDescription: "Test Description",
            appIcon: URL(string: "https://example.com/icon.png")!,
            location: URL(string: "https://example.com")!
        )

        await fcl.configure(
            metadata: metadata,
            env: .mainnet,
            provider: .flowWallet
        )

        // Test address replacement
        var config = await fcl.config
        config.put(.title, value: "New Title")

        // This would test the script processing if we had access to the private method
        // For now, we just verify the configuration was set
        XCTAssertEqual(config.get(.title), "New Title")
    }
}
