	//
	//  HTTPProvider.swift
	//

import Foundation

public extension FCL {

		/// HTTP JSON RPC provider used for non–WalletConnect flows.
	final class HTTPProvider: FCLStrategy {

		public init() {}

			// MARK: - FCLStrategy

		public func execService(
			service: FCL.Service,
			request: (any Encodable & Sendable)?
		) async throws -> FCL.Response {
			guard let url = service.endpoint else {
				throw FCLError.invaildURL
			}
				// Choose HTTP verb from service.method if needed
			let httpMethod: String
			switch service.method ?? .httpPost {
				case .httpGet:
					httpMethod = "GET"
				case .httpPost, .walletConnect:
					httpMethod = "POST"
			}

			return try await execService(
				url: url,
				method: service.type ?? .unknown,
				request: request,
				httpMethod: httpMethod
			)
		}

		public func execService(
			url: URL,
			method: FCL.ServiceType,
			request: (any Encodable & Sendable)?
		) async throws -> FCL.Response {
				// Default to POST if called directly
			return try await execService(
				url: url,
				method: method,
				request: request,
				httpMethod: "POST"
			)
		}

			// MARK: - Internal request helper

		private func execService(
			url: URL,
			method _: FCL.ServiceType,
			request: (any Encodable & Sendable)?,
			httpMethod: String
		) async throws -> FCL.Response {
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = httpMethod
			urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

			if let request = request {
				let bodyData = try JSONEncoder().encode(AnyEncodable(request))
				if httpMethod == "GET" {
						// If you really need GET with query params, adapt here.
						// For now, we still send body for simplicity.
					urlRequest.httpBody = bodyData
				} else {
					urlRequest.httpBody = bodyData
				}
			}

			let (data, response) = try await URLSession.shared.data(for: urlRequest)

			guard let httpResponse = response as? HTTPURLResponse,
				  (200 ..< 300).contains(httpResponse.statusCode) else {
				throw FCLError.invalidResponse
			}

			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			return try decoder.decode(FCL.Response.self, from: data)
		}
	}
}
