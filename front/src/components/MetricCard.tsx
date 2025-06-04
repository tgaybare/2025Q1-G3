import React from 'react';
import { CheckCircle, AlertTriangle, XCircle, Activity } from 'lucide-react';
import { getAlertStatus } from './../utils/getAlertStatus';

export const MetricCard = ({ title, value, unit, icon: Icon, metric }) => {
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
