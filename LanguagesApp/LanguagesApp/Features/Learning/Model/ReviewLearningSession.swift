import Foundation
import LanguagesAPI
import DataStructures
import IntelligentMarking

class ReviewLearningSession: LearningSession {
    private var questionQueue = Queue<Card>()
    override var mode: String { "Review" }
    
    @MainActor
    override func nextQuestion(wasCorrect: Bool? = nil) async {
        if currentMessage == nil {
            completion += 0.1
        }
        
        if questionQueue.isEmpty {
            if currentCard != nil {
                // Display success
                currentMessage = .init(
                    title: "🥳 Well Done!",
                    body: "You've completed 10 review cards.",
                    option1: .init(name: "Continue reviewing", action: detachedNextQuestion),
                    option2: .init(name: "Exit", action: dismiss)
                )
                currentCard = nil
            } else {
                await startSession()
                
                currentCard = await nextCard()
                currentMessage = nil
                completion = 0.0
            }
        } else {
            currentCard = await nextCard()
            currentMessage = nil
        }
    }
    
    private func nextCard() async -> Card {
        var nextCard = questionQueue.dequeue()!
        nextCard.nextQuestionType = QuestionType.questionTypes.randomElement()!
        
        if nextCard.nextQuestionType == .multipleChoice {
            guard let token = Authenticator.shared.token else { Navigator.shared.goHome(); return nextCard }
            do {
                let distractors = try await LanguagesAPI.makeRequest(.distractors(cardId: nextCard.cardId, token: token))
                let gen = AnswerGenerator()
                let answers = distractors + [nextCard.foreignTerm]
                
                nextCard.options = LinkedList(array: answers)
                    .shuffled()
                    .map { gen.generate(answer: $0, language: nil).randomElement() ?? "NO ANSWERS" }
                    .toArray()
            } catch {
                ErrorHandler.shared.report(error)
                dismiss()
            }
        }
        
        return nextCard
    }
    
    private func detachedNextQuestion() {
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
