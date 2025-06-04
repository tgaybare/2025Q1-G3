import React, { useState } from 'react';
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

const dummyHostData = {
    "192.168.1.1": {
        "CPU Utilization": 90,
        "Available Memory": 2048,
        "Total Memory": 8192,
        "Free Swap Space": 1024,
        "Number of Processes Running": 150
    },
    "192.168.1.2": {
        "CPU Utilization": 23.1,
        "Available Memory": 4096,
        "Total Memory": 8192,
        "Free Swap Space": 2048,
        "Number of Processes Running": 98
    }
};

export function Dashboard() {
    const historicalData = useHistoricalData();
    const [hosts, setHosts] = useState([
        { name: 'Host 1', ip: '192.168.1.1', zabbix: '' },
        { name: 'Host 2', ip: '192.168.1.2', zabbix: '' }
    ]);
    const [selectedHost, setSelectedHost] = useState(() => hosts[0]?.ip || '');
    
    const currentMetrics = dummyHostData[selectedHost];
    const total = currentMetrics["Total Memory"];
    const available = currentMetrics["Available Memory"];
    const used = total - available;
    const usagePercent = (used / total) * 100;
    
    const memoryPieData = [
        { name: 'Used', value: usagePercent, fill: '#ef4444' },
        { name: 'Available', value: 100 - usagePercent, fill: '#10b981' }
    ];

    const handleAddHost = (newHost) => {
        setHosts([...hosts, newHost]);

        dummyHostData[newHost.ipAddress] = {
            "CPU Utilization": 0,
            "Available Memory": 0,
            "Total Memory": 8192,
            "Free Swap Space": 0,
            "Number of Processes Running": 0
        };
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
                    className={`host-card ${selectedHost === host.ip ? 'selected' : ''}`}
                    onClick={() => setSelectedHost(host.ip)}
                    style={{ cursor: 'pointer' }}
                    >
                    <h2>{host.name}</h2>
                    <p>{host.ip}</p>
                    </div>
                ))}
                </div>
                <div className="host-manager-container">
                    <HostManager onAddHost={handleAddHost} />
                </div>

                <div className="metric-grid">
                    <MetricCard
                        title="CPU Usage"
                        value={currentMetrics["CPU Utilization"]}
                        unit="%"
                        icon={Cpu}
                        statusData={getAlertStatus("CPU Utilization", currentMetrics["CPU Utilization"])}
                    />

                    <MetricCard
                        title="Memory Usage"
                        value={usagePercent.toFixed(1)}
                        unit="%"
                        icon={MemoryStick}
                        statusData={getAlertStatus("Available Memory", available, total)}
                    />

                    <MetricCard
                        title="Active Processes"
                        value={currentMetrics["Number of Processes Running"]}
                        unit="proc"
                        icon={ActivityIcon}
                        statusData={getAlertStatus("Number of Processes Running", currentMetrics["Number of Processes Running"])}
                    />
                    <MetricCard
                        title="Free Swap Space"
                        value={currentMetrics["Free Swap Space"]}
                        unit="MB"
                        icon={HardDrive}
                        statusData={getAlertStatus("Free Swap Space", currentMetrics["Free Swap Space"])}
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