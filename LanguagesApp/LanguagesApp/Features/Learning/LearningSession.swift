//
//  LearningSession.swift
//  LanguagesApp
//
//  Created by Ben Robinson on 01/11/2022.
//

import Foundation
import LanguagesAPI

class LearningSession: ObservableObject {
    @Published var currentCard: Card? = nil
    @Published var currentMessage: Message? = nil
    
    func nextQuestion() async { }
    func startSession() async { }
}
