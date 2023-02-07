import Foundation
import MSAL

/// Handles the auhtnetication process.
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
    
    /// Handles a response from Microsoft.
    /// - Parameter url: The response deep linked URL.
    func openUrl(url: URL) {
        MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
    }
    
    /// Connects the MSAL library to a view controller so that it can display the web view.
    /// - Parameter vc: The view controller to show the web view on.
    func connectToViewController(vc: UIViewController) {
        self.viewController = vc
    }
    
    /// Asynchronously gets an OAuth token, interactively communicating with the user if needed.
    /// - Parameter useCache: Whether to use the cache.
    /// - Returns: The OAuth token if authentication was successful.
    func getToken(useCache: Bool = true) async throws -> String {
        if useCache, let token = token {
            return token
        }
        
        return try await interactivelyAcquireToken()
    }
    
    /// Creates a task to interactively sign in.
    func signInDetached() {
        Task {
            do {
                _ = try await self.interactivelyAcquireToken()
            } catch {
                AlertHandler.shared.show("Could not sign in", body: "Please try again later.")
            }
        }
    }
    
    /// Creates a task to silently sign in.
    func signInSilentlyDetached() {
        Task {
            _ = try? await self.silentlyAcquireToken()
        }
    }
    
    /// Gets a token via a sign in view.
    /// - Returns: The OAuth token if authentication was successful.
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
    
    /// Gets a token in the background.
    /// - Returns: The OAuth token if authentication was successful.
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
    
    /// Creates a task to sign out of the account.
    func signOutDetached() {
        ErrorHandler.shared.detachAsync {
            try await self.signOut()
        }
    }
    
    /// Signs a user out of their Microsoft account.
    @MainActor
    func signOut() async throws {
        try await Notifier.shared.removeDeviceToken()
        
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
