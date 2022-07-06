import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

import { PublicClientApplication } from "@azure/msal-browser";
import { MsalProvider } from "@azure/msal-react";

const config = {
    auth: {
        clientId: '67d7b840-45a6-480b-be53-3d93c187ed66',
        // authority: "https://login.microsoftonline.com/common",
        // redirectUri: "http://localhost:3000",
    },
    // cache: {
    //     cacheLocation: "sessionStorage",
    //     storeAuthStateInCookie: false
    // },
};

const publicClientApplication = new PublicClientApplication(config);
const root = ReactDOM.createRoot(document.getElementById('root'));

root.render(
    <React.StrictMode>
        <MsalProvider instance={publicClientApplication}>
            <App />
        </MsalProvider>
    </React.StrictMode>
);