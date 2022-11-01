import Foundation
import LanguagesAPI
import DataStructures

class ReviewLearningSession: LearningSession {
    private var questionQueue = Queue<Card>()
    
    override func nextQuestion() async {
        if questionQueue.isEmpty {
            if currentCard != nil {
                // Display success
                currentMessage = .init(
                    title: "Well Done!",
                    body: "You've completed all your task cards.",
                    option1: "Continue reviewing",
                    option2: "Exit"
                )
                currentCard = nil
            } else {
                await startSession()
                currentCard = questionQueue.dequeue()
            }
        } else {
            currentCard = questionQueue.dequeue()
        }
    }
    
    override func startSession() async {
        guard let token = token else { return }
        
        do {
            let newCards = try await LanguagesAPI.makeRequest(.reviewCards(token: token))
            questionQueue = Queue(newCards)
        } catch {
            // FIXME: Error handling
        }
    }
}
