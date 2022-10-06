import Foundation
import MSAL

class MSAuthManager: ObservableObject {
    private let clientId = ""
    private var accountId: String?
    private var viewController: UIViewController?
    private let msal: MSALPublicClientApplication
    
    @Published private(set) var token: String?
    
    init?() {
        let config = MSALPublicClientApplicationConfig(clientId: clientId)
        let application = try? MSALPublicClientApplication(configuration: config)
        guard let application else { return nil }
        self.msal = application
    }
    
    func openUrl(url: URL) {
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
    }
    
    func connectToViewController(vc: UIViewController) {
        self.viewController = vc
    }
    
    func detachedAcquireToken() {
        Task.detached {
            do {
                _ = try await self.acquireToken()
            } catch {
                // FIXME: Error reporting
            }
        }
    }
    
    func acquireToken() async throws -> String {
        if accountId != nil {
            do {
                return try await silentlyAcquireToken()
            } catch {
                // Continue below to try interactively
            }
        }
        
        return try await interactivelyAcquireToken()
    }
    
    func interactivelyAcquireToken() async throws -> String {
        guard let viewController else { throw AuthError.noViewController }
        let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        let interactiveParameters = MSALInteractiveTokenParameters(scopes: ["FIXME FIXME FIXME"], webviewParameters: webviewParameters)
        let result = try await msal.acquireToken(with: interactiveParameters)
        guard let idToken = result.idToken else { throw AuthError.noIdToken }
        
        self.accountId = result.account.identifier
        self.token = idToken
        
        return idToken
    }
    
    func silentlyAcquireToken() async throws -> String {
        guard let accountId else { throw AuthError.noAccount }
        
        let account = try msal.account(forIdentifier: accountId)
        let silentParameters = MSALSilentTokenParameters(scopes: ["FIXME FIXME FIXME"], account: account)
        let result = try await msal.acquireTokenSilent(with: silentParameters)
        guard let idToken = result.idToken else { throw AuthError.noIdToken }
        
        self.token = idToken
        
        return idToken
    }
    
    func detachedSignOut() {
        Task.detached {
            do {
                try await self.signOut()
            } catch {
                // FIXME: Error reporting
            }
        }
    }
    
    func signOut() async throws {
        guard let accountId else { throw AuthError.noAccount }
        let account = try msal.account(forIdentifier: accountId)
        
        guard let viewController else { throw AuthError.noViewController }
        let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        let signoutParameters = MSALSignoutParameters(webviewParameters: webviewParameters)
        signoutParameters.signoutFromBrowser = false
        
        let success = try await msal.signout(with: account, signoutParameters: signoutParameters)
        guard success else { throw AuthError.failedToSignOut }
        
        self.accountId = nil
        self.token = nil
    }
    
    enum AuthError: Error {
        case noIdToken
        case noAccount
        case noViewController
        case failedToSignOut
    }
}
