import Foundation
import LanguagesAPI
import IntelligentMarking

class LearningQuestion: ObservableObject {
    private let marker: IntelligentMarking
    
    let card: Card
    @Published var correct: Bool? = nil
    @Published var feedback: String? = nil
    
    init(card: Card) {
        self.card = card
        
        let answerGenerator = AnswerGenerator()
        let typoDetector = WeightedEditDistance(perCharacterThreshold: 0.2)
        self.marker = IntelligentMarking(answerGenerator: answerGenerator, typoDetector: typoDetector)
    }
    
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