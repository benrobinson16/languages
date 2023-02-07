import Foundation
import DataStructures

/// Manages file handling for the IntelligentMarking module.
struct FileController {
    /// Reads in a dictionary of recognised articles that can be dropped from answers.
    /// - Returns: The dictionary of articles by language.
    func loadArticles() throws -> [String: [String]] {
        return try loadJsonFile(name: "articles")
    }
    
    /// Reads in a dictionary of adjacency lists for the standard QWERTY keyboard.
    /// - Returns: A dictionary of character adjacency lists.
    func loadKeyboard() throws -> [String: [String]] {
        return try loadJsonFile(name: "keyboard")
    }
    
    private func loadJsonFile<DecodeType: Decodable>(name: String) throws -> DecodeType {
        let url = Bundle.module.url(forResource: name, withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(DecodeType.self, from: data)
    }
}
