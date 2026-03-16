#if canImport(UIKit)
import Foundation
import FCLCore
import Flow
import AuthenticationServices
import SafariServices
import UIKit

/// iOS-specific FCL implementation that extends the core functionality
@MainActor
public final class FCLiOS: ObservableObject {
    public static let shared = FCLiOS()

    private let core: FCLCore
    private let keychain = KeychainStorage(serviceIdentifier: "@outblock/fcl-swift")
    private let userDefaults = UserDefaults.standard

    @Published public private(set) var currentUser: User?
    @Published public private(set) var currentEnv: Flow.ChainID = .mainnet
    @Published public private(set) var currentProvider: Provider?

    private var safariManager: SafariWebViewManager?

    public init(core: FCLCore = .shared) {
        self.core = core
        setupBindings()
        loadPersistedState()
    }

    private func setupBindings() {
        Task {
            await MainActor.run {
                self.currentUser = await core.currentUser
                self.currentEnv = await core.currentEnv
                self.currentProvider = await core.currentProvider
            }
        }
    }

    private func loadPersistedState() {
        // This will be implemented later
    }

    // MARK: - Configuration

    public func configure(
        metadata: Metadata,
        env: Flow.ChainID,
        provider: Provider
    ) async {
        await core.configure(metadata: metadata, env: env, provider: provider)

        if provider.supportAutoConnect {
            userDefaults.set(provider.id, forKey: PreferenceKey.provider.rawValue)
            userDefaults.set(env.name, forKey: PreferenceKey.env.rawValue)
        }

        await MainActor.run {
            currentProvider = provider
            currentEnv = env
        }
    }

    // MARK: - Authentication

    public func authenticate() async throws -> Response {
        let config = await core.config
        guard let endpoint = config.get(.authn),
              let url = URL(string: endpoint) else {
            throw FCLError.invalidURL
        }

        // Use Safari for authentication
        return try await authenticateWithSafari(url: url)
    }

    private func authenticateWithSafari(url: URL) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            safariManager = SafariWebViewManager()
            safariManager?.authenticate(url: url) { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let response):
                        if let user = self?.buildUser(from: response) {
                            self?.currentUser = user
                            self?.persistUser(user)
                        }
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                    self?.safariManager = nil
                }
            }
        }
    }

    public func unauthenticate() async throws {
        currentUser = nil
        try keychain.deleteAll()
    }

    // MARK: - Core Operations

    public func query(script: String, args: [Flow.Cadence.FValue] = []) async throws -> Flow.ScriptResponse {
        return try await core.query(script: script, args: args)
    }

    public func mutate(transaction: String, args: [Flow.Cadence.FValue] = []) async throws -> Flow.ID {
        return try await core.mutate(transaction: transaction, args: args)
    }

    // MARK: - Utilities

    public func generateNonce() -> String {
        return (0..<64).map { _ in "0123456789abcdef".randomElement()! }.map(String.init).joined()
    }

    // MARK: - Private Methods

    private func buildUser(from response: Response) -> User? {
        guard let addr = response.data?.addr else { return nil }

        return User(
            addr: Flow.Address(hex: addr),
            keyId: response.data?.keyId ?? 0,
            loggedIn: true,
            services: response.data?.services
        )
    }

    private func persistUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            try? keychain.add(data: data, forKey: StorageKey.currentUser.rawValue)
        }
    }

    private enum StorageKey: String {
        case currentUser
    }

    private enum PreferenceKey: String {
        case provider
        case env
    }
}

// MARK: - Safari Web View Manager

private class SafariWebViewManager: NSObject, SFSafariViewControllerDelegate {
    private var authenticationContinuation: CheckedContinuation<Response, Error>?
    private var safariVC: SFSafariViewController?

    func authenticate(url: URL, completion: @escaping (Result<Response, Error>) -> Void) {
        Task {
            do {
                let response = try await withCheckedThrowingContinuation { (continuation) in
                    self.authenticationContinuation = continuation
                }
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }

        DispatchQueue.main.async {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            vc.modalPresentationStyle = .formSheet
            self.safariVC = vc

            // Present from top view controller
            if let topVC = UIApplication.shared.windows.first?.rootViewController {
                topVC.present(vc, animated: true)
            }
        }
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        safariVC?.dismiss(animated: true)
        safariVC = nil
        authenticationContinuation?.resume(throwing: FCLError.declined)
        authenticationContinuation = nil
    }
}
#endif
