import { Configuration, InteractionRequiredAuthError, PublicClientApplication } from "@azure/msal-browser";

const options: Configuration = {
    auth: {
        clientId: '67d7b840-45a6-480b-be53-3d93c187ed66',
        authority: "https://login.microsoftonline.com/common",
        redirectUri: "http://localhost:3000"
    }
}

// Provides all logic for authenticating a user with Microsoft.
class AuthService {

    // The current instance of the application for MSAL to use.
    instance: PublicClientApplication;

    // Create the instance with the provided options.
    constructor(options: Configuration) {
        this.instance = new PublicClientApplication(options)
    }

    // Gets the id token for the user, redirecting them to sign in if necessary.
    async getToken(): Promise<string> {

        // Provide information to mMicrosoft so that they can handle the request.
        const accessTokenRequest = {
            scopes: ["api://67d7b840-45a6-480b-be53-3d93c187ed66/API.Access"],
            account: this.instance.getAllAccounts()[0]
        };

        // Wrap the callback in a promise so that it can be used with async/await.
        return new Promise((resolve, reject) => {
            this.instance.acquireTokenSilent(accessTokenRequest)
                .then(accessToken => {
                    
                    // Got the token successfully, now return.
                    let idToken = accessToken.idToken;
                    resolve(idToken);
                })
                .catch(error => {
                    
                    // An error has ocurred. Redirect if the user needs to manually sign in.
                    if (error instanceof InteractionRequiredAuthError) {
                        this.instance.acquireTokenRedirect(accessTokenRequest);
                    } else {
                        reject(error);
                    }
                });
        });
    }

    // Create the header for an API request
    async requestHeader(token: string | null) {
        const resolvedToken = token ?? await this.getToken();
        return {
            "Authorization": resolvedToken
        };
    }
}

export default new AuthService(options);