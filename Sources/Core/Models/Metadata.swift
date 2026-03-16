import Foundation

public struct Metadata: Sendable {
    public let appName: String
    public let appDescription: String
    public let appIcon: URL
    public let location: URL
    public let accountProof: AccountProofConfig?
    
    public init(
        appName: String,
        appDescription: String,
        appIcon: URL,
        location: URL,
        accountProof: AccountProofConfig? = nil
    ) {
        self.appName = appName
        self.appDescription = appDescription
        self.appIcon = appIcon
        self.location = location
        self.accountProof = accountProof
    }
    
    public struct AccountProofConfig: Sendable {
        public let appIdentifier: String
        public let nonce: String
        
        public init(appIdentifier: String, nonce: String) {
            self.appIdentifier = appIdentifier
            self.nonce = nonce
        }
    }
}