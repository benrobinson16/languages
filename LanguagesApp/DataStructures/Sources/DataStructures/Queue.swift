/// A queue abstraction using a ``LinkedList`` implementation.
public class Queue<T>: Queueing {
    internal let list: LinkedList<T>
    
    /// Creates a new, empty queue.
    public init() {
        self.list = LinkedList<T>()
    }
    
    /// Creates a new queue, directly accessing the provided list.
    /// - Parameter list: The ``LinkedList`` of elements to include in the queue. The queue will directly manipulate this list by reference.
    public init(_ list: LinkedList<T>) {
        self.list = list
    }
    
    /// Creates a new queue, copying in the elements of an array.
    /// - Parameter array: The array of elements to add to the list.
    public init(_ array: [T]) {
        self.list = LinkedList<T>(array: array)
    }
    
    /// Adds an element to the queue.
    /// - Parameter value: The element to add to the end of the queue.
    public func enqueue(_ value: T) {
        list.append(value)
    }
    
    /// Removes the front element in the queue.
    /// - Returns: The value that is removed. May be null if there are no elements in the queue (``isEmpty``).
    public func dequeue() -> T? {
        return list.popFirst()
    }
    
    public func clear() {
        list.clear()
    }
    
    /// The number of elements in the queue.
    public var count: Int {
        return list.count
    }
    
    /// Indicates if the number of elements is 0.
    public var isEmpty: Bool {
        return list.isEmpty
    }
}

