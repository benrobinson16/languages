import Foundation
import LanguagesAPI

class HomeController: ObservableObject {
    @Published private(set) var summary: StudentSummary? = nil
    private var isLoading = false
    
    func loadSummary() {
        guard !isLoading else { return }
        isLoading = true
        
        ErrorHandler.shared.detachAsync { @MainActor in
            guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
            let isNewStudent = try await LanguagesAPI.makeRequest(.isNewStudent(token: token))
            if isNewStudent {
                Navigator.shared.open(.onboarding)
            }
            self.summary = try await LanguagesAPI.makeRequest(.summary(token: token))
        } finally: {
            self.isLoading = false
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