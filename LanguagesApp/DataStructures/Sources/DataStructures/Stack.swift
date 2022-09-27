/// A stack abstraction using a ``LinkedList`` implementation.
public class Stack<T> {
    private let list: LinkedList<T>
    
    /// Creates a new, empty stack.
    public init() {
        self.list = LinkedList<T>()
    }
    
    /// Creates a new stack, directly accessing the provided list.
    /// - Parameter list: The ``LinkedList`` of elements to include in the stack. The stack will directly manipulate this list by reference.
    public init(_ list: LinkedList<T>) {
        self.list = list
    }
    
    /// Creates a new stack, copying in the elements of an array.
    /// - Parameter array: The array of elements to add to the list.
    public init(_ array: [T]) {
        self.list = LinkedList<T>(array: array)
    }
    
    /// Adds an element to the stack.
    /// - Parameter value: The value to add to the top of the stack.
    public func push(_ value: T) {
        list.append(value)
    }
    
    /// Removes the top element from the stack.
    /// - Returns: The value that has been removed. May be null if the stack is empty.
    public func pop() -> T? {
        return list.popLast()
    }
    
    /// The number of elements in the stack.
    public var count: Int {
        return list.count
    }
    
    /// Whether or not the stack is empty.
    public var isEmpty: Bool {
        return list.isEmpty
    }
}
