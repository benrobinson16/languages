import Foundation
import MSAL

class MSAuthManager {
    init() {
        let config = MSALPublicClientApplicationConfig(clientId: clientId)
        let application = try! MSALPublicClientApplication(configuration: config)
        self.msal = application
    }
    
    private let clientId = "67d7b840-45a6-480b-be53-3d93c187ed66"
    private let scopes = ["api://67d7b840-45a6-480b-be53-3d93c187ed66/API.Access"]
    private var accountId: String?
    private var viewController: UIViewController?
    private let msal: MSALPublicClientApplication
    
    func openUrl(url: URL) {
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
    }
    
    func connectToViewController(vc: UIViewController) {
        self.viewController = vc
    }
    
    func acquireToken() async throws -> String {
        if accountId != nil {
            do {
                return try await silentlyAcquireToken()
            } catch {
                print(error)
                // Continue below to try interactively
            }
        }
        
        return try await interactivelyAcquireToken()
    }
    
    @MainActor
    func interactivelyAcquireToken() async throws -> String {
        guard let viewController else { throw AuthError.noViewController }
        let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        let interactiveParameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webviewParameters)
        let result = try await msal.acquireToken(with: interactiveParameters)
        guard let idToken = result.idToken else { throw AuthError.noIdToken }
        
        self.accountId = result.account.identifier
        
        return idToken
    }
    
    @MainActor
    func silentlyAcquireToken() async throws -> String {
        guard let accountId else { throw AuthError.noAccount }
        
        let account = try msal.account(forIdentifier: accountId)
        let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account)
        let result = try await msal.acquireTokenSilent(with: silentParameters)
        guard let idToken = result.idToken else { throw AuthError.noIdToken }
        
        return idToken
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
    }
    
    enum AuthError: Error {
        case noIdToken
        case noAccount
        case noViewController
        case failedToSignOut
    }
}
