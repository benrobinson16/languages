import Foundation

public class LearningLQN<T>: LeitnerQueueNetwork<T> where T: Identifiable {
    private var lastQueue: Int?
    private var lastValue: T.ID?
    
    private let targetCards = 8
    
    public override func dequeue(fromQueue queueIndex: Int) -> (value: T, queue: Int)? {
        guard let value = queues[queueIndex].dequeue() else { return nil }
        
        self.lastValue = value.id
        self.lastQueue = queueIndex
        
        return (value, queueIndex)
    }
    
    private func currentLearningQueues() -> LinkedList<any Queueing<T>> {
        return queues
            .dropFirst()
            .dropLast()
    }
    
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
    
    private func numCardsCurrentlyLearning() -> Int {
        return currentLearningQueues().reduce(0) { $0 + $1.count }
    }
    
    private func cardsCurrentlyLearning() -> LinkedList<(value: T, queue: Int)> {
        return queues
            .enumerated()
            .dropFirst()
            .dropLast()
            .flatMap { idx, queue in
                return queue.values.map { value in
                    return (value: value, queue: idx)
                }
            }
    }
    
    public func dequeueWithLearningHeuristic() -> (value: T, queue: Int)? {
        
        // Insert into learning LQN if we aren't at the target number of cards.
        while queues[0].count > 0 && numCardsCurrentlyLearning() < targetCards {
            enqueue(dequeue(fromQueue: 0)!.value, intoQueue: 1)
        }
        
        if numCardsCurrentlyLearning() == 1 {
            return cardsCurrentlyLearning()[0]
        }
        
        let weights = queueWeights()
        var chosenCard: T? = nil
        var chosenQueueIndex = 0
        
        repeat {
            let random = Double.random(in: 0...1)
            let queueIndex = weights.first { $0.threshold >= random }?.queueIndex
                ?? weights.filter { $0.threshold != 0 }[0].queueIndex
            chosenCard = dequeue(fromQueue: queueIndex)?.value
            chosenQueueIndex = queueIndex
        } while chosenCard?.id == lastValue && chosenCard == nil
        
        return (value: chosenCard!, queue: chosenQueueIndex)
        
        
        // If there are unseen cards
//        if !queues[0].isEmpty {
//
//            // If there aren't enough current cards
//            if totalCardsBeyondInput < minCards {
//                return dequeue(fromQueue: 0)
//            }
//
//            // If not at target and last was not insertion
//            if totalCardsBeyondInput < targetCards && lastQueue != 0 {
//                // ... insert with probability
//                let randomVal = Double.random(in: 0...1)
//                if randomVal < insertionProb {
//                    return dequeue(fromQueue: 0)
//                }
//            }
//        }
//
//        var index: Int
//        var value: T
//
//        // Take a value that was not the previous value
//        repeat {
//            index = indices.randomElement()!
//            value = queues[index].dequeue()!
//        } while totalCardsBeyondInput > 1 && value.id == lastValue
//
//        return (value, index)
    }
}
