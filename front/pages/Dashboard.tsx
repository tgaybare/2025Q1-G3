import {Link, Navigate} from "react-router-dom";


export function DashboardPage() {

    return (
        <div>
            <h2>Dashboard</h2>
            <p>Welcome, user!</p>

            <nav>
                <Link to="/">Home</Link> | <Link to="/dashboard">Dashboard</Link>
            </nav>
        </div>
    );
}
