import { InteractionType, InteractionStatus, InteractionRequiredAuthError } from "@azure/msal-browser";
import { MsalAuthenticationTemplate, useMsal } from "@azure/msal-react";
import { useState, useEffect } from "react";

function WelcomeUser() {
    const { accounts } = useMsal();
    const username = accounts[0].username;
  
    return <p>Welcome, {username}</p>
}

function App() {
    return (
        <>
            <p>Hello</p>
            <MsalAuthenticationTemplate interactionType={InteractionType.Redirect}>
                <p>This will only render if a user is signed-in.</p>
                <WelcomeUser />
                <ProtectedComponent />
            </MsalAuthenticationTemplate>
        </>
    );
}

export default App;

function ProtectedComponent() {
    const { instance, inProgress, accounts } = useMsal();
    const [apiData, setApiData] = useState(null);

    console.log("PROTECTED");
    
    useEffect(() => {
        const accessTokenRequest = {
            scopes: ["api://67d7b840-45a6-480b-be53-3d93c187ed66/API.Access"],
            account: accounts[0]
        }

        console.log("REQUEST");

        if (!apiData && inProgress === InteractionStatus.None) {
            instance.acquireTokenSilent(accessTokenRequest).then((accessTokenResponse) => {
                // Acquire token silent success
                let accessToken = accessTokenResponse.accessToken;
                console.log(accessToken);
                console.log("HELLO");
                // Call your API with token
                let headers = new Headers();
                let bearer = "Bearer " + accessToken;
                headers.append("Authorization", bearer);
                headers.append("Content-Type", "application/json");
                let options = {
                    method: "GET",
                    headers: headers,
                };
                let graphEndpoint = "https://localhost:7255/student/reviewcards";
                fetch(graphEndpoint, options)
                    .then(async function (response) {
                        const textResponse = await response.text()
                        setApiData(textResponse);
                        console.log(textResponse);
                    })
                    .catch((error) => console.log(error ?? "unknown error"));
            }).catch((error) => {
                console.log("ERROR");
                if (error instanceof InteractionRequiredAuthError) {
                    instance.acquireTokenRedirect(accessTokenRequest);
                }
                console.log(error);
            })
        }
    }, [instance, accounts, inProgress, apiData]);

    return <p>Return your protected content here: {apiData}</p>
}