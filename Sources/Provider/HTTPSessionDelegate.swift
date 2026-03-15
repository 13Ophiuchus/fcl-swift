import SwiftUI


@MainActor
public protocol HTTPSessionDelegate: AnyObject {
	var isPending: Bool { get set }

	func openAuthenticationSession(service: FCL.Service) throws
	func closeSession()

		// Add these two so SafariWebViewManager can call them safely.
	func handleRedirect(url: URL)
	func stopPolling()
}
