import Foundation
import DataStructures

/// A type that can generate possible answers from a teacher answer.
public protocol AnswerGenerating {
    func generate(answer: String, language: String?) -> [String]
}

/// Generates possible answers from a teacher's answer.
public struct AnswerGenerator: AnswerGenerating {
    private let articles: [String: [String]]
    
    /// Creates a new instance and reads in the lists of recognised articles that can be dropped.
    public init() {
        self.articles = try! FileController().loadArticles()
    }
    
    /// Generate possible student answers.
    /// - Parameters:
    ///   - answer: The reference teacher answer.
    ///   - language: The language (e.g., "fr"/"en").
    /// - Returns: An array of possible student answers.
    public func generate(answer: String, language: String?) -> [String] {
        let ast = produceAST(answer: answer)
        let answersWithArticles = permutationsOfAST(ast: ast)
        let answersWithoutArticles = removePrefixArticles(answersWithArticles, articles: articles[language ?? ""] ?? [])
        return answersWithArticles + answersWithoutArticles
    }
    
    /// Create an abstract syntax tree from a teacher answer.
    /// - Parameter answer: The teacher answer.
    /// - Returns: The root node of the abstract syntax tree.
    private func produceAST(answer: String) -> TreeNode<SyntaxNode> {
        var currentNode = TreeNode<SyntaxNode>(.concatenated, parent: nil)
        
        for c in answer {
            if c == "[" {
                // Opening group
                if currentNode.value.isContent() {
                    currentNode = currentNode.parentOrCreateParent(.concatenated)
                    currentNode = currentNode.insertChildRight(.group)
                } else {
                    currentNode = currentNode.insertChildRight(.group)
                }
            } else if c == "]" {
                // Closing group
                if let optionalParent = currentNode.findParent(.group) {
                    currentNode = optionalParent.parentEqualsOrCreateParent(.concatenated)
                } else if let parent = currentNode.parent, !parent.value.isContent() {
                    currentNode = currentNode.insertChildRight(.content(""))
                    currentNode.value = currentNode.value.appendToContent(c)
                } else {
                    currentNode.value = currentNode.value.appendToContent(c)
                }
            } else if c == "(" {
                // Opening optional
                if currentNode.value == .optional || currentNode.value.isContent() {
                    // Concatenate on the existing node
                    currentNode = currentNode.parentEqualsOrCreateParent(.concatenated)
                    currentNode = currentNode.insertChildRight(.optional)
                } else {
                    currentNode = currentNode.insertChildRight(.optional)
                }
            } else if c == ")" {
                // Closing optional
                if let optionalParent = currentNode.findParent(.optional) {
                    // Find the optional node in the parent line and move up to a concatenated level
                    // above that to concatenate the what comes next to the optional node
                    currentNode = optionalParent.parentEqualsOrCreateParent(.concatenated)
                } else if let parent = currentNode.parent, !parent.value.isContent() {
                    // Treat as a normal content character because optional node not found.
                    // Create new content node.
                    currentNode = currentNode.insertChildRight(.content(""))
                    currentNode.value = currentNode.value.appendToContent(c)
                } else {
                    // Treat as a normal content character because optional node not found.
                    currentNode.value = currentNode.value.appendToContent(c)
                }
            } else if c == " " {
                // Space separated
                if currentNode.parent?.value == .alternatives {
                    // Use a space to break the alternative string and leave the alternatives node
                    currentNode = currentNode.parent!
                    currentNode = currentNode.parentEqualsOrCreateParent(.spaceSeparated)
                } else {
                    currentNode = currentNode.parentEqualsOrCreateParent(.spaceSeparated)
                }
            } else if c == "/" {
                // Move the most recent node into an alternatives node
                if currentNode.parent?.value == .concatenated {
                    currentNode = currentNode.parent!.insertAbove(.alternatives)
                } else {
                    currentNode = currentNode.insertAbove(.alternatives)
                }
            } else if !currentNode.value.isContent() {
                // Create a new content node and append.
                currentNode = currentNode.insertChildRight(.content(""))
                currentNode.value = currentNode.value.appendToContent(c)
            } else {
                // Append the new character.
                currentNode.value = currentNode.value.appendToContent(c)
            }
        }
        
        return currentNode.rootNode()
    }
    
    /// Generate all possible answers given an abstract syntax tree.
    /// - Parameter ast: The abstract syntax tree root node.
    /// - Returns: A list of possible answers.
    private func permutationsOfAST(ast: TreeNode<SyntaxNode>) -> [String] {
        switch ast.value {
        case .group, .concatenated:
            // Use [""] because each string is appended to the previous strings
            var results = [""]
            ast.children.forEach { child in
                let childPermutations = permutationsOfAST(ast: child)
                results = permutations(results, childPermutations) { $0 + $1 }
            }
            return results
            
        case .spaceSeparated:
            // Use [""] because each string is appended to the previous strings (with a space)
            var results = [""]
            ast.children.forEach { child in
                let childPermutations = permutationsOfAST(ast: child)
                
                // Only add the space when it is needed
                results = permutations(results, childPermutations) { ($0.isEmpty || $1.isEmpty) ? $0 + $1 : $0 + " " + $1 }
            }
            return results
            
        case .alternatives:
            var options: [[String]] = []
            ast.children.forEach { child in
                let childPermutations = permutationsOfAST(ast: child)
                options.append(childPermutations)
            }
            
            while options.count > 1 {
                let a = options.remove(at: 0)
                let b = options.remove(at: 0)
                let ab = permutations(a, b) { $0 + (!$0.isEmpty && !$1.isEmpty ? "/" : "") + $1 }
                let ba = permutations(b, a) { $0 + (!$0.isEmpty && !$1.isEmpty ? "/" : "") + $1 }
                
                options.append(a + b + ab + ba)
            }
            
            return options[0]
            
        case .optional:
            var results: [String] = []
            ast.children.forEach { child in
                let childPermutations = permutationsOfAST(ast: child)
                results.append(contentsOf: childPermutations)
            }
            
            results.forEach {
                results.append("(" + $0 + ")")
            }
            results.append("")
            
            return results
            
        case .content:
            return [ast.value.contentValue()]
        }
    }
    
    /// Removes leading articles from answers.
    /// - Parameters:
    ///   - answers: The answers.
    ///   - articles: Articles to drop.
    /// - Returns: Answers with articles dropped.
    private func removePrefixArticles(_ answers: [String], articles: [String]) -> [String] {
        return answers.flatMap { answer in
            return articles
                .filter { answer.hasPrefix($0) }
                .map { String(answer.dropFirst($0.count)) }
        }
    }
    
    /// Helper function to operate on all possible pairings from two arrays.
    /// - Parameters:
    ///   - arr1: The first array.
    ///   - arr2: The second array.
    ///   - combine: A function to call for each pairing, returning a value.
    /// - Returns: An array of output values.
    private func permutations(_ arr1: [String], _ arr2: [String], combine: (String, String) -> String) -> [String] {
        return arr1.flatMap { a in
            return arr2.map { b in
                combine(a, b)
            }
        }
    }
}
