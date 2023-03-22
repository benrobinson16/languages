import XCTest
@testable import DataStructures

final class NoisyQueueTests: XCTestCase {
    func testProbabilityDistribution() {
        let numTrials = 100000
        let noiseFactor = 0.5
        let allowedError = 0.01 // Due to randomness
        
        var itemCounts = [0, 0, 0]
        for _ in 0..<numTrials {
            let q = NoisyQueue([0, 1, 2], noiseFactor: noiseFactor)
            itemCounts[q.dequeue()!] += 1
        }
        
        let expectedProportions = [0.5 + pow(0.5, 3), pow(0.5, 2), pow(0.5, 3)]
        let actualProportions = itemCounts.map { Double($0) / Double(numTrials) }
        
        for i in 0..<3 {
            XCTAssertLessThan(0, actualProportions[i])
            XCTAssertLessThan(expectedProportions[i] - allowedError, actualProportions[i])
            XCTAssertGreaterThan(expectedProportions[i] + allowedError, actualProportions[i])
        }
    }
}
