import Foundation

enum SyntaxNode: Equatable {
    case group
    case concatenated
    case spaceSeparated
    case alternatives
    case optional
    case content(String)
    
    func isContent() -> Bool {
        if case .content(_) = self {
            return true
        }
        return false
    }
    
    func contentValue() -> String {
        if case .content(let string) = self {
            return string
        }
        return ""
    }
    
    func appendToContent(_ c: Character) -> SyntaxNode {
        if case .content(let string) = self {
            return .content(string.appending(String(c)))
        }
        return .content(String(c))
    }
}
