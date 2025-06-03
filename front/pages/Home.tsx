import {Link} from "react-router-dom";

export function HomePage() {

    return (
        <div>
            <button
                // onClick={() => window.location.href = `${import.meta.env.VITE_COGNITO_HOSTED_UI}?client_id=${import.meta.env.VITE_COGNITO_CLIENT_ID}&response_type=code&scope=openid+profile+email&redirect_uri=${encodeURIComponent(import.meta.env.VITE_REDIRECT_URI)}`}>Sign in
                onClick={() => window.location.href = `${import.meta.env.VITE_COGNITO_HOSTED_UI}`}>
                Sign In
            </button>
        </div>
    );
}
