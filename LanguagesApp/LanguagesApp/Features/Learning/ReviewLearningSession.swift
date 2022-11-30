import Foundation
import LanguagesAPI
import DataStructures
import IntelligentMarking

class ReviewLearningSession: LearningSession {
    private var questionQueue = Queue<Card>()
    override var mode: String { "Review" }
    
    @MainActor
    override func nextQuestion(wasCorrect: Bool? = nil) async {
        completion += 0.1
        
        if questionQueue.isEmpty {
            if currentCard != nil {
                // Display success
                currentMessage = .init(
                    title: "🥳 Well Done!",
                    body: "You've completed 10 review cards.",
                    option1: .init(name: "Continue reviewing", action: detachedNextQuestion),
                    option2: .init(name: "Exit", action: Navigator.shared.goHome)
                )
                currentCard = nil
            } else {
                await startSession()
                
                currentCard = await nextCard()
                completion = 0.0
            }
        } else {
            currentCard = await nextCard()
        }
    }
    
    private func nextCard() async -> Card {
        var nextCard = questionQueue.dequeue()!
        nextCard.nextQuestionType = QuestionType.questionTypes.randomElement()!
        
        if nextCard.nextQuestionType == .multipleChoice {
            guard let token = Authenticator.shared.token else { Navigator.shared.goHome(); return nextCard }
            do {
                let distractors = try await LanguagesAPI.makeRequest(.distractors(cardId: nextCard.cardId, token: token))
                let gen = AnswerGenerator(articles: []) // Intentionally disable article removal
                let answers = distractors + [nextCard.foreignTerm]
                nextCard.options = answers.map { gen.generate(answer: $0).randomElement() ?? "NO ANSWERS" }
            } catch {
                ErrorHandler.shared.report(error)
                Navigator.shared.goHome()
            }
        }
        
        return nextCard
    }
    
    func detachedNextQuestion() {
        Task {
            await nextQuestion()
        }
    }
    
    override func startSession() async {
        guard let token = Authenticator.shared.token else { return }
        
        await ErrorHandler.shared.wrapAsync {
            let newCards = try await LanguagesAPI.makeRequest(.reviewCards(token: token))
            questionQueue = Queue(newCards)
        }
    }
}
