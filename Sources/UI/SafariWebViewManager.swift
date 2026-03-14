// UI/SafariWebViewManager.swift

#if canImport(UIKit)
import UIKit
import SafariServices

@MainActor
final class SafariWebViewManager: NSObject {
    static let shared = SafariWebViewManager()

    private var safariVC: SFSafariViewController?
    var delegate: HTTPSessionDelegate?

    static func openSafariWebView(url: URL) {
        DispatchQueue.main.async {
            let vc = SFSafariViewController(url: url)
            vc.delegate = SafariWebViewManager.shared
            vc.presentationController?.delegate = SafariWebViewManager.shared
            SafariWebViewManager.shared.safariVC = vc
            UIApplication.shared.topMostViewController?.present(vc, animated: true)
        }
    }

    static func closeSafariWebView() {
        if let vc = SafariWebViewManager.shared.safariVC {
            DispatchQueue.main.async {
                vc.dismiss(animated: true)
            }
            SafariWebViewManager.shared.stopPolling()
        }
    }

    func stopPolling() {
        delegate?.stopPolling()
        delegate = nil
        safariVC = nil
    }
}

extension SafariWebViewManager: SFSafariViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    func safariViewControllerDidFinish(_: SFSafariViewController) {
        stopPolling()
    }

    func presentationControllerDidDismiss(_: UIPresentationController) {
        stopPolling()
    }
}
#endif
