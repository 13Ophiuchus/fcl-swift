import XCTest
@testable import FCLCore

final class BasicBuildTest: XCTestCase {
    
    func testBasicInitialization() {
        let fcl = FCLCore()
        XCTAssertNotNil(fcl)
    }
    
    func testMetadataCreation() {
        let metadata = Metadata(
            appName: "Test App",
            appDescription: "Test Description",
            appIcon: URL(string: "https://example.com/icon.png")!,
            location: URL(string: "https://example.com")!
        )
        
        XCTAssertEqual(metadata.appName, "Test App")
        XCTAssertEqual(metadata.appDescription, "Test Description")
    }
}