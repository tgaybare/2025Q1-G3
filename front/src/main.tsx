import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { AuthProvider } from "react-oidc-context";

const cognitoAuthConfig = {
    authority: import.meta.env.VITE_AUTHORITY || "",
    client_id: import.meta.env.VITE_COGNITO_CLIENT_ID || "",
    redirect_uri: import.meta.env.VITE_REDIRECT_URI || "",
    response_type: "code",
    scope: "email openid profile",
};

const root = ReactDOM.createRoot(document.getElementById("root"));

// wrap the application with AuthProvider
root.render(
    <React.StrictMode>
        <AuthProvider {...cognitoAuthConfig}>
            <App />
        </AuthProvider>
    </React.StrictMode>
);