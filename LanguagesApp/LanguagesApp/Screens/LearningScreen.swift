import SwiftUI

struct LearningScreenWrapper: View {
    @State private var isReviewing = false
    
    var body: some View {
        if isReviewing {
            LearningScreen(session: ReviewLearningSession())
        } else {
            LearningScreen(session: TaskLearningSession(onCompletion: moveToReview))
        }
    }
    
    func moveToReview() {
        isReviewing = false
    }
}

struct LearningScreen: View {
    @ObservedObject var session: LearningSession
    
    var body: some View {
        VStack {
            Rectangle() // Top bar
            if let card = session.currentCard {
                LearningCardView(question: LearningQuestion(card: card))
            } else if let message = session.currentMessage {
                LearningMessageView(message: message)
            } else {
                ProgressView()
            }
        }
    }
}
