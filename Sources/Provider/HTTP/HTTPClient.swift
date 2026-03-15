	//
	//  HTTPClient.swift
	//  FCL
	//
	//  Created by lmcmz on 4/10/21.
	//

import Foundation

@MainActor
extension FCL {



	final class HTTPClient: NSObject {

		public weak var delegate: HTTPSessionDelegate?

		internal let defaultUserAgent = "Flow SWIFT SDK"

		enum HTTPMethod: String {
			case get = "GET"
			case post = "POST"
		}

			// MARK: - Core fetch

		func fetchService(
		url: URL,
		method: HTTPMethod = .get,
		params: [String: String]? = [:],
		data: Data? = nil
		) async throws -> FCL.Response {
			let location = await fcl.config.get(.location)
			guard let fullURL = buildURL(url: url, params: params, location: location) else {
				throw FCLError.generic
			}

			var request = URLRequest(url: fullURL)
			request.httpMethod = method.rawValue
			
			if let httpBody = data {
				request.httpBody = httpBody
				request.addValue("application/json", forHTTPHeaderField: "Content-Type")
				request.addValue("application/json", forHTTPHeaderField: "Accept")
			}
			
			if let location {
				request.addValue(location, forHTTPHeaderField: "referer")
			}
			
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			let config = URLSessionConfiguration.default
			
			let (respData, _) = try await URLSession(configuration: config).data(for: request)
			return try decoder.decode(FCL.Response.self, from: respData)
		}
		
			// MARK: - High-level HTTP POST
		
		func execHttpPost(service: Service?,  data: Data? = nil) async throws -> FCL.Response {
			guard let ser = service,
				  let url = ser.endpoint
			else {
				throw FCLError.generic
			}
			
			return try await execHttpPost(
				url: url,
				method: .post,
				params: nil,
				data: data
			)
		}
		
		func execHttpPost(
		url: URL,
		method: HTTPMethod = .post,
		params: [String: String]? = [:],
		data: Data? = nil
		) async throws -> FCL.Response {
			var configData: Data?
			if let baseConfig = try? await BaseConfigRequest().toDictionary() {
				var body: [String: Any]? = [:]
				if let data {
					body = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
				}
				
				let configDict = baseConfig.merging(body ?? [:]) { _, new in new }
				configData = try? JSONSerialization.data(withJSONObject: configDict)
			}
			
			await fcl.delegate?.showLoading()
			
			do {
				let result = try await fetchService(
					url: url,
					method: method,
					params: params,
					data: configData ?? data
				)
				
				await fcl.delegate?.hideLoading()
				
				switch result.status {
					case .approved:
						return result
						
					case .declined:
						return result
						
					case .pending:
						return result
						
					case .none:
						return result
				}
			} catch {

				await delegate?.closeSession()
				await fcl.delegate?.hideLoading()

				throw error
			}
		}
		
			// MARK: - Polling loop
		
	//	@MainActor
		nonisolated func poll(service: Service) async throws -> FCL.Response {
			let stillPending = await delegate?.isPending ?? false
			if !stillPending {
				throw FCLError.declined
			}

			guard let url = service.endpoint else {
				throw FCLError.invaildURL
			}

			let result = try await fetchService(url: url, method: .get, params: nil)

			switch result.status {
				case .approved, .declined:
					await delegate?.closeSession()
					await SafariWebViewManager.closeSafariWebView()
					return result

				case .pending:
					try await Task.sleep(nanoseconds: 1_000_000_000)
					return try await poll(service: service)

				case .none:
					return result
			}
		}

		nonisolated private func sleepAndReenterPoll(service: Service) async throws -> FCL.Response {
			try await Task.sleep(nanoseconds: 1_000_000_000)
			return try await poll(service: service)
		}




	}
}

// Pure function: does NOT touch `fcl`.
internal func buildURL(
url: URL,
params: [String: String]?,
location: String?
) -> URL? {
	let paramLocation = "l6n"
	guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
		return nil
	}
	
	var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
	
	if let location {
		queryItems.append(URLQueryItem(name: paramLocation, value: location))
	}

	for (name, value) in params ?? [:] {
		if name != paramLocation {
			queryItems.append(URLQueryItem(name: name, value: value))
		}
	}

	urlComponents.queryItems = queryItems
	return urlComponents.url
}
