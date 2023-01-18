import Foundation

import Foundation

public class TreeNode<T>: Equatable, Identifiable {
    
    // MARK: - Properties
    
    public let id = UUID()
    public var value: T
    public private(set) var children = LinkedList<TreeNode<T>>()
    public private(set) var parent: TreeNode<T>?
    
    // MARK: - Initializers
    
    public init(_ value: T, parent: TreeNode<T>?) {
        self.value = value
        self.parent = parent
    }
    
    // MARK: - Meta info
    
    public func size() -> Int {
        return 1 + children.map { $0.size() }.reduce(initial: 0, nextPartialResult: +)
    }
    
    public func maxDepth() -> Int {
        return 1 + (children.map { $0.maxDepth() }.max() ?? 0)
    }
    
    // MARK: - Search
    
    // Chose to implement dfs and bfs separately to the traversal functions because
    // these functions exit as soon as a matching node is found instead of generating
    // an array of all nodes and then checking that.
    
    public func dfs(predicate: (T) -> Bool) -> TreeNode<T>? {
        if predicate(value) {
            return self
        }
        
        return children.reduce(initial: nil) { child, _ in
            if let result = child.dfs(predicate: predicate) {
                return result
            }
            return nil
        }
    }
    
    public func bfs(predicate: (T) -> Bool) -> TreeNode<T>? {
        let queue = LinkedList<TreeNode<T>>(array: [self])
        
        while let node = queue.popFirst() {
            if predicate(node.value) {
                return node
            }
            
            for child in node.children {
                queue.append(child)
            }
        }
        
        return nil
    }
    
    // MARK: - Leaves
    
    public func leftLeaf() -> TreeNode<T>? {
        return children.peekFirst()
    }
    
    public func rightLeaf() -> TreeNode<T>? {
        return children.peekLast()
    }
    
    public func leftmostLeaf() -> TreeNode<T> {
        if let node = children.peekFirst() {
            return node.leftmostLeaf()
        }
        return self
    }
    
    public func rightmostLeaf() -> TreeNode<T> {
        if let node = children.peekLast() {
            return node.rightmostLeaf()
        }
        return self
    }
    
    // MARK: - Parent
    
    public func rootNode() -> TreeNode<T> {
        var currentNode = self
        
        while let parent = currentNode.parent {
            currentNode = parent
        }
        
        return currentNode
    }
    
    public func findParent(where condition: (T) -> Bool) -> TreeNode<T>? {
        var currentNode = self
        
        while !condition(currentNode.value) {
            if let parent = currentNode.parent {
                currentNode = parent
            } else {
                return nil
            }
        }
        
        return currentNode
    }
    
    public func parentOrCreateParent(_ value: T) -> TreeNode<T> {
        if let parent = parent {
            return parent
        }
        
        return insertAbove(value)
    }
    
    // MARK: - Removal
    
    public func removeNode() {
        if parent == nil {
            fatalError("Cannot remove root node from tree.")
        }
        
        parent?.children = children
    }
    
    public func removeNodeAndChildren() {
        if parent == nil {
            fatalError("Cannot remove root node from tree.")
        }
        
        parent?.children = LinkedList<TreeNode<T>>()
    }
    
    // MARK: - Insertion
    
    @discardableResult
    public func insertChildRight(_ value: T) -> TreeNode<T> {
        let newNode = TreeNode(value, parent: self)
        children.append(newNode)
        return newNode
    }
    
    @discardableResult
    public func insertChild(_ value: T, index: Int) -> TreeNode<T> {
        let newNode = TreeNode(value, parent: self)
        children.insert(newNode, atPosition: index)
        return newNode
    }
    
    @discardableResult
    public func insertChildLeft(_ value: T) -> TreeNode<T> {
        let newNode = TreeNode(value, parent: self)
        children.prepend(newNode)
        return newNode
    }
    
    @discardableResult
    public func insertAbove(_ value: T) -> TreeNode<T> {
        let newNode = TreeNode<T>(value, parent: parent)
        newNode.children.append(self)
        
        parent?.children.replaceWhere(newValue: newNode) { $0 == self }
        self.parent = newNode
        
        return newNode
    }
    
    // MARK: - Traversals
    
    public func preorderTraversal() -> [TreeNode<T>] {
        return [self] + children.flatMap { $0.preorderTraversal() }.toArray()
    }
    
    public func postorderTraversal() -> [TreeNode<T>] {
        return children.flatMap { $0.preorderTraversal() }.toArray() + [self]
    }
    
    public func levelOrderTraversal() -> [TreeNode<T>] {
        let queue = LinkedList<TreeNode<T>>(array: [self])
        let output = LinkedList<TreeNode<T>>()
        
        while let node = queue.popFirst() {
            output.append(node)
            
            for child in node.children {
                queue.append(child)
            }
        }
        
        return output.toArray()
    }
    
    // MARK: - Equatable conformance
    
    public static func == (lhs: TreeNode<T>, rhs: TreeNode<T>) -> Bool {
        return lhs.id == rhs.id
    }
}

extension TreeNode where T: Equatable {
    public func dfs(for target: T) -> TreeNode<T>? {
        return dfs { $0 == target }
    }
    
    public func bfs(for target: T) -> TreeNode<T>? {
        return bfs { $0 == target }
    }
    
    public func findParent(_ value: T) -> TreeNode<T>? {
        return findParent { $0 == value }
    }
    
    public func parentEqualsOrCreateParent(_ value: T) -> TreeNode<T> {
        if let parent = parent, parent.value == value {
            return parent
        }
        
        return insertAbove(value)
    }
}
