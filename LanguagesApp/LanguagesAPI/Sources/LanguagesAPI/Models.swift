import Foundation

/// Represents an English/foreign language term pairing.
public struct Card: Codable, Identifiable, Equatable {
    public let cardId: Int
    public let englishTerm: String
    public let foreignTerm: String
    public var nextQuestionType: QuestionType? // Only included when needed
    public let dueDate: Date? // Only included when needed
    public var options: [String]? // Only included when needed
    
    public var id: Int { return cardId }
}

/// Represents a type of question to display to the user.
public enum QuestionType: Int, Codable, Equatable {
    case unspecified = 0
    case multipleChoice = 1
    case englishWritten = 2
    case foreignWritten = 3
    
    /// All question types that are possible.
    public static var questionTypes: [QuestionType] { [.multipleChoice, .englishWritten, .foreignWritten] }
}

/// Summary data for the student home page.
public struct StudentSummary: Codable, Equatable {
    public let streakHistory: [StreakDay]
    public let streakLength: Int
    public let tasks: [TaskVm]
    public let enrollments: [EnrollmentVm]
    public let dailyPercentage: Double
    public let overdueMessage: String
    public let studentName: String
}

/// Represents a single day in the student's streak history.
public struct StreakDay: Codable, Identifiable, Equatable {
    public let date: Date
    public let didAttempt: Bool
    
    /// Identifiable conformance.
    public var id: Date { return date }
}

/// Represents a task that has been assigned to the user.
public struct TaskVm: Codable, Identifiable, Equatable {
    public let id: Int
    public let classId: Int
    public let deckId: Int
    public let className: String
    public let deckName: String
    public let dueDate: Date
    public var completion: Double? = nil // Only included when needed
}

/// Data for the Task modal. Includes task details and the cards in the associated deck.
public struct TaskSummary: Codable, Equatable {
    public let taskDetails: TaskVm
    public let cards: [Card]
}

/// A standard server response indicating success or failure.
public struct StatusResponse: Codable, Equatable {
    public let success: Bool
    public let message: String? // Only included when needed
}

/// Represents a class the user has joined.
public struct EnrollmentVm: Codable, Identifiable, Equatable {
    public let classId: Int
    public let className: String
    public let teacherName: String
    
    /// Identifiable conformance.
    public var id: Int { return classId }
}

/// Summary data for the setting page.
public struct SettingsSummary: Codable, Equatable {
    public let name: String
    public let email: String
    public var reminderTime: Date
    public var dailyReminderEnabled: Bool
}
