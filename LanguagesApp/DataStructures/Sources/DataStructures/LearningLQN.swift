import Foundation

public class LearningLQN<T>: LeitnerQueueNetwork<T> where T: Identifiable {
    private var lastQueue: Int?
    private var lastValue: T.ID?
    
    private let targetCards = 15
    private let minCards = 6
    private let insertionProb = 0.5
    
    public override func dequeue(fromQueue queueIndex: Int) -> (value: T, queue: Int)? {
        guard let value = queues[queueIndex].dequeue() else { return nil }
        
        self.lastValue = value.id
        self.lastQueue = queueIndex
        
        return (value, queueIndex)
    }
    
    public func dequeueWithLearningHeuristic() -> (value: T, queue: Int)? {
        let indices = Array(0..<queues.count).filter { !queues[$0].isEmpty }
        let totalCardsBeyondInput = queues.dropFirst(1).reduce(0) { $0 + $1.count }
        
        // If there are unseen cards
        if !queues[0].isEmpty {
            
            // If there aren't enough current cards
            if totalCardsBeyondInput < minCards {
                return dequeue(fromQueue: 0)
            }
            
            // If not at target and last was not insertion
            if totalCardsBeyondInput < targetCards && lastQueue != 0 {
                // ... insert with probability
                let randomVal = Double.random(in: 0...1)
                if randomVal < insertionProb {
                    return dequeue(fromQueue: 0)
                }
            }
        }
        
        var index: Int
        var value: T
        
        // Take a value that was not the previous value
        repeat {
            index = indices.randomElement()!
            value = queues[index].dequeue()!
        } while totalCardsBeyondInput > 1 && value.id == lastValue
        
        return (value, index)
    }
}
