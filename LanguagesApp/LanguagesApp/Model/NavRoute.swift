enum NavRoute: Equatable {
    case home
    case task(Int)
    case learning
    case settings
    case onboarding
    
    func isTask() -> Bool {
        if case .task(_) = self {
            return true
        }
        return false
    }
    
    func unwrapTaskId() -> Int? {
        if case .task(let id) = self {
            return id
        }
        return nil
    }
}