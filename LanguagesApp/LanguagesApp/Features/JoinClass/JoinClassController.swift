import Foundation
import LanguagesAPI

/// Controller for the join class alert.
class JoinClassController: ObservableObject {
    @Published var joinCode = ""
    
    func cancel() {
        Navigator.shared.goHome()
    }
    
    func join() {
        // Regular expression in Swift syntax to check join code format.
        let rgx = /^[0-9]{4}-[0-9]{4}$/
        
        guard joinCode.contains(rgx) else {
            AlertHandler.shared.show("Invalid join code.")
            return
        }
        
        Navigator.shared.goHome()
        ErrorHandler.shared.detachAsync {
            guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
            let response = try await LanguagesAPI.makeRequest(.joinClass(joinCode: self.joinCode, token: token))
            if response.success {
                NotificationCenter.default.post(name: .refreshData, object: nil)
                AlertHandler.shared.show("Success!", body: response.message ?? "You have been added to the class.")
                DispatchQueue.main.async {
                    self.joinCode = ""
                }
            } else {
                AlertHandler.shared.show(response.message ?? "An unknown error occurred.")
                Navigator.shared.open(.joinClass)
            }
        }
    }
}
