import Foundation

/// Represents a network of queues that feed into each other.
public class LeitnerQueueNetwork<T> {
    let queues: LinkedList<Queue<T>>
    
    /// Creates a new queue network with the provided list of queues.
    /// - Parameter queues: The queues to use.
    public init(queues: LinkedList<Queue<T>>) {
        self.queues = queues
    }
    
    /// Insert a value to the end of the specified queue.
    /// - Parameters:
    ///   - value: The value to insert.
    ///   - queueIndex: The queue index to insert the value into.
    public func enqueue(_ value: T, intoQueue queueIndex: Int = 0) {
        queues[queueIndex].enqueue(value)
    }
    
    /// Remove a value from the front of a random queue.
    /// - Returns: The value. `nil` if the queue network was empty.
    public func dequeueRandomQueue() -> (value: T, queue: Int)? {
        let indices = Array(0..<queues.count).filter { !queues[$0].isEmpty }
        guard let index = indices.randomElement() else { return nil }
        return dequeue(fromQueue: index)
    }
    
    /// Remove a value from the fornt of the specified queue.
    /// - Parameter queueIndex: The index of the queue to dequeue from.
    /// - Returns: The value and queue removed from. `nil` if the queue is empty.
    public func dequeue(fromQueue queueIndex: Int) -> (value: T, queue: Int)? {
        guard let value = queues[queueIndex].dequeue() else { return nil }
        return (value, queueIndex)
    }
    
    /// Enqueues the contents of a sequence into the specified queue index.
    /// - Parameters:
    ///   - values: The values to insert (in order).
    ///   - queue: The queue to insert them into.
    public func enqueue(values: some Sequence<T>, queue: Int = 0) {
        for v in values {
            enqueue(v, intoQueue: queue)
        }
    }
    
    /// Is the entire queue network empty?
    public var isEmpty: Bool {
        return queues.allSatisfy { $0.isEmpty }
    }
    
    /// The total count from all queues in the network.
    public var count: Int {
        return queues.reduce(initial: 0) { $0.count + $1 }
    }
}
