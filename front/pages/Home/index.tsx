import React, { useState, useEffect } from 'react';
import "./styles.css";
import { CpuIcon, ServerIcon, HardDriveIcon, WifiIcon, BarChartIcon, ActivityIcon } from '../../src/icons';

// TypeScript declaration for import.meta.env
interface ImportMetaEnv {
    readonly VITE_COGNITO_HOSTED_UI: string;
    // add other env variables here if needed
}

interface ImportMeta {
    readonly env: ImportMetaEnv;
}

export function HomePage() {
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
                    <span className="icon_CPU"><CpuIcon /></span>
                    <span className="icon_server"><ServerIcon /></span>
                    <span className="icon_harddrive"><HardDriveIcon /></span>
                    <span className="icon_wifi"><WifiIcon /></span>
                    <span className="icon_barchart"><BarChartIcon /></span>
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
