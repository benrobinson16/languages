import Foundation
import LanguagesAPI
import Combine

class HomeController: ObservableObject {
    @Published private(set) var summary: StudentSummary? = nil
    private var isLoading = false
    private var subscription: AnyCancellable? = nil
    
    private func subscribe() {
        subscription = NotificationCenter.default
            .publisher(for: .refreshData)
            .sink { _ in
                self.loadSummary()
            }
    }
    
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
            Notifier.shared.registerForPushNotifications()
        }
    }
    
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
    
    func joinClass() {
        Navigator.shared.open(.joinClass)
    }
    
    func signOut() {
        ErrorHandler.shared.detachAsync {
            try await Authenticator.shared.signOut()
        }
    }
}
