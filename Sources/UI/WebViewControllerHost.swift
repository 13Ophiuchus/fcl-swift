	// UI/WebViewControllerHost.swift

#if canImport(SwiftUI) && canImport(WebKit)

import Foundation
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
	func makeNSView(context: Context) -> WKWebView {
		WKWebView()
	}

	func updateNSView(_ nsView: WKWebView, context: Context) {
		let request = URLRequest(url: url)
		nsView.load(request)
	}

	typealias NSViewType = WKWebView

	let url: URL

	func makeUIView(context: Context) -> WKWebView {
		WKWebView()
	}

	func updateUIView(_ webView: WKWebView, context: Context) {
		let request = URLRequest(url: url)
		webView.load(request)
	}
}
@MainActor
final class WebViewControllerHost: ObservableObject {

	static let shared = WebViewControllerHost()

	@Published var isPresented = false  // Removed private(set)
	@Published private(set) var currentURL: URL?

	private init() {}

	func present(url: URL) {
		currentURL = url
		isPresented = true
	}

	func dismiss() {
		isPresented = false
		currentURL = nil
		SafariWebViewManager.shared.stopPolling()
	}
}

/// Root overlay you can inject once into your app's scene hierarchy.
@available(macOS 11.0, *)
public struct FCLWebOverlay: View {
	@StateObject private var host = WebViewControllerHost.shared

	public init() {}

	public var body: some View {
		EmptyView()
			.sheet(isPresented: $host.isPresented) {
				if let url = host.currentURL {
					WebView(url: url)
						.ignoresSafeArea()
				} else {
					EmptyView()
				}
			}
	}
}
#endif
