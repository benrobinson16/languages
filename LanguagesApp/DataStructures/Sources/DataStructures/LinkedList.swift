import Foundation

/// Represents a node in a linked list with references to nodes in front and behind it. Stores a value.
fileprivate class Node<T>: Identifiable, Equatable {
    let id = UUID()
    var value: T
    private(set) var next: Node?
    private(set) var last: Node?
    
    /// Creates a new node.
    /// - Parameter value: The value for the node to store.
    init(_ value: T) {
        self.value = value
    }
    
    /// The length of this node and any nodes later in the sequence.
    /// - Returns: The length of the sequence starting here.
    func length() -> Int {
        return 1 + (next?.length() ?? 0)
    }
    
    /// Inserts a new node after the current one.
    /// - Parameter newNode: The new node.
    func insertAfter(newNode: Node) {
        newNode.next = next
        newNode.last = self
        next = newNode
    }
    
    /// Inserts a new node before the current one.
    /// - Parameter newNode: The new node.
    func insertBefore(newNode: Node) {
        newNode.next = self
        newNode.last = last
        last = newNode
    }
    
    /// Gets the node at the specified offset from the current node.
    /// - Parameter index: The offset to inspect.
    /// - Returns: The node at that offset. `nil` if none.
    func nodeAtIndex(index: Int) -> Node? {
        if index == 0 { return self }
        return next?.nodeAtIndex(index: index - 1)
    }
    
    /// Remove this node from the sequence.
    func remove() {
        next?.last = last
        last?.next = next
    }
    
    /// Compare the nodes by id.
    static func == (_ lhs: Node, _ rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
}

/// A doubly-linked list implementation.
public class LinkedList<T>: Sequence {
    private var first: Node<T>?
    private var last: Node<T>?
    
    /// Creates a new empty linked list.
    public init() {
        // nothing
    }
    
    /// Creates a new linked list, storing the values in the provided array.
    /// - Parameter array: An array of values.
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
    @discardableResult
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
        if let oldLast = last {
            remove(node: oldLast)
            return oldLast.value
        } else {
            return nil
        }
    }
    
    /// Return a new list that omits the first value.
    /// - Returns: The new list.
    public func dropFirst() -> LinkedList<T> {
        let newList = copy()
        newList.popFirst()
        return newList
    }
    
    /// Return a new list that omits the last value.
    /// - Returns: The new list.
    public func dropLast() -> LinkedList<T> {
        let newList = copy()
        newList.popLast()
        return newList
    }
    
    /// Remove all elements from the list.
    public func clear() {
        first = nil
        last = nil
    }
    
    // MARK: - Higher order functions
    
    /// Removes all elements in the array that
    /// - Parameter condition: A function that determines whether or not to remove the element.
    /// - Returns: The values that were removed.
    @discardableResult
    public func removeWhere(condition: (T) -> Bool) -> LinkedList<T> {
        var next = first
        let removedValues = LinkedList<T>()
        while let this = next {
            next = this.next
            if condition(this.value) {
                remove(node: this)
                removedValues.append(this.value)
            }
        }
        return removedValues
    }
    
    /// Replace values meeting the condition with a new value.
    /// - Parameters:
    ///   - newValue: The new value to replace old values with.
    ///   - condition: A predicate for wether a value meets the condition.
    public func replaceWhere(newValue: T, condition: (T) -> Bool) {
        var next = first
        while let this = next {
            next = this.next
            if condition(this.value) {
                this.value = newValue
            }
        }
    }
    
    /// Returns a new linked list that only includes values that meet the condition.
    /// - Parameter condition: A predicate for whether an element should be included or not.
    /// - Returns: A new linked list.
    public func filter(condition: (T) -> Bool) -> LinkedList<T> {
        let outputList = LinkedList<T>()
        self.forEach { value in
            if condition(value) {
                outputList.append(value)
            }
        }
        return outputList
    }
    
    /// Perform a function for each element in the list.
    /// - Parameter perform: The action to carry out.
    public func forEach(perform: (T) -> Void) {
        var next = first
        while let this = next {
            next = this.next
            perform(this.value)
        }
    }
    
    /// Transform each element to a new value and return a new list.
    /// - Parameter transform: A function mapping to new values.
    /// - Returns: A new transformed linked list.
    public func map<X>(transform: (T) -> X) -> LinkedList<X> {
        let outputList = LinkedList<X>()
        self.forEach { outputList.append(transform($0)) }
        return outputList
    }
    
    /// Copy the linked list. This performs a shallow copy, so if the values are reference type, only the references are copied.
    /// - Returns: A new linked list.
    public func copy() -> LinkedList<T> {
        return self.map { $0 }
    }
    
    /// Transform each element into a sequence and return a new linked list formed from all the elements in those sequences.
    /// - Parameter transform: A function mapping from element to a new sequence.
    /// - Returns: A linked list of the flattened transformed values.
    public func flatMap<X>(transform: (T) -> some Sequence<X>) -> LinkedList<X> {
        let outputList = LinkedList<X>()
        self.forEach { t in
            transform(t).forEach { x in
                outputList.append(x)
            }
        }
        return outputList
    }
    
    /// Obtain a result by applying a function to each element in turn.
    /// - Parameters:
    ///   - initial: The initial result.
    ///   - nextPartialResult: A function mapping to the next partial result.
    /// - Returns: The final result.
    public func reduce<X>(initial: X, nextPartialResult: (T, X) -> X) -> X {
        var output = initial
        self.forEach { output = nextPartialResult($0, output) }
        return output
    }
    
    /// Gets a linked list of indices and their corresponding values.
    /// - Returns: A linked list of indices and values.
    public func enumerated() -> LinkedList<(index: Int, value: T)> {
        var i = -1
        return self.map { value in
            i += 1
            return (index: i, value: value)
        }
    }
    
    /// Gets a random element from the list.
    /// - Returns: A random element. `nil` if the list is empty.
    public func randomElement() -> T? {
        guard !isEmpty else { return nil }
        
        let index = Int.random(in: 0..<self.count)
        return first?.nodeAtIndex(index: index)?.value
    }
    
    /// Remove a random element from the list.
    /// - Returns: A random element. `nil` if the list is empty.
    @discardableResult
    public func removeRandomElement() -> T? {
        guard !isEmpty else { return nil }
        
        let index = Int.random(in: 0..<self.count)
        return remove(atPosition: index)
    }
    
    /// Converts the list to an array for interfacing with external code.
    /// - Returns: An array copy of the list.
    public func toArray() -> [T] {
        var next = first
        var values: [T] = []
        while let this = next {
            next = this.next
            values.append(this.value)
        }
        return values
    }
    
    /// Produce a new shuffled version of the list.
    /// - Returns: A new shuffled list.
    public func shuffled() -> LinkedList<T> {
        let listCopy = self.copy()
        let output = LinkedList<T>()
        
        while !listCopy.isEmpty {
            output.append(listCopy.removeRandomElement()!)
        }
        
        return output
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
                let value = currentNode.value
                self.currentNode = currentNode.next
                return value
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
    
    /// Gets whether the provided value is in the list using the equality operator.
    /// - Parameter value: The target value.
    /// - Returns: Whether the value was found after a linear search.
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
    /// Gets the maximum element in the list.
    /// - Returns: The maximum element. `nil` if the list is empty.
    public func max() -> T? {
        var maxSoFar = first?.value
        self.forEach {
            if maxSoFar == nil || $0 > maxSoFar! {
                maxSoFar = $0
            }
        }
        return maxSoFar
    }
    
    /// Gets the minimum element in the list.
    /// - Returns: The minimum element. `nil` if the list is empty.
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
