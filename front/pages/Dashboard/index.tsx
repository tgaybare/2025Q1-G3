import React, { useState, useEffect } from 'react';
import {
    LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
    PieChart, Pie, Cell
} from 'recharts';
import {
    Activity, Server, AlertTriangle, CheckCircle, XCircle,
    Cpu, MemoryStick, HardDrive
} from 'lucide-react';
import "./styles.css";

export function Dashboard() {
    type HistoricalDataPoint = {
        time: string;
        cpu: number;
        memory: number;
        processes: number;
    };
    //const [historicalData, setHistoricalData] = useState<HistoricalDataPoint[]>([]);

    /*useEffect(() => {
        fetch('api/metrics') // Replace with your actual API endpoint
            .then(response => response.json())
            .then(data => {
                if (data.statusCode === 200) {
                    setCurrentData(data.body);
                }
            });

        const interval = setInterval(() => {
            setHistoricalData(prev => {
                const newData = [...prev.slice(1)];
                newData.push({
                    time: new Date().toLocaleTimeString(),
                    cpu: Math.random() * 40 + 15,
                    memory: Math.random() * 30 + 50,
                    processes: Math.floor(Math.random() * 5) + 1
                });
                return newData;
            });
        }, 3000);

        return () => clearInterval(interval);
    }, []);*/
    const [currentData, setCurrentData] = useState({
        host_ip: "192.168.1.1",
        metrics: {
            "CPU Utilization": { value: 45.5, timestamp: "2023-10-01 12:34:56" },
            "Available Memory": { value: 2048, timestamp: "2023-10-01 12:34:56" },
            "Total Memory": { value: 8192, timestamp: "2023-10-01 12:34:56" },
            "Free Swap Space": { value: 1024, timestamp: "2023-10-01 12:34:56" },
            "Number of Processes Running": { value: 150, timestamp: "2023-10-01 12:34:56" }
        }
    });
    const [historicalData, setHistoricalData] = useState([]);

    useEffect(() => {
        const initialData = [];
        for (let i = 30; i >= 0; i--) {
            const timestamp = new Date(Date.now() - i * 60000);
            initialData.push({
                time: timestamp.toLocaleTimeString(),
                cpu: Math.random() * 40 + 15,
                memory: Math.random() * 30 + 50,
                processes: Math.floor(Math.random() * 5) + 1
            });
        }
        setHistoricalData(initialData);
    }, []);

    //if (!currentData) return <div>Loading...</div>;

    const getAlertStatus = (metric, value) => {
        const numValue = parseFloat(value);
        switch (metric) {
            case 'CPU Utilization':
                if (numValue > 80) return { status: 'critical', color: '#ef4444', icon: XCircle };
                if (numValue > 60) return { status: 'warning', color: '#f59e0b', icon: AlertTriangle };
                return { status: 'healthy', color: '#10b981', icon: CheckCircle };
            case 'Available Memory':
                const totalMemory = parseFloat(currentData.metrics["Total Memory"].value);
                const memoryUsagePercent = ((totalMemory - numValue) / totalMemory) * 100;
                if (memoryUsagePercent > 90) return { status: 'critical', color: '#ef4444', icon: XCircle };
                if (memoryUsagePercent > 75) return { status: 'warning', color: '#f59e0b', icon: AlertTriangle };
                return { status: 'healthy', color: '#10b981', icon: CheckCircle };
            case 'Number of Processes Running':
                if (numValue > 100) return { status: 'warning', color: '#f59e0b', icon: AlertTriangle };
                if (numValue < 1) return { status: 'critical', color: '#ef4444', icon: XCircle };
                return { status: 'healthy', color: '#10b981', icon: CheckCircle };
            default:
                return { status: 'unknown', color: '#6b7280', icon: Activity };
        }
    };

    const formatBytes = (bytes) => {
        const gb = bytes / (1024 * 1024 * 1024);
        return `${gb.toFixed(2)} GB`;
    };

    const calculateMemoryUsage = () => {
        const total = parseFloat(currentData.metrics["Total Memory"].value);
        const available = parseFloat(currentData.metrics["Available Memory"].value);
        const used = total - available;
        const usagePercent = (used / total) * 100;

        return {
            total: formatBytes(total),
            used: formatBytes(used),
            available: formatBytes(available),
            usagePercent: usagePercent.toFixed(1)
        };
    };

    const memoryData = calculateMemoryUsage();
    const memoryPieData = [
        { name: 'Used', value: parseFloat(memoryData.usagePercent), fill: '#ef4444' },
        { name: 'Available', value: 100 - parseFloat(memoryData.usagePercent), fill: '#10b981' }
    ];

    const MetricCard = ({ title, value, unit, icon: Icon, metric }) => {
        const alert = getAlertStatus(metric, value);
        const StatusIcon = alert.icon;

        return (
            <div className="metric-card">
                <div className="metric-header">
                    <div className="metric-title">
                        <div className="metric-icon"><Icon size={18} color="#60a5fa" /></div>
                        <h3>{title}</h3>
                    </div>
                    <div className="metric-status">
                        <StatusIcon size={16} color={alert.color} />
                        <span>{alert.status}</span>
                    </div>
                </div>
                <div className="metric-value">
                    <span>{value}</span>
                    {unit && <small>{unit}</small>}
                </div>
                <div className="metric-bar">
                    <div className="metric-bar-fill" style={{ width: `${Math.min(parseFloat(value), 100)}%`, backgroundColor: alert.color }} />
                </div>
            </div>
        );
    };

    return (
        <div className="dashboard-container">
            <div className="dashboard-header">
                <div className="host-info">
                    <div className="host-icon"><Server size={32} color="#60a5fa" /></div>
                    <div>
                        <h1>System Monitor</h1>
                        <p>Host: {currentData.host_ip}</p>
                    </div>
                </div>
                <div className="live-status">
                    <div className="pulse-dot" />
                    <span>Live</span>
                </div>
            </div>

            <div className="metric-grid">
                <MetricCard
                    title="CPU Usage"
                    value={parseFloat(currentData.metrics["CPU Utilization"].value).toFixed(1)}
                    unit="%"
                    icon={Cpu}
                    metric="CPU Utilization"
                />
                <MetricCard
                    title="Memory Usage"
                    value={memoryData.usagePercent}
                    unit="%"
                    icon={MemoryStick}
                    metric="Available Memory"
                />
                <MetricCard
                    title="Active Processes"
                    value={currentData.metrics["Number of Processes Running"].value}
                    unit="proc"
                    icon={Activity}
                    metric="Number of Processes Running"
                />
                <MetricCard
                    title="Swap Space"
                    value={parseFloat(currentData.metrics["Free Swap Space"].value).toFixed(0)}
                    unit="MB"
                    icon={HardDrive}
                    metric="Free Swap Space"
                />
            </div>

            <div className="chart-section">
                <div className="chart-box">
                    <div className="chart-title">
                        <h3>CPU Usage Trend</h3>
                        <div className="chart-label">
                            <Cpu size={16} color="#60a5fa" />
                            <span>Real-time</span>
                        </div>
                    </div>
                    <ResponsiveContainer width="100%" height={300}>
                        <LineChart data={historicalData}>
                            <CartesianGrid strokeDasharray="3 3" stroke="#ccc" />
                            <XAxis dataKey="time" />
                            <YAxis />
                            <Tooltip />
                            <Line type="monotone" dataKey="cpu" stroke="#60a5fa" strokeWidth={2} />
                        </LineChart>
                    </ResponsiveContainer>
                </div>

                <div className="chart-box">
                    <div className="chart-title">
                        <h3>Memory Usage</h3>
                    </div>
                    <ResponsiveContainer width="100%" height={300}>
                        <PieChart>
                            <Pie data={memoryPieData} dataKey="value" nameKey="name" outerRadius={100}>
                                {memoryPieData.map((entry, index) => (
                                    <Cell key={index} fill={entry.fill} />
                                ))}
                            </Pie>
                            <Tooltip />
                        </PieChart>
                    </ResponsiveContainer>
                </div>
            </div>
        </div>
    );
}