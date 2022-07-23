import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

import { PublicClientApplication } from "@azure/msal-browser";
import { MsalProvider } from "@azure/msal-react";
import { Provider } from 'react-redux';
import store from "./redux/store";

const config = {
    auth: {
        clientId: '67d7b840-45a6-480b-be53-3d93c187ed66'
    }
};

const publicClientApplication = new PublicClientApplication(config);
const root = ReactDOM.createRoot(document.getElementById('root'));

root.render(
    <React.StrictMode>
        <Provider store={store}>
            <MsalProvider instance={publicClientApplication}>
                <App />
            </MsalProvider>
        </Provider>
    </React.StrictMode>
);