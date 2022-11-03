import Foundation
import LanguagesAPI

class HomeController: ObservableObject {
    @Published private(set) var summary: StudentSummary? = nil
    private var isLoading = false
    
    func loadSummary() {
        guard !isLoading else { return }
        isLoading = true
        
        ErrorHandler.shared.detachAsync {
            guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
            let isNewStudent = try await LanguagesAPI.makeRequest(.isNewStudent(token: token))
            self.summary = try await LanguagesAPI.makeRequest(.summary(token: token))
            if isNewStudent {
                Navigator.shared.open(.onboarding)
            }
        }
    }
}
