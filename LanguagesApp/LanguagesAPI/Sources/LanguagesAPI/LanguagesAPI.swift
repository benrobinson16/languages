import Foundation

public struct LanguagesAPI {
    public static func makeRequest<Response: Decodable>(_ request: Request<Response>) async throws -> Response {
        let urlRequest = try request.makeUrlRequest()
        let response = try await URLSession.shared.data(for: urlRequest)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Response.self, from: response.0)
    }
}
