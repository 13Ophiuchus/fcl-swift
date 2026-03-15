	//
	//  AnyEncodable.swift
	//

import Foundation

	/// Type-erased Encodable used for generic payloads (e.g. Authn/Authz bodies).
public struct AnyEncodable: Encodable {
	private let encodeFunc: (Encoder) throws -> Void

	public init<T: Encodable>(_ value: T) {
		self.encodeFunc = value.encode
	}

	public func encode(to encoder: Encoder) throws {
		try encodeFunc(encoder)
	}
}
