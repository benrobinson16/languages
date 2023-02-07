/// Represents a page in the application.
enum NavRoute: Equatable {
    case home
    case task(Int)
    case learning
    case settings
    case onboarding
    case joinClass
    case firstJoinClass
    
    /// Checks if the route is a task page.
    /// - Returns: Whether the route is a task page.
    func isTask() -> Bool {
        if case .task(_) = self {
            return true
        }
        return false
    }
    
    /// Gets the id of the task page from the enum payload.
    /// - Returns: The task id, or `nil` if not task page.
    func unwrapTaskId() -> Int? {
        if case .task(let id) = self {
            return id
        }
        return nil
    }
}
