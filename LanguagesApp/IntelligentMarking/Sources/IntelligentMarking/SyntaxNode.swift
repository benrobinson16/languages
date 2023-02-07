import Foundation

/// Represents a node in the abstract syntax tree of teacher answers.
enum SyntaxNode: Equatable {
    case group
    case concatenated
    case spaceSeparated
    case alternatives
    case optional
    case content(String)
    
    /// Checks if the current instance is a content node.
    /// - Returns: Whether the current instance is a content node.
    func isContent() -> Bool {
        if case .content(_) = self {
            return true
        }
        return false
    }
    
    /// Gets the value of the current node. Returns the empty string if not a content node.
    /// - Returns: The value of the current node.
    func contentValue() -> String {
        if case .content(let string) = self {
            return string
        }
        return ""
    }
    
    /// Appends a character to the node's value.
    /// - Parameter c: The new character to add.
    /// - Returns: The new node with the additional character.
    func appendToContent(_ c: Character) -> SyntaxNode {
        if case .content(let string) = self {
            return .content(string.appending(String(c)))
        }
        return .content(String(c))
    }
}
