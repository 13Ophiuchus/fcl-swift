import Flow
import Foundation

extension FCL {
	public struct Strategy:  Sendable {
		let fcl: FCL
		let services: [Service]

		init(fcl: FCL, services: [Service]) {
			self.fcl = fcl
			self.services = services
		}

		func execService(service: Service, request: Encodable) async throws -> Response {
				// If you actually want the *passed* service, keep this guard:
				// guard let service = await fcl.serviceOfType(services: services, type: .userSignature) else {
				//     throw FCLError.invaildService
				// }

			guard let service = await fcl.serviceOfType(
				services: services,
				type: .userSignature
			) else {
				throw FCLError.invaildService
			}

			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted

			guard let data = try? encoder.encode(request) else {
				throw FCLError.encodeFailure
			}

			guard let json = String(data: data, encoding: .utf8) else {
				throw FCLError.encodeFailure
			}

				// Make sure this is FCL.Service (the one extended with exec(json:))
			let response = try await fcl.config.service.exec(json: json, service: service)
			return response
		}
	}


}
