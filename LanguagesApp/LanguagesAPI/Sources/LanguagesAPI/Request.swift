import Foundation

/// Describes an HTTPS request to make to the server. Generic over ``Response`` which is the expected JSON return type.
public struct Request<Response> where Response: Decodable {
    private let method: HttpMethod
    private let url: URL
    private let headers: [String: String]
    private let data: [String: String]
    
    /// Memberwise initialiser.
    /// - Parameters:
    ///   - method: The HTTP method to use (GET, POST, PATCH, DELETE)
    ///   - url: The url and path of the server to access.
    ///   - headers: Header data to include.
    ///   - data: Query parameters to include.
    init(method: HttpMethod, url: URL, headers: [String : String], data: [String : String]) {
        self.method = method
        self.url = url
        self.headers = headers
        self.data = data
    }
    
    /// Creates a system-standard `URLRequest` object from the data in the current instance.
    /// - Returns: A `URLRequest` that can be executed directly using the standard library.
    func makeUrlRequest() throws -> URLRequest {
        let qryItems = data.map { URLQueryItem(name: $0.key, value: $0.value) }
        let fullUrl = url.appending(queryItems: qryItems)
        
        var request = URLRequest(url: fullUrl)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
    
    /// Represents a method of sending an HTTP request.
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }
}
