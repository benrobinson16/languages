import Foundation
import LanguagesAPI
import LanguagesUI
import DataStructures
import IntelligentMarking

class TaskLearningSession: LearningSession {
    private let onCompletion: () -> Void
    private let lqn = LearningLQN<Card>(queues: .init(array: [
        Queue<Card>(), // Input
        NoisyQueue<Card>(noiseFactor: TaskLearningSession.noiseFactor), // --> Multiple choice
        NoisyQueue<Card>(noiseFactor: TaskLearningSession.noiseFactor), // --> English written
        NoisyQueue<Card>(noiseFactor: TaskLearningSession.noiseFactor), // --> Foreign written
        Queue<Card>() // Output
    ]))
    
    private static let noiseFactor = 0.5
    override var mode: String { "Tasks" }
    
    private var lastQueue: Int? = nil
    
    init(onCompletion: @escaping () -> Void) {
        self.onCompletion = onCompletion
        super.init()
    }
    
    @MainActor
    override func nextQuestion(wasCorrect: Bool? = nil) async {
        guard let token = Authenticator.shared.token else { dismiss(); return }
        
        if let currentCard = currentCard, let lastQueue = lastQueue, let wasCorrect = wasCorrect {
            // Re-insert last card if it exists
            let newQueue = wasCorrect ? lastQueue + 1 : lastQueue - 1
            lqn.enqueue(currentCard, intoQueue: max(newQueue, 1))
            
            self.lastQueue = nil
            completion += 0.1
        } else if currentMessage != nil {
            // Reset completion for new set of 10
            completion = 0.0
        } else {
            // Check daily completion for new session
            await ErrorHandler.shared.wrapAsync {
                let dayCompletion = try await LanguagesAPI.makeRequest(.dailyCompletion(token: token))
                if dayCompletion >= 1.0 {
                    currentMessage = .init(
                        title: "🎉 Well Done!",
                        body: "You've completed all your task cards for the day.",
                        option1: .init(name: "Continue reviewing", action: onCompletion),
                        option2: .init(name: "Exit", action: dismiss)
                    )
                    currentCard = nil
                    return
                }
            }
        }
        
        if completion > 0.9 || lqn.isEmpty {
            completion = 1.0
            await ErrorHandler.shared.wrapAsync {
                let dayCompletion = try await LanguagesAPI.makeRequest(.dailyCompletion(token: token))
                if dayCompletion >= 1.0 {
                    currentMessage = .init(
                        title: "🎉 Well Done!",
                        body: "You've completed all your task cards for the day.",
                        option1: .init(name: "Continue reviewing", action: onCompletion),
                        option2: .init(name: "Exit", action: dismiss)
                    )
                    currentCard = nil
                } else {
                    currentMessage = .init(
                        title: "👍 Way to go!",
                        body: "That's another 10 cards. You've completed \(dayCompletion.formatPercentage()) of today's work.",
                        option1: .init(name: "Continue learning", action: detachedNextQuestion),
                        option2: nil
                    )
                    currentCard = nil
                }
            }
        } else {
            guard let nextCardData = lqn.dequeueWithLearningHeuristic() else {
                dismiss()
                return
            }
            
            var newCard = nextCardData.value
            newCard.nextQuestionType = QuestionType(rawValue: nextCardData.queue)!
            
            if newCard.nextQuestionType == .multipleChoice {
                do {
                    let distractors = try await LanguagesAPI.makeRequest(.distractors(cardId: newCard.cardId, token: token))
                    let gen = AnswerGenerator()
                    let answers = distractors + [newCard.foreignTerm]
                    
                    newCard.options = LinkedList(array: answers)
                        .shuffled()
                        .map { gen.generate(answer: $0, language: nil).randomElement() ?? "NO ANSWERS" }
                        .toArray()
                } catch {
                    ErrorHandler.shared.report(error)
                    dismiss()
                }
            }
            
            currentCard = newCard
            lastQueue = nextCardData.queue
            currentMessage = nil
        }
    }
    
    private func detachedNextQuestion() {
        Task {
            await nextQuestion()
        }
    }
    
    override func startSession() async {
        guard let token = Authenticator.shared.token else { return }
        
        await ErrorHandler.shared.wrapAsync {
            let cards = try await LanguagesAPI.makeRequest(.taskCards(token: token))
            for c in cards {
                lqn.enqueue(c, intoQueue: c.nextQuestionType?.rawValue ?? 0)
            }
        }
    }
}
