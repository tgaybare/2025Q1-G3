import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from 'recharts';
import React from 'react';

// Custom Tooltip component
const CustomTooltip = ({ active, payload }) => {
    if (active && payload && payload.length) {
        const { name, value, fill } = payload[0].payload;
        return (
            <div
                style={{
                    background: '#1e293b',
                    color: '#fff',
                    border: `1px solid ${fill}`,
                    borderRadius: 8,
                    padding: '10px 16px',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.15)',
                    fontSize: 14,
                }}
            >
                <strong style={{ color: fill }}>{name}</strong>
                <div style={{ marginTop: 4 }}>
                    {value} MB
                </div>
            </div>
        );
    }
    return null;
};

export const MemoryPieChart = ({ data }) => (
    <div className="chart-box">
        <div className="chart-title"><h3>Memory Usage</h3></div>
        <ResponsiveContainer width="100%" height={300}>
            <PieChart>
                <Pie data={data} dataKey="value" nameKey="name" outerRadius={100}>
                    {data.map((entry, index) => (
                        <Cell key={index} fill={entry.fill} />
                    ))}
                </Pie>
                <Tooltip content={<CustomTooltip active={data.active} payload={data.payload} />} />
            </PieChart>
        </ResponsiveContainer>
    </div>
);
