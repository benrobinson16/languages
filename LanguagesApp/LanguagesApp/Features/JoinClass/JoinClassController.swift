import Foundation
import LanguagesAPI

class JoinClassController: ObservableObject {
    @Published var joinCode = ""
    
    func cancel() {
        Navigator.shared.goHome()
    }
    
    func join() {
        let rgx = /^[0-9]{4}-[0-9]{4}$/
        
        guard joinCode.contains(rgx) else {
            AlertHandler.shared.show("Invalid join code.")
            return
        }
        
        ErrorHandler.shared.detachAsync {
            guard let token = Authenticator.shared.token else { throw AppError.notAuthenticated }
            let response = try await LanguagesAPI.makeRequest(.joinClass(joinCode: self.joinCode, token: token))
            if response.success {
                AlertHandler.shared.show("Success!", body: response.message ?? "You have been added to the class.")
            } else {
                AlertHandler.shared.show("Error", body: response.message ?? "An error ocurred when adding you to the class.")
            }
        }
    }
}
