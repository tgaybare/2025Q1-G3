import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import React from 'react';
import { Cpu } from 'lucide-react';

export const CPUChart = ({ data }) => (
    <div className="chart-box">
        <div className="chart-title">
            <h3>CPU Usage Trend</h3>
            <div className="chart-label">
                <Cpu size={16} color="#60a5fa" />
                <span>Real-time</span>
            </div>
        </div>
        <ResponsiveContainer width="100%" height={300}>
            <LineChart data={data}>
                <CartesianGrid strokeDasharray="3 3" stroke="#ccc" />
                <XAxis dataKey="time" />
                <YAxis />
                <Tooltip />
                <Line type="monotone" dataKey="cpu" stroke="#60a5fa" strokeWidth={2} />
            </LineChart>
        </ResponsiveContainer>
    </div>
);
