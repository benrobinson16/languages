import Foundation
import LanguagesAPI
import IntelligentMarking

class LearningQuestion: ObservableObject {
    private let editDistanceCalculator = WeightedEditDistance(perCharacterThreshold: 0.2)
    private let answerGenerator: AnswerGenerator
    
    let card: Card
    @Published var correct: Bool? = nil
    @Published var feedback: String? = nil
    
    init(card: Card) {
        self.card = card
        
        if let articles = FileController.shared.articles {
            self.answerGenerator = AnswerGenerator(articles: articles)
        } else if let articles = FileController.shared.readArticles(languageCode: "fr") { // only French supported
            self.answerGenerator = AnswerGenerator(articles: articles)
        } else {
            // Will continue silently, without providing the article ignoring feature.
            self.answerGenerator = AnswerGenerator(articles: [])
        }
    }
    
    func answerQuestion(answer: String) {
        guard let token = Authenticator.shared.token else { return }
        
        let correctAnswer = card.nextQuestionType == .englishWritten ? card.englishTerm : card.foreignTerm
        let correct = markCard(answer: answer, correctAnswer: correctAnswer)
        
        // Update the server
        ErrorHandler.shared.detachAsync {
            _ = try await LanguagesAPI.makeRequest(
                .didAnswer(
                    cardId: self.card.cardId,
                    correct: correct,
                    questionType: self.card.nextQuestionType,
                    token: token
                )
            )
        }
    }
    
    private func markCard(answer: String, correctAnswer: String) -> Bool {
        let possibleAnswers = answerGenerator.generate(answer: correctAnswer)
        
        if possibleAnswers.contains(answer) {
            correct = true
            return true
        }
        
        for possibleAnswer in possibleAnswers {
            if editDistanceCalculator.isOnlyTypo(source: possibleAnswer, target: answer) {
                correct = true
                feedback = "You have a typo. It should be: \(possibleAnswer)"
                return true
            }
        }
        
        correct = false
        feedback = "It should be: \(possibleAnswers[0])"
        return false
    }
}
