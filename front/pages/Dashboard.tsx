// import React, { useEffect, useState } from "react";
// import { Link } from "react-router-dom";

// export function DashboardPage() {
//     const [data, setData] = useState(null);
//     const [loading, setLoading] = useState(true);
//     const [error, setError] = useState(null);

//     useEffect(() => {
//         const fetchData = async () => {
//             try {
//                 const response = await fetch(import.meta.env.VITE_REST_API_URL);
//                 if (!response.ok) {
//                     throw new Error(`HTTP error! status: ${response.status}`);
//                 }
//                 const result = await response.json();
//                 setData(result);
//             } catch (err) {
//                 setError(err.message);
//             } finally {
//                 setLoading(false);
//             }
//         };

//         fetchData();
//     }, []);

//     return (
//         <div>
//             <h2>Dashboard</h2>
//             <p>Welcome, user!</p>

//             {loading && <p>Loading...</p>}
//             {error && <p>Error: {error}</p>}
//             {data && (
//                 <div>
//                     <h3>Results:</h3>
//                     <pre>{JSON.stringify(data, null, 2)}</pre>
//                 </div>
//             )}

//             <nav>
//                 <Link to="/">Home</Link> | <Link to="/dashboard">Dashboard</Link>
//             </nav>
//         </div>
//     );
// }
