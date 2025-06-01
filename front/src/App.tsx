// App.js

import {Route, BrowserRouter, Routes} from "react-router-dom";
import {HomePage} from "../pages/Home";
import {DashboardPage} from "../pages/Dashboard";

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<HomePage />} />
                <Route path="/dashboard" element={<DashboardPage />} />
            </Routes>
        </BrowserRouter>
    );
}

export default App;