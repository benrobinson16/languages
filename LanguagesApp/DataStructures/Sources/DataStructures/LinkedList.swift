import Foundation

fileprivate class Node<T>: Identifiable, Equatable {
    let id = UUID()
    var value: T
    private(set) var next: Node?
    private(set) var last: Node?
    
    init(_ value: T) {
        self.value = value
    }
    
    func length() -> Int {
        return 1 + (next?.length() ?? 0)
    }
    
    func insertAfter(newNode: Node) {
        newNode.next = next
        newNode.last = self
        next = newNode
    }
    
    func insertBefore(newNode: Node) {
        newNode.next = self
        newNode.last = last
        last = newNode
    }
    
    func nodeAtIndex(index: Int) -> Node? {
        if index == 0 { return self }
        return next?.nodeAtIndex(index: index - 1)
    }
    
    func remove() {
        next?.last = last
        last?.next = next
    }
    
    static func == (_ lhs: Node, _ rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
}

/// A doubly-linked list implementation.
public class LinkedList<T>: Sequence {
    private var first: Node<T>?
    private var last: Node<T>?
    
    public init() {
        // nothing
    }
    
    public init(array: [T]) {
        var first: Node<T>?
        var last: Node<T>?
        
        for val in array {
            let node = Node(val)
            
            if first == nil {
                first = node
            }
            
            last?.insertAfter(newNode: node)
            last = node
        }
        
        self.first = first
        self.last = last
    }
    
    // MARK: - Accessing information
    
    public subscript(position: Int) -> T {
        get {
            if let node = first?.nodeAtIndex(index: position) {
                return node.value
            } else {
                fatalError("Index out of bounds.")
            }
        }
        
        set {
            if let node = first?.nodeAtIndex(index: position) {
                node.value = newValue
            }
        }
    }
    
    /// The number of elements in the list.
    public var count: Int {
        guard let first = first else { return 0 }
        return first.length()
    }
    
    /// Whether or not the list contains one or more elements.
    public var isEmpty: Bool {
        return first == nil
    }
    
    /// Accesses the first value in the list without removing it.
    /// - Returns: The first value in the list. `nil` if the list is empty.
    public func peekFirst() -> T? {
        return first?.value
    }
    
    /// Accesses the final value in the list without removing it.
    ///
    /// This method should be preferred to subscripting into the final element (e.g. `myList[myList.count - 1]`)
    /// whenever possible as it has constant run-time. Accessing by subscript will require looping through all elements.
    ///
    /// - Returns: The last value in the list. `nil` if empty.
    public func peekLast() -> T? {
        return last?.value
    }
    
    // MARK: - Adding elements
    
    /// Inserts a provided value into the list.
    ///
    /// The position specified will be the new position of the value. As such, the value currently at that position will be
    /// moved up one, along with all others at later positions.
    ///
    /// Position must be between 1 and the length of the list. (Position may be beyond current end of list by one). Note
    /// that ``append(_:)`` should be preferred when inserting at the very end of the list.
    ///
    /// - Parameters:
    ///   - value: The value to insert.
    ///   - position: The position for this value to be inserted at. Must be a valid index or one more than final index.
    public func insert(_ value: T, atPosition position: Int) {
        let newNode = Node(value)
        if let prevNode = first?.nodeAtIndex(index: position - 1) {
            prevNode.insertAfter(newNode: newNode)
            
            if first?.last != nil {
                first = first?.last
            }
            
            if last?.next != nil {
                last = last?.next
            }
        } else if first == nil && position == 0 {
            first = newNode
            last = newNode
        } else {
            fatalError("Index out of bounds.")
        }
    }
    
    /// Appends a value to the end of the list.
    ///
    /// This should be preferred to ``LinkedList/insert(_:atPosition:)`` whenever possible. Using
    /// `myList.insert("foo", myList.count)` has run-time O(n) whereas `myList.append("foo")`
    /// completes in constant time.
    ///
    /// - Parameter value: The value to append to the list.
    public func append(_ value: T) {
        let newNode = Node(value)
        last?.insertAfter(newNode: newNode)
        last = newNode
        
        if first == nil {
            first = newNode
        }
    }
    
    /// Adds a value to the front of the list.
    /// - Parameter value: The value to add.
    func prepend(_ value: T) {
        let newNode = Node(value)
        first?.insertBefore(newNode: newNode)
        first = newNode
        
        if last == nil {
            last = newNode
        }
    }
    
    // MARK: - Removing elements
    
    /// Removes the value at the specified position.
    /// - Parameter position: The position of the item to remove. Must be a valid index.
    @discardableResult
    public func remove(atPosition position: Int) -> T {
        if let node = first?.nodeAtIndex(index: position) {
            remove(node: node)
            return node.value
        } else {
            fatalError("Index out of bounds.")
        }
    }
    
    private func remove(node: Node<T>) {
        node.remove()
        
        if first == node {
            first = first?.next
        }
        
        if last == node {
            last = node.last
        }
    }
    
    /// Acesses and removes the first element of the list.
    /// - Returns: The (ex) first element of the list, or `nil` if empty.
    public func popFirst() -> T? {
        if let oldFirst = first {
            remove(node: oldFirst)
            return oldFirst.value
        } else {
            return nil
        }
    }
    
    /// Accesses and removes the final element in the list.
    ///
    /// This should be preferred to accessing via subscript and then removing via ``remove(atPosition:)``
    /// whenever possible as it avoids iterating through every element of the list.
    ///
    /// - Returns: The (ex) last element of the list, or `nil` if empty.
    @discardableResult
    public func popLast() -> T? {
        if let oldLast = first {
            remove(node: oldLast)
            return oldLast.value
        } else {
            return nil
        }
    }
    
    public func dropFirst() -> LinkedList<T> {
        let newList = LinkedList<T>()
        newList.first = self.first?.next
        newList.last = self.last
        return newList
    }
    
    public func dropLast() -> LinkedList<T> {
        let newList = LinkedList<T>()
        newList.first = self.first
        newList.last = self.last?.last
        return newList
    }
    
    public func clear() {
        first = nil
        last = nil
    }
    
    // MARK: - Higher order functions
    
    /// Removes all elements in the array that
    /// - Parameter condition: A function that determines whether or not to remove the element.
    /// - Returns: The values that were removed.
    @discardableResult
    public func removeWhere(condition: (T) -> Bool) -> [T] {
        var next = first
        var removedValues: [T] = []
        while let this = next {
            next = this.next
            if condition(this.value) {
                remove(node: this)
                removedValues.append(this.value)
            }
        }
        return removedValues
    }
    
    public func replaceWhere(newValue: T, condition: (T) -> Bool) {
        var next = first
        while let this = next {
            next = this.next
            if condition(this.value) {
                this.value = newValue
            }
        }
    }
    
    public func filter(condition: (T) -> Bool) -> LinkedList<T> {
        let outputList = LinkedList<T>()
        self.forEach { value in
            if condition(value) {
                outputList.append(value)
            }
        }
        return outputList
    }
    
    public func forEach(perform: (T) -> Void) {
        var next = first
        while let this = next {
            next = this.next
            perform(this.value)
        }
    }
    
    public func map<X>(transform: (T) -> X) -> LinkedList<X> {
        let outputList = LinkedList<X>()
        self.forEach { outputList.append(transform($0)) }
        return outputList
    }
    
    public func copy() -> LinkedList<T> {
        return self.map { $0 }
    }
    
    public func flatMap<X>(transform: (T) -> some Sequence<X>) -> LinkedList<X> {
        let outputList = LinkedList<X>()
        for t in self {
            transform(t).forEach { x in
                outputList.append(x)
            }
        }
        return outputList
    }
    
    public func reduce<X>(initial: X, nextPartialResult: (T, X) -> X) -> X {
        var output = initial
        self.forEach { output = nextPartialResult($0, output) }
        return output
    }
    
    public func enumerated() -> LinkedList<(index: Int, value: T)> {
        var i = -1
        return self.map { value in
            i += 1
            return (index: i, value: value)
        }
    }
    
    public func randomElement() -> T? {
        let index = Int.random(in: 0..<self.count)
        return first?.nodeAtIndex(index: index)?.value
    }
    
    public func toArray() -> [T] {
        var next = first
        var values: [T] = []
        while let this = next {
            next = this.next
            values.append(this.value)
        }
        return values
    }
    
    // MARK: - Sequence conformance
    
    // This allows the dictionary keys and values to be accessed in a for (k, v) in hashTable syntax.
    
    public func makeIterator() -> LinkedListIterator<T> {
        return LinkedListIterator(startNode: first)
    }
    
    public struct LinkedListIterator<T>: IteratorProtocol {
        public typealias Element = T
        
        fileprivate var currentNode: Node<T>?
        
        fileprivate init(startNode: Node<T>?) {
            self.currentNode = startNode
        }
        
        public mutating func next() -> T? {
            if let currentNode {
                let nextNode = currentNode.next
                self.currentNode = nextNode
                return nextNode?.value
            } else {
                return nil
            }
        }
    }
}

extension LinkedList where T: Equatable {
    /// Removes all elements with the provided value.
    /// - Parameter value: The value to match against and remove.
    public func removeAll(ofValue value: T) {
        removeWhere { $0 == value }
    }
    
    public func contains(_ value: T) -> Bool {
        var didContain = false
        forEach { v in
            if v == value {
                didContain = true
            }
        }
        return didContain
    }
}

extension LinkedList where T: Comparable {
    public func max() -> T? {
        var maxSoFar = first?.value
        self.forEach {
            if maxSoFar == nil || $0 > maxSoFar! {
                maxSoFar = $0
            }
        }
        return maxSoFar
    }
    
    public func min() -> T? {
        var minSoFar = first?.value
        self.forEach {
            if minSoFar == nil || $0 < minSoFar! {
                minSoFar = $0
            }
        }
        return minSoFar
    }
}
