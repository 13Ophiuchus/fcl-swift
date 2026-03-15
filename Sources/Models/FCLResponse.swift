	//
	//  FCLResponse.swift
	//

import Foundation
import Flow

	// MARK: - Service enums

public extension FCL {

	enum ServiceType: String, Codable, Sendable {
		case authn
		case authz
		case preAuthz
		case userSignature
		case unknown
	}

	enum ServiceMethod: String, Codable, Sendable {
		case httpPost = "HTTP/POST"
		case httpGet  = "HTTP/GET"
		case walletConnect = "WC/RPC"
	}
}

// MARK: - Response and related models

public extension FCL {

	struct Response: Codable, Sendable {
		public let fType: String?
		public let fVsn: String?
		public let status: Status?
		public let reason: String?
		public let  data: DataPayload?

		public enum Status: String, Codable, Sendable {
			case approved
			case declined
			case pending
		}

		public struct DataPayload: Codable, Sendable {
			public let addr: String?
			public let keyId: Int?
			public let nonce: String?
			public let services: [Service]?
			public let compositeSignature: CompositeSignature?
			public let authorizationUpdates: [Service]?
			public let payer: [Service]?
			public let proposer: Service?
			public let authorization: [Service]?
			public let signatures: [CompositeSignature]?
		}
	}

	struct Service: Codable, Sendable {
		public var fType: String?
		public var fVsn: String?
		public var type: FCL.ServiceType?
		public var method: FCL.ServiceMethod?
		public var endpoint: URL?
		public var identity: Identity?
		public var data: [String: String]?

		public init(
		fType: String? = nil,
		fVsn: String? = nil,
		type: FCL.ServiceType? = nil,
		method: FCL.ServiceMethod? = nil,
		endpoint: URL? = nil,
		identity: Identity? = nil,
		data: [String: String]? = nil
		) {
			self.fType = fType
			self.fVsn = fVsn
			self.type = type
			self.method = method
			self.endpoint = endpoint
			self.identity = identity
			self.data = data
		}
	}

	struct Identity: Codable, @unchecked Sendable {
		public var address: Flow.Address?
		public var keyId: Int?
		public var issuer: String?
		public var profile: String?
	}

	struct CompositeSignature: Codable, Sendable {
		public let fType: String?
		public let fVsn: String?
		public let addr: String?
		public let keyId: Int?
		public let signature: String?
	}
}

// MARK: - Custom Codable for FCL.Service

public extension FCL.Service {

	enum CodingKeys: String, CodingKey, Sendable {
		case fType
		case fVsn
		case type
		case method
		case endpoint
		case identity
		case data
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		fType = try container.decodeIfPresent(String.self, forKey: .fType)
		fVsn = try container.decodeIfPresent(String.self, forKey: .fVsn)

		if let typeRaw = try container.decodeIfPresent(String.self, forKey: .type) {
			type = FCL.ServiceType(rawValue: typeRaw) ?? .unknown
		} else {
			type = nil
		}

		if let methodRaw = try container.decodeIfPresent(String.self, forKey: .method) {
			method = FCL.ServiceMethod(rawValue: methodRaw)
		} else {
			method = nil
		}

		if let endpointString = try container.decodeIfPresent(String.self, forKey: .endpoint) {
			endpoint = URL(string: endpointString)
		} else {
			endpoint = nil
		}

		identity = try container.decodeIfPresent(FCL.Identity.self, forKey: .identity)
		data = try container.decodeIfPresent([String: String].self, forKey: .data)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encodeIfPresent(fType, forKey: .fType)
		try container.encodeIfPresent(fVsn, forKey: .fVsn)
		try container.encodeIfPresent(type?.rawValue, forKey: .type)
		try container.encodeIfPresent(method?.rawValue, forKey: .method)
		try container.encodeIfPresent(endpoint?.absoluteString, forKey: .endpoint)
		try container.encodeIfPresent(identity, forKey: .identity)
		try container.encodeIfPresent(data, forKey: .data)
	}
}
