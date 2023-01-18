import XCTest
@testable import IntelligentMarking

final class AnswerGeneratorTests: XCTestCase {
    let generator = AnswerGenerator()
    
    let testCases: [(answer: String, language: String, expectedAnswers: [String])] = [
        (
            "je suis né(e)",
            "fr",
            [
                "je suis né",
                "je suis née",
                "je suis né(e)"
            ]
        ),
        (
            "aa(b)cc/1234",
            "en",
            [
                "1234",
                "aacc",
                "aabcc",
                "aa(b)cc",
                "aacc/1234",
                "aabcc/1234",
                "aa(b)cc/1234",
                "1234/aacc",
                "1234/aabcc",
                "1234/aa(b)cc"
            ]
        ),
        (
            "un crayon (vert)",
            "fr",
            [
                "un crayon",
                "un crayon vert",
                "un crayon (vert)",
                "crayon",
                "crayon vert",
                "un crayon (vert)"
            ]
        ),
        (
            "a dog/cat is green (and purple)",
            "en",
            [
                "a dog is green",
                "a dog is green and purple",
                "a dog is green (and purple)",
                "a cat is green",
                "a cat is green and purple",
                "a cat is green (and purple)",
                "a dog/cat is green",
                "a dog/cat is green and purple",
                "a dog/cat is green (and purple)",
                "a cat/dog is green",
                "a cat/dog is green and purple",
                "a cat/dog is green (and purple)",
                "dog is green",
                "dog is green and purple",
                "dog is green (and purple)",
                "cat is green",
                "cat is green and purple",
                "cat is green (and purple)",
                "dog/cat is green",
                "dog/cat is green and purple",
                "dog/cat is green (and purple)",
                "cat/dog is green",
                "cat/dog is green and purple",
                "cat/dog is green (and purple)"
            ]
        ),
        (
            "[hello world]/[hi earth]",
            "en",
            [
                "hello world",
                "hi earth",
                "hello world/hi earth",
                "hi earth/hello world"
            ]
        )
    ]
    
    func testAnswerGeneration() {
        for testCase in testCases {
            let answers = generator.generate(answer: testCase.answer, language: testCase.language)
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
