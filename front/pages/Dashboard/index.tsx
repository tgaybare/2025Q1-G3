import  { useState, useEffect } from 'react';
import { useHistoricalData } from './../../src/utils/useHistoricalData.ts';
import { getAlertStatus } from './../../src/utils/getAlertStatus.ts';
import { Activity as ActivityIcon } from 'lucide-react';
import { MetricCard } from '../../src/components/MetricCard/index.tsx';
import { CPUChart } from './../../src/components/CPUChart';
import { MemoryPieChart } from './../../src/components/MemoryPieChart';
import { Cpu, MemoryStick, Activity, HardDrive, Server } from 'lucide-react';
import { HostSelector } from './../../src/components/HostSelector';
import { HostManager } from './../../src/components/HostManager'; // import path depends on your file structure

import './styles.css';

interface MetricEntry {
  value: number | null;
  timestamp: string | null;
}

interface MetricData {
  ip: string;
  // now metrics is an array of strings for display
  metrics: string[];
}

export function Dashboard() {
    const [metrics, setMetrics] = useState<MetricData[]>([]);
    const [hosts, setHosts] = useState<string[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const authToken = new URLSearchParams(window.location.search).get("authToken");
    const email = new URLSearchParams(window.location.search).get("email");
    const apiUrl = import.meta.env.VITE_REST_API_URL;

    useEffect(() => {
        fetchData();
    }, []);

    async function fetchData() {
        try {
            setLoading(true);
            setError(null);

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

            const raw = await metricsResponse.json();
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

    async function handleCreateHost(newHost: string, newIp: string) {
        console.log("Creating host:", newHost, newIp);
        if (!newHost || !newIp) {
            setError("Host name and IP address are required");
            return;
        }
        try {
            setError(null);
            const response = await fetch(`${apiUrl}/create_host`, {
                method: "POST",
                headers: {
                    Authorization: `Bearer ${authToken}`,
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    ip: newIp,
                    hostname: newHost,
                    email: decodeURIComponent(email ?? ""),
                }),
            });
            if (!response.ok) throw new Error("Failed to create host");
            alert("Host created!");

            await fetchData();
        } catch (err: any) {
            setError(err.message || "Unknown error");
        }
    }
    const historicalData = useHistoricalData();
    const [selectedHost, setSelectedHost] = useState(() => hosts[0]?.ip || '');
    function getMetricValue(metricName: string): number {
        const match = currentMetrics.find(m => m.startsWith(`${metricName}:`));
        if (!match) return 0;
        const parts = match.split(": ");
        return parseFloat(parts[1]) || 0;
    }

    const currentMetrics = metrics.find(m => m.ip === selectedHost)?.metrics || [];
    const total = getMetricValue("Total Memory");
    const available = getMetricValue("Available Memory");

    const used = total - available;
    const usagePercent = (used / total) * 100;
    
    console.log("Current Metrics:", currentMetrics);
    const memoryPieData = [
        { name: 'Used', value: usagePercent, fill: '#ef4444' },
        { name: 'Available', value: 100 - usagePercent, fill: '#10b981' }
    ];

   const handleAddHost = (hostObj: { name: string; ip: string; }) => {
    handleCreateHost(hostObj.name, hostObj.ip);
};


    return (
        <div className="dashboard-container">
            <div className="dashboard-header">
            <div className="host-info">
                <div className="host-icon"><Server size={32} color="#60a5fa" /></div>
                <div>
                <h1>System Monitor</h1>
                {hosts.length > 0 && <p>Host: {selectedHost}</p>}
                </div>
            </div>
            <div className="live-status"><div className="pulse-dot" /><span>Live</span></div>
            </div>

            {hosts.length === 0 ? (
            <div>
                <HostManager onAddHost={handleAddHost} />
                <div className="empty-message">
                <h2>No Hosts Available</h2>
                <p>Start monitoring your infrastructure by adding a host above.</p>
                </div>
            </div>
            ) : (
            <>
                <div className="host-list">
                {hosts.map((host, idx) => (
                    <div
                    key={idx}
                    className={`host-card ${selectedHost === host ? 'selected' : ''}`}
                    onClick={() => setSelectedHost(host)}
                    style={{ cursor: 'pointer' }}
                    >
                    <h2>{host}</h2>
                    <p>{host}</p>
                    </div>
                ))}
                </div>
                <div className="host-manager-container">
                    <HostManager onAddHost={handleAddHost} />
                </div>

                <div className="metric-grid">
                    <MetricCard
                        title="CPU Utilization"
                        value={
                            getMetricValue("CPU Utilization") > 0
                                ? getMetricValue("CPU Utilization")
                                : "No CPU usage"
                        }
                        unit={getMetricValue("CPU Utilization") > 0 ? "%" : ""}
                        icon={Cpu}
                        statusData={
                            getMetricValue("CPU Utilization") > 0
                                ? getAlertStatus("CPU Utilization", getMetricValue("CPU Utilization"))
                                : { status: "unknown", color: "#6b7280", icon: ActivityIcon, tooltip: "No CPU usage" }
                        }
                    />

                    <MetricCard
                        title="Memory Usage"
                        value={
                            usagePercent && usagePercent > 0
                                ? usagePercent.toFixed(1)
                                : "No memory usage"
                        }
                        unit={usagePercent && usagePercent > 0 ? "%" : ""}
                        icon={MemoryStick}
                        statusData={
                            usagePercent && usagePercent > 0
                                ? getAlertStatus("Available Memory", available, total)
                                : { status: "unknown", color: "#6b7280", icon: ActivityIcon, tooltip: "No memory usage" }
                        }
                    />

                    <MetricCard
                        title="Active Processes"
                        value={
                            getMetricValue("Active Processes") > 0
                                ? getMetricValue("Active Processes")
                                : "No active processes"
                        }
                        unit={getMetricValue("Active Processes") > 0 ? "proc" : ""}
                        icon={ActivityIcon}
                        statusData={
                            getMetricValue("Active Processes") > 0
                                ? getAlertStatus("Active Processes", getMetricValue("Active Processes"))
                                : { status: "unknown", color: "#6b7280", icon: ActivityIcon, tooltip: "No active processes" }
                        }
                    />

                    <MetricCard
                        title="Free Swap Space"
                        value={
                            getMetricValue("Free Swap Space") && getMetricValue("Free Swap Space") > 0
                                ? getMetricValue("Free Swap Space")
                                : "No swap space"
                        }
                        unit={getMetricValue("Free Swap Space") && getMetricValue("Free Swap Space") > 0 ? "MB" : ""}
                        icon={HardDrive}
                        statusData={
                            getMetricValue("Free Swap Space") && getMetricValue("Free Swap Space") > 0
                                ? getAlertStatus("Free Swap Space", getMetricValue("Free Swap Space"))
                                : { status: "unknown", color: "#6b7280", icon: ActivityIcon, tooltip: "No swap space" }
                        }
                    />
                </div>

                <div className="chart-section">
                    <CPUChart data={historicalData} />
                    <MemoryPieChart data={memoryPieData} />
                </div>
            </>
            )}
        </div>
    );

}