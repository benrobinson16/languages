//
//  TaskLearningSession.swift
//  LanguagesApp
//
//  Created by Ben Robinson on 01/11/2022.
//

import Foundation
import LanguagesAPI
import DataStructures
import IntelligentMarking

class TaskLearningSession: LearningSession {
    private let onCompletion: () -> Void
    private let lqn = LearningLQN<Card>(queues: .init(array: [
        Queue<Card>(), // Input
        NoisyQueue<Card>(noiseFactor: TaskLearningSession.noiseFactor), // Input --> Multiple choice
        NoisyQueue<Card>(noiseFactor: TaskLearningSession.noiseFactor), // Multiple choice --> English written
        NoisyQueue<Card>(noiseFactor: TaskLearningSession.noiseFactor), // English written --> Foreign written
        Queue<Card>() // Output
    ]))
    
    private static let noiseFactor = 0.5
    override var mode: String { "Tasks" }
    
    private var lastCard: Card? = nil
    private var lastQueue: Int? = nil
    
    init(onCompletion: @escaping () -> Void) {
        self.onCompletion = onCompletion
        super.init()
    }
    
    @MainActor
    override func nextQuestion(wasCorrect: Bool? = nil) async {
        if let lastCard = lastCard, let lastQueue = lastQueue, let wasCorrect = wasCorrect {
            let newQueue = wasCorrect ? lastQueue + 1 : lastQueue - 1
            lqn.enqueue(lastCard, intoQueue: max(newQueue, 1))
        }
        
        if let nextCardData = lqn.dequeueWithLearningHeuristic() {
            lastCard = nextCardData.value
            lastQueue = nextCardData.queue
            
            var newCard = nextCardData.value
            newCard.nextQuestionType = QuestionType(rawValue: nextCardData.queue)!
            
            if newCard.nextQuestionType == .multipleChoice {
                guard let token = Authenticator.shared.token else { Navigator.shared.goHome(); return }
                do {
                    let distractors = try await LanguagesAPI.makeRequest(.distractors(cardId: newCard.cardId, token: token))
                    let gen = AnswerGenerator(articles: []) // Intentionally disable article removal
                    let answers = distractors + [newCard.foreignTerm]
                    newCard.options = answers.map { gen.generate(answer: $0).randomElement() ?? "NO ANSWERS" }
                } catch {
                    ErrorHandler.shared.report(error)
                    Navigator.shared.goHome()
                }
            }
            
            currentCard = newCard
            currentMessage = nil
            
            completion += 0.1 // FIXME: Actual completion
        } else if currentCard != nil {
            // Display success
            currentMessage = .init(
                title: "Well Done!",
                body: "You've completed all your task cards.",
                option1: .init(name: "Continue reviewing", action: { }),
                option2: .init(name: "Exit", action: Navigator.shared.goHome)
            )
            currentCard = nil
        } else {
            // Alert the view a new learning session should be created
            onCompletion()
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
