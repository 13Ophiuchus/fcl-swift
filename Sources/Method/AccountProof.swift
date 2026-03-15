	//
	//  AccountProof.swift
	//
	//  Created by Hao Fu on 25/9/2022.
	//

import Flow
import Foundation

public extension FCL {

	struct AccountProofPayload: Decodable {
		public let addr: String
		public let keyId: Int?
		public let nonce: String
		public let signatures: [CompositeSignature]

		enum CodingKeys: String, CodingKey {
			case addr
			case keyId
			case nonce
			case signatures
		}

		init(from dict: [String: String]) throws {
			guard
				let addr = dict["addr"],
				let nonce = dict["nonce"]
			else {
				throw FCLError.invaildService
			}

			self.addr = addr
			self.nonce = nonce

			if let keyIdString = dict["keyId"], let keyId = Int(keyIdString) {
				self.keyId = keyId
			} else {
				self.keyId = nil
			}

			if let sigsJSON = dict["signatures"],
			   let sigData = sigsJSON.data(using: .utf8) {
				self.signatures = try JSONDecoder().decode([CompositeSignature].self, from: sigData)
			} else {
				self.signatures = []
			}
		}
	}

	func getAccountProof() async throws -> AccountProofPayload {
		guard let currentUser = currentUser, currentUser.loggedIn else {
			throw Flow.FError.unauthenticated
		}

		guard let service = serviceOfType(services: currentUser.services, type: .authn),
			  let data = service.data
		else {
			throw FCLError.invaildService
		}

		return try AccountProofPayload(from: data)
	}

	func verifyAccountProof(includeDomainTag: Bool = false) async throws -> Bool {
		guard let currentUser = currentUser, currentUser.loggedIn else {
			throw Flow.FError.unauthenticated
		}

		guard let service = serviceOfType(services: currentUser.services, type: .authn),
			  let rawData = service.data
		else {
			throw FCLError.invaildService
		}

		let payload = try AccountProofPayload(from: rawData)

		guard let appIdentifier = config.get(.appId) else {
			throw FCLError.invaildService
		}

		guard let encoded = RLP.encode([
			appIdentifier.data(using: .utf8),
			payload.addr.hexValue.data,
			payload.nonce.hexValue.data
		]) else {
			throw FCLError.encodeFailure
		}

		let encodedTag: Data
		if includeDomainTag {
			encodedTag = Flow.DomainTag.custom("FCL-ACCOUNT-PROOF-V0.0").normalize + encoded
		} else {
			encodedTag = encoded
		}

		return try await fcl.query {
			cadence {
				FCL.Constants.verifyAccountProofSignaturesCadence
			}
			arguments {
				[
					.address(Flow.Address(hex: payload.addr)),
					.string(encodedTag.hexValue),
					.array(payload.signatures.compactMap { .int($0.keyId ?? -1) }),
					.array(payload.signatures.compactMap { .string($0.signature ?? "") })
				]
			}
		}.decode()
	}
}
