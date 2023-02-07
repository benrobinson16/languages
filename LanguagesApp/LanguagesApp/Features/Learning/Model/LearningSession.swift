import Foundation
import LanguagesAPI

/// Manages the lifetime of a learning session, providing current card/message and completion.
class LearningSession: ObservableObject {
    @Published var currentCard: Card? = nil
    @Published var currentMessage: Message? = nil
    @Published var completion: Double = 0.0
    var mode: String { "" }
    
    func nextQuestion(wasCorrect: Bool? = nil) async { }
    func startSession() async { }
    
    /// Closes the learning session view.
    func dismiss() {
        Navigator.shared.goHome()
        NotificationCenter.default.post(name: .refreshData, object: nil)
    }
}
