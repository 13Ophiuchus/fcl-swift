@preconcurrency import Flow
import Foundation

public struct Provider: Sendable, Hashable {
    public let id: String
    public let name: String
    public let logo: URL?
    public let endpoint: @Sendable (Flow.ChainID) -> URL?
    public let provider: @Sendable (Flow.ChainID) -> ProviderInfo
    public let supportNetwork: [Flow.ChainID]
    public let supportAutoConnect: Bool

    public init(
        id: String,
        name: String,
        logo: URL?,
        endpoint: @Sendable @escaping (Flow.ChainID) -> URL?,
        provider: @Sendable @escaping (Flow.ChainID) -> ProviderInfo,
        supportNetwork: [Flow.ChainID],
        supportAutoConnect: Bool = true
    ) {
        self.id = id
        self.name = name
        self.logo = logo
        self.endpoint = endpoint
        self.provider = provider
        self.supportNetwork = supportNetwork
        self.supportAutoConnect = supportAutoConnect
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Provider, rhs: Provider) -> Bool {
        return lhs.id == rhs.id
    }
}

// Pre-defined providers
public extension Provider {
    static let flowWallet = Provider(
        id: "flow-wallet",
        name: "Flow Wallet",
        logo: URL(string: "https://fcl-discovery.onflow.org/images/flow-wallet.png"),
        endpoint: { chainId in
            switch chainId {
            case .mainnet: return URL(string: "https://fcl-discovery.onflow.org/api/mainnet/authn")
            case .testnet: return URL(string: "https://fcl-discovery.onflow.org/api/testnet/authn")
            default: return nil
            }
        },
        provider: { _ in ProviderInfo(name: "Flow Wallet") },
        supportNetwork: [.mainnet, .testnet]
    )

    static let blocto = Provider(
        id: "blocto",
        name: "Blocto",
        logo: URL(string: "https://fcl-discovery.onflow.org/images/blocto.png"),
        endpoint: { chainId in
            switch chainId {
            case .mainnet: return URL(string: "https://flow-wallet.blocto.app/api/flow/authn")
            case .testnet: return URL(string: "https://flow-wallet-testnet.blocto.app/api/flow/authn")
            default: return nil
            }
        },
        provider: { _ in ProviderInfo(name: "Blocto") },
        supportNetwork: [.mainnet, .testnet]
    )
}
