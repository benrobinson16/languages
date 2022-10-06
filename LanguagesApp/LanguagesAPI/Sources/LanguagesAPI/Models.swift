import Foundation

public struct Card: Codable {
    public let cardId: Int
    public let englishTerm: String
    public let foreignTerm: String
    public let dueDate: Date?
    public let nextQuestionType: QuestionType?
}

public enum QuestionType: Int, Codable {
    case none = 0
    case multipleChoice = 1
    case englishWritten = 2
    case foreignWritten = 3
}


public struct StudentSummary: Codable {
    public let streakHistory: [StreakDay]
    public let streakLength: Int
    public let tasks: [TaskVm]
    public let dailyPercentage: Double
    public let overdueMessage: String
    public let studentName: String
}

public struct StreakDay: Codable {
    public let date: String
    public let didAttempt: Bool
}

public struct TaskVm: Codable {
    public let id: Int
    public let classId: Int
    public let deckId: Int
    public let className: String
    public let deckName: String
    public let dueDate: String
}

public struct TaskSummary: Codable {
    public let taskDetails: TaskVm
    public let cards: [Card]
}
