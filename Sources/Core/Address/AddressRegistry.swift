@preconcurrency import Flow
import Foundation

public struct AddressRegistry: Sendable {
    private var registry: [String: [Flow.ChainID: Flow.Address]] = [:]

    public init() {
        // Initialize with common contracts
        registerContract("FungibleToken", addresses: [
            .mainnet: Flow.Address(hex: "0xf233dcee88fe0abe"),
            .testnet: Flow.Address(hex: "0x9a0766d93b6608b7"),
        ])

        registerContract("FUSD", addresses: [
            .mainnet: Flow.Address(hex: "0x3c5959b568896393"),
            .testnet: Flow.Address(hex: "0xe223d8a629e49c68"),
        ])
    }

    public mutating func registerContract(_ name: String, addresses: [Flow.ChainID: Flow.Address]) {
        registry[name] = addresses
    }

    public func processScript(script: String, chainId: Flow.ChainID) -> String {
        var processedScript = script

        for (contractName, addresses) in registry {
            if let address = addresses[chainId] {
                processedScript = processedScript.replacingOccurrences(
                    of: "0x\(contractName)",
                    with: address.hex
                )
            }
        }

        return processedScript
    }
}
