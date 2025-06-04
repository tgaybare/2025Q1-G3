import React, { useState, useEffect } from 'react';
import styles from "./Home.module.css";
import MemoryIcon from '@mui/icons-material/Memory';

const ActivityIcon = () => (
    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <polyline points="22,12 18,12 15,21 9,3 6,12 2,12"></polyline>
    </svg>
);



const ServerIcon = () => (
    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <rect x="2" y="3" width="20" height="4" rx="1" ry="1"></rect>
        <rect x="2" y="9" width="20" height="4" rx="1" ry="1"></rect>
        <rect x="2" y="15" width="20" height="4" rx="1" ry="1"></rect>
        <line x1="6" y1="5" x2="6.01" y2="5"></line>
        <line x1="6" y1="11" x2="6.01" y2="11"></line>
        <line x1="6" y1="17" x2="6.01" y2="17"></line>
    </svg>
);

const HardDriveIcon = () => (
    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <line x1="22" y1="12" x2="2" y2="12"></line>
        <path d="M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z"></path>
        <line x1="6" y1="16" x2="6.01" y2="16"></line>
        <line x1="10" y1="16" x2="10.01" y2="16"></line>
    </svg>
);

const WifiIcon = () => (
    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M5 12.55a11 11 0 0 1 14.08 0"></path>
        <path d="M1.42 9a16 16 0 0 1 21.16 0"></path>
        <path d="M8.53 16.11a6 6 0 0 1 6.95 0"></path>
        <line x1="12" y1="20" x2="12.01" y2="20"></line>
    </svg>
);

const BarChartIcon = () => (
    <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <line x1="12" y1="20" x2="12" y2="10"></line>
        <line x1="18" y1="20" x2="18" y2="4"></line>
        <line x1="6" y1="20" x2="6" y2="16"></line>
    </svg>
);

interface MonitoringIcon {
    Icon: React.FC;
    label: string;
    color: string;
}

export function HomePage() {
    const [isLoaded, setIsLoaded] = useState(false);
    const [hoveredIcon, setHoveredIcon] = useState<number | null>(null);

    const COMPANY_NAME = "TechMonitor Pro";
    const COGNITO_LOGIN_URL = import.meta.env.VITE_COGNITO_HOSTED_UI;

    useEffect(() => {
        const timer = setTimeout(() => setIsLoaded(true), 100);
        return () => clearTimeout(timer);
    }, []);

    const handleLoginRedirect = () => {
        window.location.href = COGNITO_LOGIN_URL;
    };

    const monitoringIcons: MonitoringIcon[] = [
        { Icon: ServerIcon, label: "Memory", color: "#4ADE80" },
        { Icon: HardDriveIcon, label: "Storage", color: "#A78BFA" },
        { Icon: WifiIcon, label: "Network", color: "#FB923C" },
        { Icon: BarChartIcon, label: "Analytics", color: "#F472B6" },
    ];

    return (
        <div className={styles.container}>
            <div className={styles.blob}></div>
            <div className={styles.content}>
                <div className={styles.logo}><ActivityIcon /></div>
                <h1 className={styles.title}>{COMPANY_NAME}</h1>
                <p className={styles.subtitle}>Infrastructure Monitoring Dashboard
                </p>

                <div className={styles.iconsContainer}>
                    <MemoryIcon className="iconBox icon_CPU"/>
                    {monitoringIcons.map(({ Icon, label, color }, index) => (
                        <div
                            key={label}
                            className={styles.iconBox}
                            onMouseEnter={() => setHoveredIcon(index)}
                            onMouseLeave={() => setHoveredIcon(null)}
                            style={{
                                transform: hoveredIcon === index ? 'scale(1.1)' : 'scale(1)',
                                borderColor: hoveredIcon === index ? color : undefined,
                            }}
                        >
                            <Icon />
                        </div>
                    ))}
                </div>

                <button className={styles.loginButton} onClick={handleLoginRedirect}>
                    Start Monitoring
                </button>

                <div className={styles.footer}>
                    <p className=" text-sm">
                        Secure login powered by AWS Cognito
                    </p>
                    &copy; {new Date().getFullYear()} {COMPANY_NAME}. All rights reserved.
                </div>
            </div>
        </div>
    );
}
