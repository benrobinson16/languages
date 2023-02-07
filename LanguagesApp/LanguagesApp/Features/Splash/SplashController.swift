import Foundation
import UIKit

/// Controller for the splash screen.
class SplashController: ObservableObject {
    /// Silently attempt to sign in. This should be called when the screen is opened.
    func signInSilently() {
        guard let vc = UIApplication.shared.topViewController else { return }
        Authenticator.shared.connectToViewController(vc: vc)
        Authenticator.shared.signInSilentlyDetached()
    }
    
    /// Attempt to sign in via a web view. This should be called when the Sign In button is tapped.
    func signIn() {
        guard let vc = UIApplication.shared.topViewController else { return }
        Authenticator.shared.connectToViewController(vc: vc)
        Authenticator.shared.signInDetached()
    }
}
