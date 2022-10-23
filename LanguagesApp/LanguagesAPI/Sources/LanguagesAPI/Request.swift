import Foundation

public struct Request<Response> where Response: Decodable {
    private let method: HttpMethod
    private let url: URL
    private let headers: [String: String]
    private let data: [String: String]
    
    init(method: HttpMethod, url: URL, headers: [String : String], data: [String : String]) {
        self.method = method
        self.url = url
        self.headers = headers
        self.data = data
    }
    
    func makeUrlRequest() throws -> URLRequest {
        var request = URLRequest(url: url)
        
        switch method {
        case .get:
            let qryItems = data.map { URLQueryItem(name: $0.key, value: $0.value) }
            let fullUrl = url.appending(queryItems: qryItems)
            request = URLRequest(url: fullUrl)
            
        case .post, .patch, .delete:
            let encodedData = try JSONEncoder().encode(data)
            request.httpBody = encodedData
        }
        
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
    }
}