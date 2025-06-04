import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer } from 'recharts';
import React from 'react';

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
                <Tooltip />
            </PieChart>
        </ResponsiveContainer>
    </div>
);
