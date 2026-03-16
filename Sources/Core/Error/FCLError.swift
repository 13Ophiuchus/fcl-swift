import Foundation

public enum FCLError: String, Error, LocalizedError, Sendable {
    case generic
    case invalidURL
    case invalidNetwork
    case invalidService
    case invalidSession
    case invalidWalletProvider
    case invalidAuthzResponse
    case generateURIFailed
    case declined
    case invalidResponse
    case decodeFailure
    case unauthenticated
    case missingAuthz
    case missingPreAuthz
    case missingPayer
    case unhandledService
    case encodeFailure
    case convertToTxFailure
    case invalidProposer
    case fetchAccountFailure
    case failedToConnectWallet
    case unsupportedNetwork
    
    public var errorDescription: String? {
        switch self {
        case .generic: return "A generic error occurred"
        case .invalidURL: return "Invalid URL provided"
        case .invalidNetwork: return "Invalid network configuration"
        case .invalidService: return "Invalid service configuration"
        case .invalidSession: return "Invalid session"
        case .invalidWalletProvider: return "Invalid wallet provider"
        case .invalidAuthzResponse: return "Invalid authorization response"
        case .generateURIFailed: return "Failed to generate URI"
        case .declined: return "Request was declined"
        case .invalidResponse: return "Invalid response from service"
        case .decodeFailure: return "Failed to decode response"
        case .unauthenticated: return "User is not authenticated"
        case .missingAuthz: return "Missing authorization"
        case .missingPreAuthz: return "Missing pre-authorization"
        case .missingPayer: return "Missing payer"
        case .unhandledService: return "Unhandled service type"
        case .encodeFailure: return "Failed to encode request"
        case .convertToTxFailure: return "Failed to convert to transaction"
        case .invalidProposer: return "Invalid proposer"
        case .fetchAccountFailure: return "Failed to fetch account"
        case .failedToConnectWallet: return "Failed to connect wallet"
        case .unsupportedNetwork: return "Unsupported network"
        }
    }
}