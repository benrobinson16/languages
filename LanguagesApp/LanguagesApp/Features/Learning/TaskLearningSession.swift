//
//  TaskLearningSession.swift
//  LanguagesApp
//
//  Created by Ben Robinson on 01/11/2022.
//

import Foundation
import LanguagesAPI
import DataStructures

class TaskLearningSession: LearningSession {
    private let onCompletion: () -> Void
    private let lqn = LearningLQN<Card>(queues: .init(array: [
        Queue<Card>(), // Input --> Multiple choice
        NoisyQueue<Card>(noiseFactor: TaskLearningSession.noiseFactor), // Input --> Multiple choice
        NoisyQueue<Card>(noiseFactor: TaskLearningSession.noiseFactor), // Multiple choice --> English written
        NoisyQueue<Card>(noiseFactor: TaskLearningSession.noiseFactor), // English written --> Foreign written
    ]))
    
    private static let noiseFactor = 0.5
    
    init(onCompletion: @escaping () -> Void) {
        self.onCompletion = onCompletion
        super.init()
    }
    
    override func nextQuestion() async {
        if lqn.isEmpty {
            if currentCard != nil {
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
        } else {
            guard let nextCardData = lqn.dequeueWithLearningHeuristic() else { return }
            
            var newCard = nextCardData.value
            newCard.nextQuestionType = QuestionType(rawValue: nextCardData.queue)!
            currentCard = newCard
            currentMessage = nil
        }
    }
    
    override func startSession() async {
        guard let token = Authenticator.shared.token else { return }
        
        await ErrorHandler.shared.wrapAsync {
            let cards = try await LanguagesAPI.makeRequest(.taskCards(token: token))
            for c in cards {
                lqn.enqueue(c, intoQueue: c.nextQuestionType.rawValue)
            }
        }
    }
}
