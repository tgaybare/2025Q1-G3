import React, { useState, useEffect } from 'react';
import "./styles.css";
import { CpuIcon, ServerIcon, HardDriveIcon, WifiIcon, BarChartIcon, ActivityIcon } from '../src/icons';

const monitoringIcons: MonitoringIcon[] = [
    { Icon: CpuIcon, label: "CPU", color: "#60A5FA" },
    { Icon: ServerIcon, label: "Memory", color: "#4ADE80" },
    { Icon: HardDriveIcon, label: "Storage", color: "#A78BFA" },
    { Icon: WifiIcon, label: "Network", color: "#FB923C" },
    { Icon: BarChartIcon, label: "Analytics", color: "#F472B6" },
];

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
    

    return (
        <div className="container">
            <div className="blob"></div>
            <div className="content">
                <div className="logo"><ActivityIcon /></div>
                <h1 className="title">{COMPANY_NAME}</h1>
                <p className="subtitle">Infrastructure Monitoring Dashboard
                </p>

                <div className="iconsContainer">
                    {monitoringIcons.map((icon, index) => (
                        <div
                            key={index}
                            className={`icon ${hoveredIcon === index ? 'hovered' : ''}`}
                            style={{ backgroundColor: hoveredIcon === index ? icon.color : '#f0f0f0' }}
                            onMouseEnter={() => setHoveredIcon(index)}
                            onMouseLeave={() => setHoveredIcon(null)}
                        >
                            <icon.Icon />
                            <span>{icon.label}</span>
                        </div>
                    ))}
                </div>

                <button className="loginButton" onClick={handleLoginRedirect}>
                    Start Monitoring
                </button>

                <div className="footer">
                    <p className=" text-sm">
                        Secure login powered by AWS Cognito
                    </p>
                    &copy; {new Date().getFullYear()} {COMPANY_NAME}. All rights reserved.
                </div>
            </div>
        </div>
    );
}
