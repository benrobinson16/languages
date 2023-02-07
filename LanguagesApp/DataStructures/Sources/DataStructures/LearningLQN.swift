import Foundation

/// Subclass of ``LeitnerQueueNetwork`` which provides additional domain-specific dequeue operations.
public class LearningLQN<T>: LeitnerQueueNetwork<T> where T: Identifiable {
    private var lastQueue: Int?
    private var lastValue: T.ID?
    
    private let targetCards = 8
    
    /// Redefine empty to mean no cards currently learning.
    public override var isEmpty: Bool {
        return numCardsCurrentlyLearning() == 0
    }
    
    /// Redefine count to mean the number of cards currently learning.
    public override var count: Int {
        return numCardsCurrentlyLearning()
    }
    
    /// Removes an item from a queue.
    /// - Parameter queueIndex: The index of the queue to remove from.
    /// - Returns: The value and queue. `nil` if no value in the queue.
    public override func dequeue(fromQueue queueIndex: Int) -> (value: T, queue: Int)? {
        guard let value = queues[queueIndex].dequeue() else { return nil }
        
        self.lastValue = value.id
        self.lastQueue = queueIndex
        
        return (value, queueIndex)
    }
    
    /// Gets a lists of queues that correspond to the items currently being learnt.
    /// - Returns: A list of currently learning queues.
    private func currentLearningQueues() -> LinkedList<Queue<T>> {
        return queues
            .dropFirst()
            .dropLast()
    }
    
    /// Gets weights for each queue by the number of cards in them.
    /// - Returns: A list of tuples. Each with the queue index and the threshold that must be exceeded (0...1) to be chosen.
    private func queueWeights() -> LinkedList<(queueIndex: Int, threshold: Double)> {
        let totalCards = numCardsCurrentlyLearning()
        var currentThreshold = 0.0
        return queues
            .enumerated()
            .dropFirst()
            .dropLast()
            .map { idx, queue in
                currentThreshold += Double(queue.count) / Double(totalCards)
                return (queueIndex: idx, threshold: currentThreshold)
            }
    }
    
    /// Gets the number of cards in the currently leanring queues (i.e. not completed/not started).
    /// - Returns: The number of cards.
    private func numCardsCurrentlyLearning() -> Int {
        return currentLearningQueues().reduce(0) { $0 + $1.count }
    }
    
    /// Returns the first card found in any queue.
    /// - Returns: The first card encountered.
    private func firstCardFound() -> (value: T, queue: Int)? {
        let queue = queues
            .enumerated()
            .dropFirst()
            .dropLast()
            .filter { !$0.value.isEmpty }[0]
        
        return (value: queue.value.dequeue()!, queue: queue.index)
    }
    
    /// Removes an item from a queue, using a heuristic to successfully manage the learning process.
    /// - Returns: A value and the queue it was removed from. `nil` if no value.
    public func dequeueWithLearningHeuristic() -> (value: T, queue: Int)? {
        // Insert into learning LQN if we aren't at the target number of cards.
        while queues[0].count > 0 && numCardsCurrentlyLearning() < targetCards {
            enqueue(dequeue(fromQueue: 0)!.value, intoQueue: 1)
        }
        
        // Special cases for 0 or 1 cards.
        if numCardsCurrentlyLearning() == 0 {
            return nil
        } else if numCardsCurrentlyLearning() == 1 {
            return firstCardFound()!
        }
        
        let previousId = lastValue
        let weights = queueWeights()
        var chosenCard: T? = nil
        var chosenQueueIndex = 0
        let toReinsert = LinkedList<(value: T, queue: Int)>()
        
        repeat {
            // Choose a queue, weighted by number of cards in each queue.
            let random = Double.random(in: 0...1)
            chosenQueueIndex = weights.first { $0.threshold >= random }?.queueIndex
                ?? weights.filter { $0.threshold != 0 }[0].queueIndex
            chosenCard = dequeue(fromQueue: chosenQueueIndex)?.value
            
            // Avoid choosing the same card as last time
            if let chosen = chosenCard, chosen.id == previousId {
                toReinsert.append((value: chosen, queue: chosenQueueIndex))
                
                chosenCard = nil
                chosenQueueIndex = 0
            }
        } while chosenCard == nil
        
        // Reinsert values removed during selection process.
        for (value, queue) in toReinsert {
            enqueue(value, intoQueue: queue)
        }
        
        return (value: chosenCard!, queue: chosenQueueIndex)
    }
}
