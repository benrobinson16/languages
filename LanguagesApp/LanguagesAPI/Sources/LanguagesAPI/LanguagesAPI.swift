import Foundation

public struct LanguagesAPI {
    public static func makeRequest<Response: Decodable>(_ request: Request<Response>) async throws -> Response {
        let urlRequest = try request.makeUrlRequest()
        let response = try await URLSession.shared.data(for: urlRequest)
        print(String(data: response.0, encoding: .utf8))
        return try JSONDecoder().decode(Response.self, from: response.0)
    }
}
