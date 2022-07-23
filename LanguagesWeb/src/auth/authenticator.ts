import { InteractionRequiredAuthError, PublicClientApplication } from "@azure/msal-browser";
import { useMsal } from "@azure/msal-react";

const options = {
    auth: {
        clientId: '67d7b840-45a6-480b-be53-3d93c187ed66',
        // authority: "https://login.microsoftonline.com/common", <-- Do I need this?
        // redirectUri: "http://localhost:3000", <-- Do I need this?
    },
}

// Provides all logic for authenticating a user with Microsoft.
export const authenticator = {

    // The current instance of the application for MSAL to use.
    instance: new PublicClientApplication(options),

    // The current token. Do not use this directly. Use the get token function instead.
    token: null,

    // Gets the id token for the user, redirecting them to sign in if necessary.
    getToken: function (): Promise<string> {

        // If the token is cached, return it immediately to avoid a trip to the server.
        if (this.token != null) {
            return this.token;
        }

        const { instance, accounts } = useMsal();

        // Provide information to mMicrosoft so that they can handle the request.
        const accessTokenRequest = {
            scopes: ["api://67d7b840-45a6-480b-be53-3d93c187ed66/API.Access"],
            account: accounts[0]
        };

        // Wrap the callback in a promise so that it can be used with async/await.
        return new Promise((resolve, reject) => {
            instance.acquireTokenSilent(accessTokenRequest)
                .then(accessToken => {
                    
                    // Got the token successfully, now save and return.
                    let idToken = accessToken.idToken;
                    resolve(idToken);
                })
                .catch(error => {
                    
                    // An error has ocurred. Redirect if the user needs to manually sign in.
                    if (error instanceof InteractionRequiredAuthError) {
                        instance.acquireTokenRedirect(accessTokenRequest);
                    } else {
                        reject(error);
                    }
                });
        });
    }
}