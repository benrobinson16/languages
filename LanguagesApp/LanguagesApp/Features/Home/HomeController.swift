import Foundation
import LanguagesAPI
import Combine

/// Controller for the home page.
class HomeController: ObservableObject {
    @Published private(set) var summary: StudentSummary? = nil
    private var isLoading = false
    private var subscription: AnyCancellable? = nil
    
    /// Subscribe to internal notifications telling the home screen to reload data.
    private func subscribe() {
        subscription = NotificationCenter.default
            .publisher(for: .refreshData)
            .sink { _ in
                self.loadSummary()
            }
    }
    
    /// Get summary information from the server.
    func loadSummary() {
        guard !isLoading else { return }
        isLoading = true
        
        if subscription == nil { subscribe() }
        
        ErrorHandler.shared.detachAsync { @MainActor in
            guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
            let isNewStudent = try await LanguagesAPI.makeRequest(.register(token: token))
            if isNewStudent {
                Navigator.shared.open(.onboarding)
            } else {
                await Notifier.shared.askForPermissionIfNeeded()
            }
            self.summary = try await LanguagesAPI.makeRequest(.summary(token: token))
        } finally: {
            self.isLoading = false
            
            // Finish by ensuring push notifications are set up.
            Notifier.shared.registerForPushNotifications()
        }
    }
    
    /// Leave a class.
    /// - Parameter classId: The class id to leave.
    func leaveClass(_ classId: Int) {
        AlertHandler.shared.show(
            "Leave Class",
            body: "You will be removed from this class.",
            option1: .init(
                name: "Cancel",
                action: { Navigator.shared.goHome() }
            ),
            option2: .init(
                name: "Leave",
                action: {
                    ErrorHandler.shared.detachAsync {
                        guard let token = Authenticator.shared.token else { return }
                        let response = try await LanguagesAPI.makeRequest(.leaveClass(classId: classId, token: token))
                        ErrorHandler.shared.handleResponse(response)
                        self.loadSummary()
                    }
                }
            ))
    }
    
    /// Opens the join class alert.
    func joinClass() {
        Navigator.shared.open(.joinClass)
    }
}
