import Foundation

/// Provides file handling operations for the app.
class FileController: ObservableObject {
    init() { }
    
    /// Reads a list of ways to say hello.
    /// - Returns: A list of hellos, `nil` if an error was encountered.
    func readHellos() -> [String]? {
        var hellos: [String]? = nil
        
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
}
