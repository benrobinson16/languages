import Foundation
import LanguagesAPI
import DataStructures
import IntelligentMarking

/// Manages a review learning session.
class ReviewLearningSession: LearningSession {
    private var questionQueue = Queue<Card>()
    override var mode: String { "Review" }
    
    /// Gets the next queuestion from the queue, or provides an interstitial card,
    /// - Parameter wasCorrect: Whether the user answered the previous card correctly.
    @MainActor
    override func nextQuestion(wasCorrect: Bool? = nil) async {
        if wasCorrect != nil {
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
    
    /// Helper to get the next card from the queue.
    /// - Returns: The card (if any).
    private func nextCard() async -> Card? {
        guard var nextCard = questionQueue.dequeue() else {
            // No card available; abort session
            Navigator.shared.goHome()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                AlertHandler.shared.show("No cards available", body: "Ask your teacher to set you some homework!")
            }
            return nil
        }
        
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
    
    /// Gets the next question as a detached task.
    private func detachedNextQuestion() {
        Task {
            await nextQuestion()
        }
    }
    
    /// Starts the session by getting cards from the server.
    override func startSession() async {
        guard let token = Authenticator.shared.token else { return }
        
        await ErrorHandler.shared.wrapAsync {
            let newCards = try await LanguagesAPI.makeRequest(.reviewCards(token: token))
            questionQueue = Queue(newCards)
        }
    }
}
