import Foundation
import LanguagesAPI

class TaskController: ObservableObject {
    @Published private(set) var summary: TaskSummary? = nil
    private var isLoading = false
    
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
    
    func dismiss() {
        Navigator.shared.goHome()
        summary = nil
    }
}
