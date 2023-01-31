import Foundation

/// Static namespace through which to comminucate with the server.
public struct LanguagesAPI {
    
    /// Starts a new request to the server.
    /// - Parameter request: A ``Request`` instance describing how to make the request and the return type.
    /// - Returns: The response received from the server. Decoded as JSON to the data type specified by the ``Request``.
    public static func makeRequest<Response: Decodable>(_ request: Request<Response>) async throws -> Response {
        let urlRequest = try request.makeUrlRequest()
        
        print("Starting request to \(urlRequest.url?.description ?? "[NO URL]")")
        let response = try await URLSession.shared.data(for: urlRequest)
        print("Received response: " + (String(data: response.0, encoding: .utf8) ?? "[null]"))
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let decoded = try decoder.decode(Response.self, from: response.0)
            print(decoded)
            return decoded
        } catch {
            print(error)
            throw error
        }
    }
}
