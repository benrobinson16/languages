import Foundation

public struct LanguagesAPI {
    public static func makeRequest<Response: Decodable>(_ request: Request<Response>) async throws -> Response {
        let urlRequest = try request.makeUrlRequest()
        print(urlRequest.url)
        let response = try await URLSession.shared.data(for: urlRequest)
        print(String(data: response.0, encoding: .utf8))
        print(response.1)
        return try JSONDecoder().decode(Response.self, from: response.0)
    }
}
