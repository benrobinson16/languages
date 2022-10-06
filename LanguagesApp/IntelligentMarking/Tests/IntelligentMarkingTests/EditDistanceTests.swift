import XCTest
@testable import IntelligentMarking

final class EditDistanceTests: XCTestCase {
    let editDistance = EditDistance(threshold: 2)
    
    let testCases: [(start: String, end: String, distance: Int)] = [
        ("a", "b", 1),
        ("aa", "ab", 1),
        ("aa", "a", 1),
        ("aba", "a", 2),
        ("aba aba", "aaa aaa", 2),
        ("aba aba", "aaa", 4)
    ]
    
    func testAnswerGeneration() {
        for testCase in testCases {
            let distance = editDistance.calculate(from: testCase.start, to: testCase.end)
            XCTAssertEqual(distance, testCase.distance)
        }
    }
}
