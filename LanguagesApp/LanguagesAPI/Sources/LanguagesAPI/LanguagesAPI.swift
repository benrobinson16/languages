import Foundation

public struct LanguagesAPI {
    public init() { }
    
    public func makeRequest<Response: Decodable>(_ request: Request<Response>) async throws -> Response {
        let urlRequest = try request.makeUrlRequest()
        let response = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(Response.self, from: response.0)
    }
}
