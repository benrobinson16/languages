import Foundation

public struct LanguagesAPI {
    public static func makeRequest<Response: Decodable>(_ request: Request<Response>) async throws -> Response {
        let urlRequest = try request.makeUrlRequest()
        
        print("Starting request to \(urlRequest.url?.description ?? "[NO URL]")")
        let response = try await URLSession.shared.data(for: urlRequest)
        print("Received response")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decoded = try decoder.decode(Response.self, from: response.0)
        print(decoded)
        
        return decoded
    }
}
