import XCTest
@testable import IntelligentMarking

final class IntelligentMarkingTests: XCTestCase {
    let marker = IntelligentMarking(
        answerGenerator: AnswerGenerator(),
        typoDetector: WeightedEditDistance(perCharacterThreshold: 0.2)
    )
    
    let testCases: [(userAnswer: String, teacherAnswer: String, correct: Bool, language: String)] = [
        ("vert", "vert(e)", true, "fr"),
        ("verte", "vert(e)", true, "fr"),
        ("vert(e)", "vert(e)", true, "fr"),
        ("vertee", "vert(e)", false, "fr"),
        ("nouvelke", "nouveau/nouvelle", true, "fr"), // weighted edit distance < threshold
        ("nouvele", "nouveau/nouvelle", false, "fr"), // weighted edit distance > threshold
        ("nouveaunouvelle", "nouvelle/nouveau", true, "fr"), // weighted edit distance < threshold
        ("n0uveaunouvelle", "nouvelle/nouveau", false, "fr"), // weighted edit distance > threshold
        ("green cat/dog", "green cat/dog", true, "en"),
        ("green dog/cat", "green cat/dog", true, "en"),
        ("greencat", "green cat/dog", true, "en"), // whitespaces ignored in edit distance
        ("grrencat", "green dog/cat", true, "en"), // weighted edit distance < threshold
        ("grrrncat", "green dog/cat", false, "en"), // weighted edit distance > threshold
        ("blue dog", "[green cat]/[blue dog]", true, "en"),
        ("green cat", "[green cat]/[blue dog]", true, "en"),
        ("to throw away", "to throw (away)", true, "en"),
        ("to throw", "to throw (away)", true, "en"),
        ("to throw (away)", "to throw (away)", true, "en"),
        ("to throw (away", "to throw (away)", false, "en"), // weighted edit distance > threshold
        ("to thrmw away", "to throw (away)", true, "en"), // weighted edit distance < threshold
        ("to thrnw away", "to throw (away)", false, "en"), // weighted edit distance > threshold
        ("the computer", "the computer", true, "en"),
        ("computer", "the computer", true, "en"),
        ("clmputer", "the computer", true, "en"), // weighted edit distance < threshold
        ("cmmputer", "the computer", false, "en"), // weighted edit distance > threshold
        ("chien", "le chien", true, "fr"),
        ("voiture", "la voiture", true, "fr"),
        ("hopital", "[la voiture]/[l'hopital]", true, "fr"),
        ("hlpital", "[la voiture]/[l'hopital]", true, "fr"),
        ("hopiatl", "[la voiture]/[l'hopital]", false, "fr"),
        
        // long string performance tests
        (
            "'cause there we are again that little town street",
            "'cause there we are again on that little town street",
            true,
            "en"
        ),
        (
            "'cause there we are on that little town street",
            "'cause there we are again on that little town street",
            false,
            "en"
        ),
        (
            "it was r.re, I rememBer it all too well/wind in my hair, I was there, I was there]",
            "[it was rare, I remember it all too well]/[wind in my hair, I was there, I was there]",
            true,
            "en"
        ),
        (
            "wind in my hair, I was, I was there",
            "[it was rare, I remember it all too well]/[wind in my hair, I was there, I was there]",
            false,
            "en"
        ),
        (
            "Rebekah rode up on the atfernoon train, it was snuny",
            "Rebekah rode up on the afternoon train, it was sunny",
            true,
            "en"
        ),
        (
            "Rebecca rode up on the morning train, it was windy",
            "Rebekah rode up on the afternoon train, it was sunny",
            false,
            "en"
        ),
        (
            "wedding was charming if a little guache",
            "the wedding was charming if a little gauche",
            true,
            "en"
        ),
        (
            "the wedding was charming if a little gauche",
            "the wedding was gauche if a little charming",
            false,
            "en"
        ),
        (
            "I swear I don't love the drama: it loves me",
            "I swear I don't love the drama; (it) love's me",
            true,
            "en"
        ),
        (
            "I swear I love the drama: it dislikes me",
            "I swear I don't love the drama; (it) love's me",
            false,
            "en"
        )
    ]
    
    func testAnswerGeneration() {
        for testCase in testCases {
            let correct = marker.isCorrect(
                userAnswer: testCase.userAnswer,
                teacherAnswer: testCase.teacherAnswer,
                language: testCase.language
            )
            
            if correct != testCase.correct {
                print(testCase.userAnswer)
                print(testCase.teacherAnswer)
                _ = marker.isCorrect(
                    userAnswer: testCase.userAnswer,
                    teacherAnswer: testCase.teacherAnswer,
                    language: testCase.language
                )
            }
            XCTAssertEqual(correct, testCase.correct)
        }
    }
}
