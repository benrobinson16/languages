import XCTest
@testable import IntelligentMarking

final class WeightedEditDistanceTests: XCTestCase {
    let editDistance = WeightedEditDistance(threshold: 3)
    
    let testCases: [(start: String, end: String, distance: Int)] = [
        ("q", "r", 3),
        ("q", "e", 2),
        ("q", "w", 1),
        ("q", "q", 0),
        ("qwerty", "qwe rtu", 4)
    ]
    
    func testAnswerGeneration() {
        for testCase in testCases {
            let distance = editDistance.calculate(from: testCase.start, to: testCase.end)
            XCTAssertEqual(distance, testCase.distance)
        }
    }
}
