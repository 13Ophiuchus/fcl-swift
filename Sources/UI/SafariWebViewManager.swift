	// UI/SafariWebViewManager.swift

import Foundation
import SwiftUI

@MainActor
public final class SafariWebViewManager: ObservableObject {

	public static let shared = SafariWebViewManager()

	public weak var delegate: HTTPSessionDelegate?
	@Published private(set) var currentURL: URL?

	private init() {}

		// Called by FCL / HTTPClient to start an auth flow.
	public func open(url: URL) {
		currentURL = url
		delegate?.handleRedirect(url: url)
	}

		// Convenience for callers; just stops polling and clears state.
	public func close() {
		stopPolling()
	}

	public func stopPolling() {
		delegate?.stopPolling()
		delegate = nil
		currentURL = nil
	}

		// Static helpers used by HTTPClient and older call sites.

	public static func openSafariWebView(url: URL) {
		SafariWebViewManager.shared.open(url: url)
	}

	public static func closeSafariWebView() {
		SafariWebViewManager.shared.close()
	}
}
