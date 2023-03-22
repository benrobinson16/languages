import XCTest
@testable import DataStructures

extension Int: Identifiable {
    public var id: Int { return self }
}

final class LearningLQNTests: XCTestCase {
    func testDoesNotReturnSameItemTwice() {
        let lqn = LearningLQN(queues: LinkedList(array: [
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: [1])),
            Queue<Int>(LinkedList(array: [2, 3])),
            Queue<Int>(LinkedList(array: []))
        ]))
        
        var last = -1
        for _ in 0..<50 { // Repeat due to LQN randomisation
            let next = lqn.dequeueWithLearningHeuristic()
            XCTAssertNotNil(next)
            XCTAssertNotEqual(last, next!.value, "Should not dequeue the same element twice in a row.")
            last = next!.value
            lqn.enqueue(next!.value, intoQueue: Int.random(in: 1...2))
        }
    }
    
    func testDoesNotUseFirstAndLastQueues() {
        let lqn = LearningLQN(queues: LinkedList(array: [
            Queue<Int>(LinkedList(array: [1])),
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: [2]))
        ]))
        
        XCTAssertNil(lqn.dequeueWithLearningHeuristic())
    }
    
    func testWeightingByQueue() {
        let lqn = LearningLQN(queues: LinkedList(array: [
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: [1, 2, 3, 4, 5, 6, 7, 8])),
            Queue<Int>(LinkedList(array: [9, 10])),
            Queue<Int>(LinkedList(array: []))
        ]))
        
        // Aim: run the test many times, num times from queue 1 should be around 80%
        var numQueue1 = 0
        for _ in 0..<1000 {
            let next = lqn.dequeueWithLearningHeuristic()
            XCTAssertNotNil(next)
            if next!.queue == 1 {
                numQueue1 += 1
            }
            lqn.enqueue(next!.value, intoQueue: next!.queue)
        }
        
        // Should fall in range 765-835 with >99%
        XCTAssertTrue(765 < numQueue1)
        XCTAssertTrue(835 > numQueue1)
    }
}
