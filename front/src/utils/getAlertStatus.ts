import { XCircle, AlertTriangle, CheckCircle, Activity } from 'lucide-react';

export const getAlertStatus = (metric: string, value: number | string, totalMemory?: number) => {
    const numValue = parseFloat(value as string);
    switch (metric) {
        case 'CPU Utilization':
            if (numValue > 80) return { status: 'critical', color: '#ef4444', icon: XCircle };
            if (numValue > 60) return { status: 'warning', color: '#f59e0b', icon: AlertTriangle };
            return { status: 'healthy', color: '#10b981', icon: CheckCircle };
        case 'Available Memory':
            if (!totalMemory) return { status: 'unknown', color: '#6b7280', icon: Activity };
            const memUsage = ((totalMemory - numValue) / totalMemory) * 100;
            if (memUsage > 90) return { status: 'critical', color: '#ef4444', icon: XCircle };
            if (memUsage > 75) return { status: 'warning', color: '#f59e0b', icon: AlertTriangle };
            return { status: 'healthy', color: '#10b981', icon: CheckCircle };
        case 'Number of Processes Running':
            if (numValue > 100) return { status: 'warning', color: '#f59e0b', icon: AlertTriangle };
            if (numValue < 1) return { status: 'critical', color: '#ef4444', icon: XCircle };
            return { status: 'healthy', color: '#10b981', icon: CheckCircle };
        default:
            return { status: 'unknown', color: '#6b7280', icon: Activity };
    }
};
