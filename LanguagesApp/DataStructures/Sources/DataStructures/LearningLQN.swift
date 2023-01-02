import Foundation

public class LearningLQN<T>: LeitnerQueueNetwork<T> where T: Identifiable {
    private var lastQueue: Int?
    private var lastValue: T.ID?
    
    private let targetCards = 8
    
    public override var isEmpty: Bool {
        return numCardsCurrentlyLearning() == 0
    }
    
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
                let arr = queue.values.map { value in
                    return (value: value, queue: idx)
                }
                
                return arr
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
    }
}
