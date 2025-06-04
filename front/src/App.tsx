// App.js

import {Route, BrowserRouter, Routes} from "react-router-dom";
import {HomePage} from "../pages/Home/index";
import {Dashboard} from "../pages/Dashboard/index";

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<HomePage />} />
                <Route path="/dashboard" element={<Dashboard />} />
            </Routes>
        </BrowserRouter>
    );
}

export default App;