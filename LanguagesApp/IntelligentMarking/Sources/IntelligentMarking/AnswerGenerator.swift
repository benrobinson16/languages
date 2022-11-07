import Foundation
import DataStructures

public protocol AnswerGenerating {
    func generate(answer: String) -> [String]
}

public struct AnswerGenerator: AnswerGenerating {
    private let articles: [String]
    
    public init(articles: [String]) {
        self.articles = articles
    }
    
    public func generate(answer: String) -> [String] {
        let ast = produceAST(answer: answer)
        let answersWithArticles = permutationsOfAST(ast: ast)
        let answersWithoutArticles = removePrefixArticles(answersWithArticles, articles: articles)
        return answersWithArticles + answersWithoutArticles
    }
    
    private func produceAST(answer: String) -> TreeNode<SyntaxNode> {
        var currentNode = TreeNode<SyntaxNode>(.concatenated, parent: nil)
        
        for c in answer {
            if c == "(" {
                if currentNode.value == .optional || currentNode.value.isContent() {
                    // Concatenate on the existing node
                    currentNode = currentNode.parentEqualsOrCreateParent(.concatenated)
                    currentNode = currentNode.insertChildRight(.optional)
                } else {
                    currentNode = currentNode.insertChildRight(.optional)
                }
            } else if c == ")" {
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
                if currentNode.parent?.value == .alternatives {
                    // Use a space to break the alternative string and leave the alternatives node
                    currentNode = currentNode.parent!
                    currentNode = currentNode.parentEqualsOrCreateParent(.spaceSeparated)
                } else {
                    currentNode = currentNode.parentEqualsOrCreateParent(.spaceSeparated)
                }
            } else if c == "/" {
                // Move the most recent node into an alternatives node
                currentNode = currentNode.insertAbove(.alternatives)
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
    
    private func permutationsOfAST(ast: TreeNode<SyntaxNode>) -> [String] {
        switch ast.value {
        case .concatenated:
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
            // Use [] because the entire arrays are added together (not the element strings)
            var results: [String] = []
            ast.children.forEach { child in
                let childPermutations = permutationsOfAST(ast: child)
                results.append(contentsOf: childPermutations)
            }
            return results
            
        case .optional:
            // Use [] because the entire arrays are added together (not the element strings),
            // and one option should be to not provide the optional string
            var results = [""]
            ast.children.forEach { child in
                let childPermutations = permutationsOfAST(ast: child)
                results.append(contentsOf: childPermutations)
            }
            return results
            
        case .content:
            return [ast.value.contentValue()]
        }
    }
    
    private func removePrefixArticles(_ answers: [String], articles: [String]) -> [String] {
        return answers.flatMap { answer in
            articles
                .filter { answer.hasPrefix($0) }
                .map { String(answer.dropFirst($0.count)) }
        }
    }
    
    private func permutations(_ arr1: [String], _ arr2: [String], combine: (String, String) -> String) -> [String] {
        return arr1.flatMap { a in
            arr2.map { b in
                combine(a, b)
            }
        }
    }
}
