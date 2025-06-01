import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { AuthProvider } from "react-oidc-context";

const cognitoAuthConfig = {
    authority: "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_KDVROpMKt",
    client_id: "539qi4hbt6km9hd52u1mhrvl24",
    redirect_uri: "https://d84l1y8p4kdic.cloudfront.net",
    response_type: "code",
    scope: "phone openid email",
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