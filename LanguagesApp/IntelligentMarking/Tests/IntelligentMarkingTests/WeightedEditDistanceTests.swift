import XCTest
@testable import IntelligentMarking

final class WeightedEditDistanceTests: XCTestCase {
    let editDistance = WeightedEditDistance(perCharacterThreshold: 0.15)
    
    let testCases: [(start: String, end: String, distance: Int)] = [
        ("q", "r", 3),
        ("q", "e", 2),
        ("q", "w", 1),
        ("q", "q", 0),
        ("qwerty", "qwe rty", 0),
        ("hello w0rld", "h3llo world", 6),
        ("je suis ne", "je suis nee", 3),
        ("hello there I am a robot", "hello the I am robot", 9),
        ("qwertyuiop", "qwertguiop", 1),
        ("abcde", "abde", 3),
        ("abde", "abcde", 3),
        ("nouvellenouveau", "nouvelle/nouveau", 3),
        ("nouvelke", "nouvelle", 1)
    ]
    
    func testWeightedEditDistance() {
        for testCase in testCases {
            let distance = editDistance.editDistance(from: testCase.start, to: testCase.end)
            let distance2 = editDistance.editDistance(from: testCase.end, to: testCase.start)
            XCTAssertEqual(distance, testCase.distance)
            XCTAssertEqual(distance2, testCase.distance)
        }
    }
}
