import Foundation
import UIKit

class SplashController: ObservableObject {
    func signIn() {
        guard let vc = UIApplication.shared.topViewController else { return }
        Authenticator.shared.connectToViewController(vc: vc)
        Authenticator.shared.signInDetached()
    }
}
