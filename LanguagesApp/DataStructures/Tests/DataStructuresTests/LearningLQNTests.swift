import XCTest
@testable import DataStructures

// For simplicity, use just integers in the queue network
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
        
        // Repeat due to LQN randomisation
        var last = -1
        for _ in 0..<50 {
            let next = lqn.dequeueWithLearningHeuristic()
            XCTAssertNotNil(next)
            XCTAssertNotEqual(last, next!.value, "Should not dequeue the same element twice in a row.")
            last = next!.value
            lqn.enqueue(next!.value, intoQueue: Int.random(in: 1...2))
        }
    }
    
    func testDoesNotUseLastQueue() {
        let lqn = LearningLQN(queues: LinkedList(array: [
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: [1, 2, 3]))
        ]))
        
        // No values are currently in the main queues so cannot dequeue
        XCTAssertNil(lqn.dequeueWithLearningHeuristic())
        XCTAssertTrue(lqn.isEmpty)
    }
    
    func testMovesValuesInFromStartQueue() {
        let lqn = LearningLQN(queues: LinkedList(array: [
            Queue<Int>(LinkedList(array: [1, 2, 3])),
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: []))
        ]))
        
        // Check that the values can be dequeued
        XCTAssertNotNil(lqn.dequeueWithLearningHeuristic())
        XCTAssertFalse(lqn.isEmpty)
    }
    
    func testMovesThroughQueue() {
        let lqn = LearningLQN(queues: LinkedList(array: [
            Queue<Int>(LinkedList(array: Array(1...50))),
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: []))
        ]))
        
        // Run the entire learning session
        while (lqn.count > 0) {
            XCTAssertLessThanOrEqual(lqn.count, 8)
            let next = lqn.dequeueWithLearningHeuristic()
            XCTAssertNotNil(next)
            
            // 75% chance of getting the question right and moving up a queue
            if Double.random(in: 0...1) < 0.75 {
                lqn.enqueue(next!.value, intoQueue: next!.queue + 1)
            } else {
                lqn.enqueue(next!.value, intoQueue: max(next!.queue - 1, 1))
            }
        }
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
    
    func testEnqueueDequeue() {
        let lqn = LearningLQN(queues: LinkedList(array: [
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: [])),
            Queue<Int>(LinkedList(array: []))
        ]))
        
        for q in 0..<3 {
            // Test dequeuing from this specific queue.
            lqn.enqueue(1, intoQueue: q)
            assertDequeueEquality(lqn.dequeue(fromQueue: q), value: 1, queue: q)
            
            // Test dequeuing from a random queue (which will be the only one with values in it)
            lqn.enqueue(1, intoQueue: q)
            assertDequeueEquality(lqn.dequeueRandomQueue(), value: 1, queue: q)
            
            lqn.enqueue(1, intoQueue: q)
            if q == 0 {
                // Dequeuing with learning heuristic should have found item moved to main queues.
                // (I.e. out of the start queue)
                assertDequeueEquality(lqn.dequeueWithLearningHeuristic(), value: 1, queue: 1)
            } else if q == 1 || q == 2 {
                assertDequeueEquality(lqn.dequeueWithLearningHeuristic(), value: 1, queue: q)
            } else {
                // Dequeue with learning heuristic does not remove from final (end) queue
                XCTAssertNil(lqn.dequeueWithLearningHeuristic())
            }
        }
    }
    
    private func assertDequeueEquality(_ dequeued: (value: Int, queue: Int)?, value: Int, queue: Int) {
        XCTAssertNotNil(dequeued)
        XCTAssertEqual(dequeued!.value, value)
        XCTAssertEqual(dequeued!.queue, queue)
    }
}
