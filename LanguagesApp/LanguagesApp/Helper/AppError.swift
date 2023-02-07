import Foundation

/// Represents an error thrown by the application.
enum AppError: Error {
    case notAuthenticated
    case noConnection
    case unexpected
}

extension AppError {
    public var description: String {
        switch self {
        case .notAuthenticated:
            return "You are not signed in."
        case .noConnection:
            return "Could not connect to the server. Please check your internet connection and try again."
        case .unexpected:
            return "An unexpected error occurred."
        }
    }
}
