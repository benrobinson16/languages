import XCTest
@testable import IntelligentMarking

final class AnswerGeneratorTests: XCTestCase {
    let generator = AnswerGenerator(articles: [
        "le ", "la ", "les ", "l'", "un ", "une ", "de ", "du ", "des "
    ])
    
    let testCases: [(answer: String, expectedAnswers: [String])] = [
        (
            "je suis né(e)",
            [
                "je suis né",
                "je suis née"
            ]
        ),
        (
            "aa(b)cc(d)/1234",
            [
                "1234",
                "aacc",
                "aaccd",
                "aabcc",
                "aabccd"
            ]
        ),
        (
            "un crayon (vert)",
            [
                "un crayon",
                "un crayon vert",
                "crayon",
                "crayon vert"
            ]
        ),
        (
            "a dog/cat is green/orange or purple (in colour)",
            [
                "a dog is green or purple",
                "a dog is orange or purple",
                "a cat is green or purple",
                "a cat is orange or purple",
                "a dog is green or purple in colour",
                "a dog is orange or purple in colour",
                "a cat is green or purple in colour",
                "a cat is orange or purple in colour"
            ]
        ),
        (
            "a dog/cat is green/(orange or) purple (in colour)",
            [
                "a dog is green purple",
                "a dog is orange or purple",
                "a cat is green purple",
                "a cat is orange or purple",
                "a dog is green purple in colour",
                "a dog is orange or purple in colour",
                "a cat is green purple in colour",
                "a cat is orange or purple in colour",
                "a cat is purple",
                "a cat is purple in colour",
                "a dog is purple",
                "a dog is purple in colour"
            ]
        )
    ]
    
    func testAnswerGeneration() {
        for testCase in testCases {
            let answers = generator.generate(answer: testCase.answer)
            compareArrays(arr1: testCase.expectedAnswers, arr2: answers)
        }
    }
    
    private func compareArrays(arr1: [String], arr2: [String]) {
        print(arr1.sorted())
        print(arr2.sorted())
        
        for ele in arr1 {
            XCTAssertTrue(arr2.contains(ele), "Expected arr2 to contain " + ele)
        }
        
        XCTAssertEqual(arr1.count, arr2.count)
    }
}
