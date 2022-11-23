import Foundation
import LanguagesAPI
import DataStructures

class ReviewLearningSession: LearningSession {
    private var questionQueue = Queue<Card>()
    override var mode: String { get { "Review" } }
    
    @MainActor
    override func nextQuestion(wasCorrect: Bool? = nil) async {
        if questionQueue.isEmpty {
            if currentCard != nil {
                // Display success
                currentMessage = .init(
                    title: "Well Done!",
                    body: "You've completed all your task cards.",
                    option1: .init(name: "Continue reviewing", action: detachedNextQuestion),
                    option2: .init(name: "Exit", action: Navigator.shared.goHome)
                )
                currentCard = nil
            } else {
                await startSession()
                currentCard = questionQueue.dequeue()
                completion = 0.0
            }
        } else {
            currentCard = questionQueue.dequeue()
            completion += 0.1 // FIXME: Actual completion
        }
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
