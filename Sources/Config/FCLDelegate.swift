//
//  FCLDelegate.swift
//  FCL
//
//  Created by Nicholas Reich on 3/15/26.
//

import AuthenticationServices
import Foundation

	/// UI delegate for FCL flows.
	/// Kept on the main actor so it never has to be Sendable.
@MainActor
public protocol FCLDelegate: Sendable {
	func showLoading()
	func hideLoading()
	func presentationAnchor() -> ASPresentationAnchor
}

public extension FCLDelegate {
	func presentationAnchor() -> ASPresentationAnchor {
		ASPresentationAnchor()
	}
}

