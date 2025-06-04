import { XCircle, AlertTriangle, CheckCircle, Activity, AlertCircle, Info } from 'lucide-react';

export const getAlertStatus = (metric: string, value: number | string, totalMemory?: number) => {
    const numValue = parseFloat(value as string);
    switch (metric) {
        case 'CPU Utilization':
            if (numValue > 80) return {
                status: 'critical',
                color: '#ef4444',
                icon: XCircle,
                tooltip: 'CPU usage is very high. Consider closing unused applications or upgrading your server.'
            };
            if (numValue > 60) return {
                status: 'warning',
                color: '#f59e0b',
                icon: AlertTriangle,
                tooltip: 'CPU usage is elevated. Monitor for performance issues.'
            };
            return {
                status: 'healthy',
                color: '#10b981',
                icon: CheckCircle,
                tooltip: 'CPU usage is within a healthy range.'
            };
        case 'Available Memory':
            if (!totalMemory) return {
                status: 'unknown',
                color: '#6b7280',
                icon: Activity,
                tooltip: 'Total memory information is missing.'
            };
            const memUsage = ((totalMemory - numValue) / totalMemory) * 100;
            if (memUsage > 90) return {
                status: 'critical',
                color: '#ef4444',
                icon: XCircle,
                tooltip: 'Memory usage is very high. Consider closing programs or adding more RAM.'
            };
            if (memUsage > 75) return {
                status: 'warning',
                color: '#f59e0b',
                icon: AlertTriangle,
                tooltip: 'Memory usage is elevated. Monitor for slowdowns.'
            };
            return {
                status: 'healthy',
                color: '#10b981',
                icon: CheckCircle,
                tooltip: 'Memory usage is within a healthy range.'
            };
        case 'Number of Processes Running':
            if (numValue > 100) return {
                status: 'warning',
                color: '#f59e0b',
                icon: AlertTriangle,
                tooltip: 'Many processes are running. This can slow down your system.'
            };
            if (numValue < 1) return {
                status: 'critical',
                color: '#ef4444',
                icon: XCircle,
                tooltip: 'No processes running. The system may be unresponsive or down.'
            };
            return {
                status: 'healthy',
                color: '#10b981',
                icon: CheckCircle,
                tooltip: 'The number of running processes is normal.'
            };
        case "Free Swap Space":
            if (numValue < 256) return {
                status: "critical",
                color: "#ef4444",
                icon: AlertCircle,
                tooltip: "Free swap space is very low. Swap is used when RAM is full. Consider closing programs or adding more memory."
            };
            if (numValue < 1024) return {
                status: "warning",
                color: "#f59e42",
                icon: Info,
                tooltip: "Free swap space is getting low. Monitor your memory usage."
            };
            return {
                status: "healthy",
                color: "#10b981",
                icon: CheckCircle,
                tooltip: "Swap space is sufficient. Swap helps your system when RAM is full."
            };

        default:
            return {
                status: 'unknown',
                color: '#6b7280',
                icon: Activity,
                tooltip: 'No information available for this metric.'
            };
    }
};
