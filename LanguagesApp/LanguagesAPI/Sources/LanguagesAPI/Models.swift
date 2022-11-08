import Foundation

public struct Card: Codable, Identifiable, Equatable {
    public let cardId: Int
    public let englishTerm: String
    public let foreignTerm: String
    public var nextQuestionType: QuestionType? // Only included when needed
    public let dueDate: Date? // Only included when needed
    
    public var id: Int { return cardId }
}

public enum QuestionType: Int, Codable, Equatable {
    case unspecified = 0
    case multipleChoice = 1
    case englishWritten = 2
    case foreignWritten = 3
}

public struct StudentSummary: Codable, Equatable {
    public let streakHistory: [StreakDay]
    public let streakLength: Int
    public let tasks: [TaskVm]
    public let enrollments: [EnrollmentVm]
    public let dailyPercentage: Double
    public let overdueMessage: String
    public let studentName: String
}

public struct StreakDay: Codable, Identifiable, Equatable {
    public let date: Date
    public let didAttempt: Bool
    
    public var id: Date { return date }
}

public struct TaskVm: Codable, Identifiable, Equatable {
    public let id: Int
    public let classId: Int
    public let deckId: Int
    public let className: String
    public let deckName: String
    public let dueDate: Date
    public var completion: Double? = nil // Only included when needed
}

public struct TaskSummary: Codable, Equatable {
    public let taskDetails: TaskVm
    public let cards: [Card]
}

public struct StatusResponse: Codable, Equatable {
    public let success: Bool
    public let message: String? // Only included when needed
}

public struct EnrollmentVm: Codable, Identifiable, Equatable {
    public let classId: Int
    public let className: String
    public let teacherName: String
    
    public var id: Int { return classId }
}
