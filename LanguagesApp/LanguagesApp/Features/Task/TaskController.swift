import Foundation
import LanguagesAPI

/// View model for the ``TaskScreen``.
class TaskController: ObservableObject {
    @Published private(set) var summary: TaskSummary? = nil
    private var isLoading = false
    
    /// Gets the task summary.
    func loadSummary() {
        guard !isLoading else { return }
        isLoading = true
        
        ErrorHandler.shared.detachAsync { @MainActor in
            guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
            guard case .task(let taskId) = Navigator.shared.state else { throw AppError.unexpected }
            self.summary = try await LanguagesAPI.makeRequest(.taskDetails(id: taskId, token: token))
        } finally: {
            self.isLoading = false
        }
    }
    
    /// Closes the task view.
    func dismiss() {
        Navigator.shared.goHome()
        summary = nil
    }
}
