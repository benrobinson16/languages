import Foundation
import MSAL

class Authenticator: ObservableObject {
    private let accountIdKey = "msal.auth.account.id"
    private let clientId = "67d7b840-45a6-480b-be53-3d93c187ed66"
    private let scopes = ["api://67d7b840-45a6-480b-be53-3d93c187ed66/API.Access"]
    private var viewController: UIViewController?
    private let msal: MSALPublicClientApplication
    
    private var accountId: String? {
        get {
            return UserDefaults.standard.string(forKey: accountIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: accountIdKey)
        }
    }
    
    @Published var token: String?
    
    // Use a singleton instance because same token needed everywhere.
    static let shared = Authenticator()
    
    private init() {
        let config = MSALPublicClientApplicationConfig(clientId: clientId)
        let application = try! MSALPublicClientApplication(configuration: config)
        self.msal = application
    }
    
    func openUrl(url: URL) {
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
    }
    
    func connectToViewController(vc: UIViewController) {
        self.viewController = vc
    }
    
    func getToken(useCache: Bool = true) async throws -> String {
        if useCache, let token = token {
            return token
        }
        
        return try await interactivelyAcquireToken()
    }
    
    func signInDetached() {
        ErrorHandler.shared.detachAsync {
            _ = try await self.interactivelyAcquireToken()
        }
    }
    
    func signInSilentlyDetached() {
        Task {
            _ = try? await self.silentlyAcquireToken()
        }
    }
    
    @MainActor
    private func interactivelyAcquireToken() async throws -> String {
        guard let viewController else { throw AuthError.noViewController }
        let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        let interactiveParameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webviewParameters)
        let result = try await msal.acquireToken(with: interactiveParameters)
        guard let idToken = result.idToken else { throw AuthError.noIdToken }
        
        self.accountId = result.account.identifier
        self.token = idToken
        
        return idToken
    }
    
    @MainActor
    private func silentlyAcquireToken() async throws -> String {
        guard let accountId else { throw AuthError.noAccount }
        
        let account = try msal.account(forIdentifier: accountId)
        let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account)
        let result = try await msal.acquireTokenSilent(with: silentParameters)
        guard let idToken = result.idToken else { throw AuthError.noIdToken }
        
        self.token = idToken
        
        return idToken
    }
    
    @MainActor
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
