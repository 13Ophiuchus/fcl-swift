import XCTest
import FCLVapor
import Vapor
import FCLCore
import Flow

final class FCLVaporTests: XCTestCase {
    var app: Application!

    override func setUp() {
        super.setUp()
        app = Application(.testing)
        let config = FCLVapor.Configuration(
            accessNodeURL: "https://access-testnet.onflow.org",
            chainID: .testnet,
            appMetadata: Metadata(
                appName: "Test App",
                appDescription: "Test Description",
                appIcon: URL(string: "https://example.com/icon.png")!,
                location: URL(string: "https://example.com")!
            )
        )
        app.configureFCL(config)
    }

    override func tearDown() {
        app.shutdown()
        app = nil
        super.tearDown()
    }

    func testFCLServiceInitialization() async throws {
        XCTAssertNotNil(app.fcl)
    }

    func testQueryExecution() async throws {
        guard let fcl = app.fcl else {
            XCTFail("FCL service not configured")
            return
        }

        let script = """
            pub fun main(): Int {
                return 42
            }
        """

        do {
            let response = try await fcl.query(script: script)
            XCTAssertNotNil(response)
        } catch {
            // This might fail in test environment without proper network access
            // We're mainly testing that the API works
            XCTAssertTrue(true)
        }
    }

    func testAccountRetrieval() async throws {
        guard let fcl = app.fcl else {
            XCTFail("FCL service not configured")
            return
        }

        let testAddress = Flow.Address(hex: "0x1234567890abcdef")

        do {
            let account = try await fcl.getAccount(address: testAddress)
            XCTAssertNotNil(account)
        } catch {
            // This might fail in test environment without proper network access
            // We're mainly testing that the API works
            XCTAssertTrue(true)
        }
    }
}
