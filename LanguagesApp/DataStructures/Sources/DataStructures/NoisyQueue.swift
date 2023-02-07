/// A subclass of ``Queue`` which provides random dequeue behaviour.
public class NoisyQueue<T>: Queue<T> {
    private let noiseFactor: Double
    
    /// Creates a new empty noisy queue with the provided noise factor.
    /// - Parameter noiseFactor: The chance of dequeueing the next element instead of the current one.
    public init(noiseFactor: Double = 0.5) {
        self.noiseFactor = noiseFactor
        
        super.init()
    }
    
    /// Creates a new noisy queue using the provided linked list.
    /// - Parameters:
    ///   - list: The list to use as underlying storage for the queue.
    ///   - noiseFactor: The chance of dequeueing the next element instead of the current one.
    public init(_ list: LinkedList<T>, noiseFactor: Double = 0.5) {
        self.noiseFactor = noiseFactor
        
        super.init(list)
    }
    
    /// Creates a new noisy queue using the values from the provided array.
    /// - Parameters:
    ///   - array: The values to use initially in the queue.
    ///   - noiseFactor: The chance of dequeueing the next element instead of the current one.
    public init(_ array: [T], noiseFactor: Double = 0.5) {
        self.noiseFactor = noiseFactor
        
        super.init(array)
    }
    
    /// Dequeues elements with a probability of instead moving to the next element.
    /// - Returns: The dequeued element. `nil` if the queue is empty.
    public override func dequeue() -> T? {
        var index = 0
        let maxIndex = list.count - 1
        
        while index <= maxIndex {
            // With probability noiseFactor, remove the current
            // element of the queue.
            if Double.random(in: 0...1) >= noiseFactor {
                return list.remove(atPosition: index)
            }
            index += 1
        }
        
        // In the case where none of the items have been removed,
        // return and remove the very first item like normal.
        return list.popFirst()
    }
}
