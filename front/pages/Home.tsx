import { useAuth } from "react-oidc-context";
import {Link} from "react-router-dom";

export function HomePage() {
    const auth = useAuth();

    const signOutRedirect = () => {
        const clientId = "4n6ubup1slfbd4u1j0qns8i2r7";
        const logoutUri = "<logout uri>";
        const cognitoDomain = "https://<user pool domain>";
        window.location.href = `${cognitoDomain}/logout?client_id=${clientId}&logout_uri=${encodeURIComponent(logoutUri)}`;
    };

    if (auth.isLoading) {
        return <div>Loading...</div>;
    }

    if (auth.error) {
        return <div>Encountering error... {auth.error.message}</div>;
    }

    if (auth.isAuthenticated) {
        return (
            <div>
                <h2>Home</h2>
                <pre> Hello: {auth.user?.profile.email} </pre>
                <pre> ID Token: {auth.user?.id_token} </pre>
                <pre> Access Token: {auth.user?.access_token} </pre>
                <pre> Refresh Token: {auth.user?.refresh_token} </pre>

                <nav>
                    <Link to="/">Home</Link> | <Link to="/dashboard">Dashboard</Link>
                </nav>

                <button onClick={() => auth.removeUser()}>Sign out</button>
            </div>
        );
    }

    return (
        <div>
            <button onClick={() => auth.signinRedirect()}>Sign in</button>
            <button onClick={() => signOutRedirect()}>Sign out</button>
        </div>
    );
}
