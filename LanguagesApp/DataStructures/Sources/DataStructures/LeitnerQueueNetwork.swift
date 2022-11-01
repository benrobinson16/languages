import Foundation

public class LeitnerQueueNetwork<T> {
    let queues: LinkedList<any Queueing<T>>
    
    public init(queues: LinkedList<any Queueing<T>>) {
        self.queues = queues
    }
    
    public func enqueue(_ value: T, intoQueue queueIndex: Int = 0) {
        queues[queueIndex].enqueue(value)
    }
    
    public func dequeueRandomQueue() -> (value: T, queue: Int)? {
        let indices = Array(0..<queues.count).filter { !queues[$0].isEmpty }
        guard let index = indices.randomElement() else { return nil }
        return dequeue(fromQueue: index)
    }
    
    public func dequeue(fromQueue queueIndex: Int) -> (value: T, queue: Int)? {
        guard let value = queues[queueIndex].dequeue() else { return nil }
        return (value, queueIndex)
    }
    
    public func enqueue(values: some Sequence<T>, queue: Int = 0) {
        for v in values {
            enqueue(v, intoQueue: queue)
        }
    }
    
    public var isEmpty: Bool {
        return queues.allSatisfy { $0.isEmpty }
    }
}
