import Foundation
import UIKit

struct AuthInteractor {
    let appState: AppState
    let msal = MSAuthManager()
    
    func signInSilently() {
        guard !appState.auth.isAuthenticating else { return }
        appState.auth.isAuthenticating = true
        
        Task { @MainActor in
            do {
                appState.auth.token = try await msal.silentlyAcquireToken()
            } catch {
                // Ignore error
            }
            appState.auth.isAuthenticating = false
        }
    }
    
    func signIn() {
        guard !appState.auth.isAuthenticating else { return }
        appState.auth.isAuthenticating = true
        
        Task { @MainActor in
            do {
                appState.auth.token = try await msal.acquireToken()
            } catch {
                appState.error = "Failed to authenticate with Microsoft. Please try again."
            }
            appState.auth.isAuthenticating = false
        }
    }
    
    func signOut() {
        guard !appState.auth.isAuthenticating else { return }
        appState.auth.isAuthenticating = true
        
        Task { @MainActor in
            do {
                try await msal.signOut()
                appState.auth.token = nil
            } catch {
                appState.error = "Failed to sign out. Please try again."
            }
            appState.auth.isAuthenticating = false
        }
    }
    
    func openUrl(url: URL) {
        msal.openUrl(url: url)
    }
    
    func connectToViewController(vc: UIViewController) {
        msal.connectToViewController(vc: vc)
    }
}

