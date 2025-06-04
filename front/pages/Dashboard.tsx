import { Link } from "react-router-dom";
import { useEffect, useState } from "react";
import React from "react";

interface MetricEntry {
  value: number | null;
  timestamp: string | null;
}

interface MetricData {
  ip: string;
  // now metrics is an array of strings for display
  metrics: string[];
}

export function DashboardPage() {
  const [metrics, setMetrics] = useState<MetricData[]>([]);
  const [hosts, setHosts] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const authToken = new URLSearchParams(window.location.search).get("authToken");
  const email = new URLSearchParams(window.location.search).get("email");
  const apiUrl = import.meta.env.VITE_REST_API_URL;

  async function fetchData() {
    try {
      setLoading(true);
      setError(null);

      // 1) Fetch hosts by email
      const hostsResponse = await fetch(
        `${apiUrl}/get_hosts_by_user_email?userEmail=${encodeURIComponent(email ?? "")}`,
        { headers: { Authorization: `Bearer ${authToken}` } }
      );
      if (!hostsResponse.ok) throw new Error("Failed to fetch hosts");

      const hostsData: any[] = await hostsResponse.json();
      // HostsData might look like: [{ ip: { S: "1.2.3.4" } }, …]
      const plainHosts: string[] = hostsData.map((h) => h.ip.S);
      setHosts(plainHosts);

      // 2) For each host, fetch its metrics
      const metricsData: MetricData[] = [];
      for (const ip of plainHosts) {
        const metricsResponse = await fetch(
          `${apiUrl}/get_metrics?host_ip=${encodeURIComponent(ip)}`,
          { headers: { Authorization: `Bearer ${authToken}` } }
        );
        if (!metricsResponse.ok) throw new Error("Failed to fetch metrics for " + ip);

        // Parse JSON once
        const raw = await metricsResponse.json();
        //
        // raw looks like:
        //   { host_ip: "134.209.128.100",
        //     metrics: { "CPU Utilization": {value:null,timestamp:null}, … }
        //   }
        //
        const metricsObj: Record<string, MetricEntry> = raw.metrics;

        // Convert the metrics object into an array of strings
        // e.g. [ "CPU Utilization: null", "Available Memory: null", ... ]
        const metricsArray: string[] = Object.entries(metricsObj).map(
          ([key, entry]) => `${key}: ${entry.value ?? "N/A"}`
        );

        metricsData.push({ ip, metrics: metricsArray });
      }

      setMetrics(metricsData);
    } catch (err: any) {
      setError(err.message || "Unknown error");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchData();
  }, [apiUrl, authToken, email]);

  async function handleCreateHost() {
    try {
      setError(null);
      const response = await fetch(`${apiUrl}/create_host`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${authToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          ip: "134.209.128.100",
          hostname: "examplffe",
          email: decodeURIComponent(email ?? ""),
        }),
      });
      if (!response.ok) throw new Error("Failed to create host");
      alert("Host created!");

      // Re-run the fetch so the new host & its metrics appear
      await fetchData();
    } catch (err: any) {
      setError(err.message || "Unknown error");
    }
  }

  return (
    <div>
      <h2>Dashboard</h2>
      <p>Welcome, user!</p>
      <nav>
        <Link to="/">Home</Link> | <Link to="/dashboard">Dashboard</Link>
      </nav>
      <button onClick={handleCreateHost}>Create Host</button>

      {loading && <p>Loading...</p>}
      {error && <p style={{ color: "red" }}>{error}</p>}

      <h3>Your Hosts:</h3>
      <ul>
        {hosts.map((ip) => (
          <li key={ip}>{ip}</li>
        ))}
      </ul>

      <h3>Metrics:</h3>
      <ul>
        {metrics.map(({ ip, metrics }) => (
          <li key={ip}>
            <strong>{ip}:</strong> {metrics.join(", ")}
          </li>
        ))}
      </ul>
    </div>
  );
}
