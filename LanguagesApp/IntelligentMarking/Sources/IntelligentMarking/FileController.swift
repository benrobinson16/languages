import Foundation
import DataStructures

struct FileController {
    func loadArticles() throws -> [String: [String]] {
        return try loadJsonFile(name: "articles")
    }
    
    func loadKeyboard() throws -> [String: [String]] {
        return try loadJsonFile(name: "keyboard")
    }
    
    private func loadJsonFile<DecodeType: Decodable>(name: String) throws -> DecodeType {
        let url = Bundle.module.url(forResource: name, withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(DecodeType.self, from: data)
    }
}
