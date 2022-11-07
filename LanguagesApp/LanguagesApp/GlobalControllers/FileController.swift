import Foundation

class FileController: ObservableObject {
    @Published private(set) var hellos: [String]? = nil
    @Published private(set) var articles: [String]? = nil
    
    private init() { }
    public static let shared = FileController()
    
    @discardableResult
    func readHellos() -> [String]? {
        if let url = Bundle.main.url(forResource: "hellos", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                hellos = try JSONDecoder().decode([String].self, from: data)
            } catch {
                // Could not read data from file. Do not report an error: hellos.json is purely for
                // UI/decorative purposes so should not alert user to it's failings.
            }
        } else {
            // Could not read data from file. Do not report an error: hellos.json is purely for
            // UI/decorative purposes so should not alert user to it's failings.
        }
        return hellos
    }
    
    @discardableResult
    func readArticles(languageCode: String) -> [String]? {
        if let url = Bundle.main.url(forResource: "articles", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let dict = try JSONDecoder().decode([String: [String]].self, from: data)
                articles = dict[languageCode]
            } catch {
                // Could not read data from file. Do not report an error: hellos.json is purely for
                // UI/decorative purposes so should not alert user to it's failings.
            }
        } else {
            // Could not read data from file. Do not report an error: hellos.json is purely for
            // UI/decorative purposes so should not alert user to it's failings.
        }
        return articles
    }
}
