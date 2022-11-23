/// Implementation of a noisy queue which has probability noiseFactor of popping the item from each position.
public class NoisyQueue<T>: Queueing {
    private let list: LinkedList<T>
    private let noiseFactor: Double
    
    /// Creates a new, empty noisy queue.
    /// - Parameter noiseFactor: The probability of removing each item.
    public init(noiseFactor: Double = 0.5) {
        self.list = LinkedList<T>()
        self.noiseFactor = noiseFactor
    }
    
    /// Creates a new noisy queue, directly accessing the provided list.
    /// - Parameters:
    ///   - list: The ``LinkedList`` of elements to include in the queue. The queue will directly manipulate this list by reference.
    ///   - noiseFactor: The probability of removing each item.
    public init(_ list: LinkedList<T>, noiseFactor: Double = 0.5) {
        self.list = list
        self.noiseFactor = noiseFactor
    }
    
    /// Creates a new noisy queue, copying in the elements of an array.
    /// - Parameters:
    ///   - array: The array of elements to add to the list.
    ///   - noiseFactor: The probability of removing each item.
    public init(_ array: [T], noiseFactor: Double = 0.5) {
        self.list = LinkedList<T>(array: array)
        self.noiseFactor = noiseFactor
    }
    
    /// Adds a value to the end of the noisy queue.
    /// - Parameter value: The item to append.
    public func enqueue(_ value: T) {
        list.append(value)
    }
    
    
    /// Removes a value from the queue.
    ///
    /// The first element is removed with propability `p + p^n` where `n` is the number of elements (``count``) and `p` is the `noiseFactor`.
    /// Each element at position n is removed with probability `p^n`, where `p` is the `noiseFactor`.
    ///
    /// - Returns: The value that is removed. May be null if there are no elements in the queue.
    public func dequeue() -> T? {
        var index = 0
        let maxIndex = list.count - 1
        
        while index <= maxIndex {
            // With probability noiseFactor, remove the current
            // element of the queue.
            if Double.random(in: 0...1) <= noiseFactor {
                return list.remove(atPosition: index)
            }
            index += 1
        }
        
        // In the case where none of the items have been removed,
        // return and remove the very first item like normal.
        return list.popFirst()
    }
    
    /// The number of elements in the queue.
    public var count: Int {
        return list.count
    }
    
    /// Whether or not the queue is empty. Equivalent to `queue.count == 0` but is more efficient.
    public var isEmpty: Bool {
        return list.isEmpty
    }
    
    public var values: LinkedList<Value> {
        return list.copy()
    }
}
