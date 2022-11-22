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
        isReviewing = true
    }
}

struct LearningScreen: View {
    @ObservedObject var session: LearningSession
    
    var body: some View {
        VStack {
            LearningProgressBar(completion: session.completion, mode: session.mode, dismiss: Navigator.shared.goHome)
            if let card = session.currentCard {
                LearningCardView(question: LearningQuestion(card: card)) {
                    Task {
                        await session.nextQuestion()
                    }
                }
            } else if let message = session.currentMessage {
                LearningMessageView(message: message)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                await session.startSession()
                await session.nextQuestion()
            }
        }
    }
}
