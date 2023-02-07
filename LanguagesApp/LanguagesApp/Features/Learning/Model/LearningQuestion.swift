import Foundation
import LanguagesAPI
import IntelligentMarking

/// Represents a single question and the associated lifecycle.
class LearningQuestion: ObservableObject {
    private let kWeightedEditDistanceThreshold = 0.2
    private let marker: IntelligentMarking
    
    let card: Card
    @Published var correct: Bool? = nil
    @Published var feedback: String? = nil
    
    /// Creates a new question with the given card.
    /// - Parameter card: The card to ask the question on.
    init(card: Card) {
        self.card = card
        
        let answerGenerator = AnswerGenerator()
        let typoDetector = WeightedEditDistance(perCharacterThreshold: kWeightedEditDistanceThreshold)
        self.marker = IntelligentMarking(answerGenerator: answerGenerator, typoDetector: typoDetector)
    }
    
    /// Answer a question.
    /// - Parameter answer: The user's answer.
    func answerQuestion(answer: String) {
        guard let token = Authenticator.shared.token else { return }
        
        let correctAnswer = card.nextQuestionType == .englishWritten ? card.englishTerm : card.foreignTerm
        let languageCode = card.nextQuestionType == .englishWritten ? "en" : "fr"
        let results = marker.isCorrectFeedback(userAnswer: answer, teacherAnswer: correctAnswer, language: languageCode)
        
        correct = results.isCorrect
        
        if let correction = results.correction {
            if results.isCorrect {
                feedback = "You have a typo. It should be: " + correction
            } else {
                feedback = "It should be: " + correction
            }
        }
        
        // Update the server
        ErrorHandler.shared.detachAsync {
            _ = try await LanguagesAPI.makeRequest(
                .didAnswer(
                    cardId: self.card.cardId,
                    correct: results.isCorrect,
                    questionType: self.card.nextQuestionType ?? .multipleChoice,
                    token: token
                )
            )
        }
    }
}
