import XCTest
@testable import IntelligentMarking

final class AnswerGeneratorTests: XCTestCase {
    let generator = AnswerGenerator()
    
    let testCases: [(answer: String, language: String, expectedAnswers: [String])] = [
        (
            "vert(e)",
            "fr",
            [
                "vert",
                "verte",
                "vert(e)"
            ]
        ),
        (
            "nouveau/nouvelle",
            "fr",
            [
                "nouveau",
                "nouvelle",
                "nouveau/nouvelle",
                "nouvelle/nouveau"
            ]
        ),
        (
            "green cat/dog",
            "en",
            [
                "green cat",
                "green dog",
                "green cat/dog",
                "green dog/cat"
            ]
        ),
        (
            "[green cat]/[blue dog]",
            "en",
            [
                "green cat",
                "blue dog",
                "green cat/blue dog",
                "blue dog/green cat"
            ]
        ),
        (
            "indigo/violet",
            "en",
            [
                "indigo",
                "violet",
                "indigo/violet",
                "violet/indigo"
            ]
        ),
        (
            "pretty/beautiful view",
            "en",
            [
                "pretty view",
                "beautiful view",
                "pretty/beautiful view",
                "beautiful/pretty view"
            ]
        ),
        (
            "cheap/[good deal]",
            "en",
            [
                "cheap",
                "good deal",
                "cheap/good deal",
                "good deal/cheap"
            ]
        ),
        (
            "to throw (away)",
            "en",
            [
                "to throw",
                "to throw away",
                "to throw (away)"
            ]
        ),
        (
            "the computer",
            "en",
            [
                "the computer",
                "computer"
            ]
        ),
        (
            "a dog",
            "en",
            [
                "a dog",
                "dog"
            ]
        ),
        (
            "le chien",
            "fr",
            [
                "le chien",
                "chien"
            ]
        ),
        (
            "[la voiture]/[l'hopital]",
            "fr",
            [
                "la voiture",
                "voiture",
                "l'hopital",
                "hopital",
                "la voiture/l'hopital",
                "voiture/l'hopital",
                "l'hopital/la voiture",
                "hopital/la voiture"
            ]
        ),
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
    
    /// Helper function to compare two arrays as an XCTest. This ensures the two arrays contain the same number of elements
    /// and also contain all elements from the other, with no requirement on the two to be sorted.
    private func compareArrays(arr1: [String], arr2: [String]) {
        for ele in arr1 {
            XCTAssertTrue(arr2.contains(ele), "Expected arr2 to contain " + ele)
        }
        
        XCTAssertEqual(arr1.count, arr2.count)
    }
}
