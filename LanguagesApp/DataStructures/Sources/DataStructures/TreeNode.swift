import Foundation

/// Represents a node in a tree, storing a value and references to children and parent nodes.
public class TreeNode<T>: Equatable, Identifiable {
    
    // MARK: - Properties
    
    public let id = UUID()
    public var value: T
    public private(set) var children = LinkedList<TreeNode<T>>()
    public private(set) var parent: TreeNode<T>?
    
    // MARK: - Initializers
    
    /// Creates a new tree node.
    /// - Parameters:
    ///   - value: The value to store.
    ///   - parent: The parent (if any).
    public init(_ value: T, parent: TreeNode<T>?) {
        self.value = value
        self.parent = parent
    }
    
    // MARK: - Meta info
    
    /// Gets the size of the tree (number of nodes) from here down.
    /// - Returns: The size of the tree.
    public func size() -> Int {
        return 1 + children.map { $0.size() }.reduce(initial: 0, nextPartialResult: +)
    }
    
    /// Gets the maximum depth of the tree (number of generations) from here down.
    /// - Returns: The max depth.
    public func maxDepth() -> Int {
        return 1 + (children.map { $0.maxDepth() }.max() ?? 0)
    }
    
    // MARK: - Search
    
    // Chose to implement dfs and bfs separately to the traversal functions because
    // these functions exit as soon as a matching node is found instead of generating
    // an array of all nodes and then checking that.
    
    /// Performs a depth-first search on the tree.
    /// - Parameter predicate: A function testing if the target node has been found.
    /// - Returns: The target node (if found).
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
    
    /// Performs a breadth-first search on the tree.
    /// - Parameter predicate: A function testing if the target node has been found.
    /// - Returns: The target node (if found).
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
    
    /// Gets the left child of this node.
    /// - Returns: The left child (if any).
    public func leftLeaf() -> TreeNode<T>? {
        return children.peekFirst()
    }
    
    /// Gets the right child of this node.
    /// - Returns: The right child (if any).
    public func rightLeaf() -> TreeNode<T>? {
        return children.peekLast()
    }
    
    /// Gets the leftmost leaf from this node, by recursively finding the leaftmost leaf of each left child.
    /// - Returns: The leftmost leaf, or self.
    public func leftmostLeaf() -> TreeNode<T> {
        if let node = children.peekFirst() {
            return node.leftmostLeaf()
        }
        return self
    }
    
    /// Gets the rightmost leaf from this node, by recursively finding the rightmost leaf of each right child.
    /// - Returns: The rightmost leaf, or self.
    public func rightmostLeaf() -> TreeNode<T> {
        if let node = children.peekLast() {
            return node.rightmostLeaf()
        }
        return self
    }
    
    // MARK: - Parent
    
    /// Gets the highest level parent (root).
    /// - Returns: The root node, or self.
    public func rootNode() -> TreeNode<T> {
        var currentNode = self
        
        while let parent = currentNode.parent {
            currentNode = parent
        }
        
        return currentNode
    }
    
    /// Finds the first parent above this node where the condition holds.
    /// - Parameter condition: A predicate for checking if the target parent has been found.
    /// - Returns: The matching parent node, or `nil`.
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
    
    /// Checks if this node has a parent and inserts a parent if not.
    /// - Parameter value: The value to assign to the parent, if created.
    /// - Returns: A parent node.
    public func parentOrCreateParent(_ value: T) -> TreeNode<T> {
        if let parent = parent {
            return parent
        }
        
        return insertAbove(value)
    }
    
    // MARK: - Removal
    
    /// Remove self from the tree.
    public func removeNode() {
        if parent == nil {
            fatalError("Cannot remove root node from tree.")
        }
        
        parent?.children = children
    }
    
    /// Remove entire subtree from the tree.
    public func removeNodeAndChildren() {
        if parent == nil {
            fatalError("Cannot remove root node from tree.")
        }
        
        parent?.children = LinkedList<TreeNode<T>>()
    }
    
    // MARK: - Insertion
    
    /// Adds a child with the provided value to the right.
    /// - Parameter value: The value for the child node.
    /// - Returns: The new child node.
    @discardableResult
    public func insertChildRight(_ value: T) -> TreeNode<T> {
        let newNode = TreeNode(value, parent: self)
        children.append(newNode)
        return newNode
    }
    
    /// Adds a child with the provided value.
    /// - Parameters:
    ///   - value: The value for the child node.
    ///   - index: The index of the child node (from the left).
    /// - Returns: The new child node.
    @discardableResult
    public func insertChild(_ value: T, index: Int) -> TreeNode<T> {
        let newNode = TreeNode(value, parent: self)
        children.insert(newNode, atPosition: index)
        return newNode
    }
    
    /// Adds a child with the provided value to the left.
    /// - Parameter value: The value for the child node.
    /// - Returns: The new child node.
    @discardableResult
    public func insertChildLeft(_ value: T) -> TreeNode<T> {
        let newNode = TreeNode(value, parent: self)
        children.prepend(newNode)
        return newNode
    }
    
    /// Adds a parent node above this one before any higher-up parents.
    /// - Parameter value: The value of the new node.
    /// - Returns: The new node.
    @discardableResult
    public func insertAbove(_ value: T) -> TreeNode<T> {
        let newNode = TreeNode<T>(value, parent: parent)
        newNode.children.append(self)
        
        parent?.children.replaceWhere(newValue: newNode) { $0 == self }
        self.parent = newNode
        
        return newNode
    }
    
    // MARK: - Traversals
    
    /// Conducts a pre-order traversal.
    /// - Returns: An array in pre-order traversal order.
    public func preorderTraversal() -> [TreeNode<T>] {
        return [self] + children.flatMap { $0.preorderTraversal() }.toArray()
    }
    
    /// Conducts a post-order traversal.
    /// - Returns: An array in post-order traversal order.
    public func postorderTraversal() -> [TreeNode<T>] {
        return children.flatMap { $0.preorderTraversal() }.toArray() + [self]
    }
    
    /// Conducts a level-order traversal.
    /// - Returns: An array in level-order traversal order.
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
