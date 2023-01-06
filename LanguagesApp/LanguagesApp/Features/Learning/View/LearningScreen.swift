import SwiftUI
import LanguagesUI

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
            TopProgressBar(completion: session.completion, title: session.mode, dismiss: dismiss)
            if let message = session.currentMessage {
                LearningMessageView(message: message)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else if let card = session.currentCard {
                LearningCardView(question: LearningQuestion(card: card)) { wasCorrect in
                    Task {
                        await session.nextQuestion(wasCorrect: wasCorrect)
                    }
                }
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .animation(.spring(), value: session.currentMessage)
        .onAppear {
            Task {
                await session.startSession()
                await session.nextQuestion()
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    func dismiss() {
        Navigator.shared.goHome()
        NotificationCenter.default.post(name: .refreshData, object: nil)
    }
}
