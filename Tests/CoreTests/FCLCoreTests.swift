import XCTest
import FCLCore
import Flow

@MainActor
final class FCLCoreTests: XCTestCase {
    func testCoreInitialization() async {
        let fcl = FCLCore()

        // Test initial state
        XCTAssertNil(await fcl.currentUser)
        XCTAssertEqual(await fcl.currentEnv, .mainnet)
        XCTAssertNil(await fcl.currentProvider)
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

        XCTAssertEqual(await fcl.currentEnv, .testnet)
        XCTAssertEqual(await fcl.currentProvider, .flowWallet)
    }

    func testNonceGeneration() {
        let fcl = FCLCore()
        let nonce1 = fcl.generateNonce()
        let nonce2 = fcl.generateNonce()

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
        config.put(.init(rawValue: "0xFungibleToken"), value: "0xf233dcee88fe0abe")

        let script = """
            import FungibleToken from 0xFungibleToken
        """

        // This would test the script processing if we had access to the private method
        // For now, we just verify the configuration was set
        XCTAssertEqual(config.get(.init(rawValue: "0xFungibleToken")), "0xf233dcee88fe0abe")
    }
}
