import { AuthenticationResult, Configuration, EventType, PublicClientApplication } from "@azure/msal-browser";

const options: Configuration = {
    auth: {
        clientId: '67d7b840-45a6-480b-be53-3d93c187ed66',
        authority: "https://login.microsoftonline.com/common",
        redirectUri: "http://localhost:3000/"
    }
}

// Provides all logic for authenticating a user with Microsoft.
class AuthService {

    /** The current instance of the application for MSAL to use. */
    instance: PublicClientApplication;

    /** Create the instance with the provided options. */
    constructor(options: Configuration) {
        this.instance = new PublicClientApplication(options)
    }

    /** Gets the id token for the user, redirecting them to sign in if necessary. */
    async getToken(): Promise<string> {
        const account = this.instance.getAllAccounts()[0];
        if (account == null) throw Error("Not authenticated.");
        
        // Provide information to Microsoft so that they can handle the request.
        const request = {
            scopes: ["api://67d7b840-45a6-480b-be53-3d93c187ed66/API.Access"],
            account: account
        };

        const response = await this.instance.acquireTokenSilent(request);
        return response.idToken;
    }

    /** Redirects the user to Microsoft's log-in page page. */
    async logIn() {
        
        // No need to redirect if already authenticated.
        if (this.instance.getAllAccounts().length > 0) {
            await this.getToken();
        }

        const request = {
            scopes: ["api://67d7b840-45a6-480b-be53-3d93c187ed66/API.Access"],
        };

        this.instance.loginRedirect(request);
    }

    /** Initiates a getToken call if accounts are already registered with the instance.
        This can be used to log a user in without redirecting them. */
    async getTokenIfAuthenticated(): Promise<string | null> {
        if (this.instance.getAllAccounts().length > 0) {
            return await this.getToken();
        }
        return null;
    }

    /** Logs the user out of their account. */
    async logOutRedirect() {
        await this.instance.logoutRedirect();
    }

    /** Registers a function to call when a redirect from log-in succeeds.
        The id token is passed to the callback function to be used. */
    registerLoginCallback(callback: (token: string) => void) {
        this.instance.addEventCallback((event) => {
            if ((event.eventType === EventType.ACQUIRE_TOKEN_SUCCESS || event.eventType === EventType.LOGIN_SUCCESS) && event.payload) {
                const result = event.payload as AuthenticationResult;
                callback(result.idToken);
            }
        });
    
        this.instance.handleRedirectPromise()
            .then(() => { })
            .catch(err => console.log(err));
    }

    /** Create the header for an API request. */
    async requestHeader(token: string | null) {
        const resolvedToken = token ?? await this.getToken();
        return {
            "Authorization": resolvedToken
        };
    }
}

export default new AuthService(options);