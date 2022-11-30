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
            if let message = session.currentMessage {
                LearningMessageView(message: message)
            } else if let card = session.currentCard {
                LearningCardView(question: LearningQuestion(card: card)) { wasCorrect in
                    Task {
                        await session.nextQuestion(wasCorrect: wasCorrect)
                    }
                }
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
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}
