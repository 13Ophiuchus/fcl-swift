<<<<<<< HEAD
// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

=======
// swift-tools-version:6.2
>>>>>>> e8c5942 (f)
import PackageDescription

let package = Package(
    name: "fcl-swift",
    platforms: [
<<<<<<< HEAD
        .iOS(.v16),
=======
        .iOS(.v13),
>>>>>>> e8c5942 (f)
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "FCLCore",
            targets: ["FCLCore"]
        ),
        .library(
            name: "FCLiOS",
            targets: ["FCLiOS"]
        ),
        .library(
            name: "FCLVapor",
            targets: ["FCLVapor"]
        ),
        .library(
            name: "FCL",
            targets: ["FCL"]
        ),
    ],
    dependencies: [
<<<<<<< HEAD
        .package(url: "https://github.com/outblock/flow-swift.git", exact: "0.3.1"),
        .package(url: "https://github.com/daltoniam/Starscream", exact: "3.1.1"),
        .package(url: "https://github.com/WalletConnect/WalletConnectSwiftV2", exact: "1.6.11"),
        .package(url: "https://github.com/1024jp/GzipSwift", exact: "5.2.0"),
=======
        .package(url: "https://github.com/outblock/flow-swift.git", from: "0.3.1"),
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.2.0"),
        
        // iOS-specific dependencies
        .package(url: "https://github.com/daltoniam/Starscream", from: "3.1.1"),
        .package(url: "https://github.com/WalletConnect/WalletConnectSwiftV2", from: "1.6.11"),
        
        // Vapor dependencies
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
>>>>>>> e8c5942 (f)
    ],
    targets: [
        // MARK: - Core Module (Cross-platform)
        .target(
            name: "FCLCore",
            dependencies: [
                .product(name: "Flow", package: "flow-swift"),
                .product(name: "Gzip", package: "GzipSwift"),
            ],
            path: "Sources/Core"
        ),
        
        // MARK: - iOS Module
        .target(
            name: "FCLiOS",
            dependencies: [
                "FCLCore",
                .product(name: "Flow", package: "flow-swift"),
                .product(name: "Starscream", package: "Starscream"),
                .product(name: "WalletConnect", package: "WalletConnectSwiftV2"),
                .product(name: "WalletConnectAuth", package: "WalletConnectSwiftV2"),
            ],
            path: "Sources/iOS"
        ),
        
        // MARK: - Vapor Module
        .target(
            name: "FCLVapor",
            dependencies: [
                "FCLCore",
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Sources/Vapor"
        ),
        
        // MARK: - Legacy FCL Module (for backward compatibility)
        .target(
            name: "FCL",
            dependencies: [
                "FCLCore",
                "FCLiOS",
            ],
            path: "Sources/Legacy"
        ),
        
        // MARK: - Tests
        .testTarget(
            name: "FCLCoreTests",
            dependencies: ["FCLCore"],
            path: "Tests/CoreTests"
        ),
        .testTarget(
            name: "FCLiOSTests",
            dependencies: ["FCLiOS"],
            path: "Tests/iOSTests"
        ),
        .testTarget(
            name: "FCLVaporTests",
            dependencies: ["FCLVapor"],
            path: "Tests/VaporTests"
        ),
    ]
)