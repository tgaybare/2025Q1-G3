import { useAuth } from "react-oidc-context";
import {Link, Navigate} from "react-router-dom";


export function DashboardPage() {
    const auth = useAuth();

    if (!auth.isAuthenticated) {
        return <Navigate to="/" />;
    }

    return (
        <div>
            <h2>Dashboard</h2>
            <p>Welcome, {auth.user?.profile.email}!</p>

            <nav>
                <Link to="/">Home</Link> | <Link to="/dashboard">Dashboard</Link>
            </nav>
        </div>
    );
}
