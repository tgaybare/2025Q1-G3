import React, { useState } from 'react';
import './styles.css';

export function HostManager({ onAddHost }) {
    const [isFormVisible, setFormVisible] = useState(false);
    const [hostName, setHostName] = useState('');
    const [ipAddress, setIpAddress] = useState('');
    const [zabbixEndpoint, setZabbixEndpoint] = useState('');

    const handleAdd = () => {
        if (hostName && ipAddress) {
            onAddHost({ hostName, ipAddress, zabbixEndpoint });
            setHostName('');
            setIpAddress('');
            setZabbixEndpoint('');
            setFormVisible(false);
        }
    };

    const handleCancel = () => {
        setFormVisible(false);
        setHostName('');
        setIpAddress('');
        setZabbixEndpoint('');
    };

    return (
        <div className="host-manager">
            {!isFormVisible && (
                <button className="add-host-btn" onClick={() => setFormVisible(true)}>
                    + Add Host
                </button>
            )}

            {isFormVisible && (
                <div className="host-form">
                    <h3>Add New Host</h3>
                    <input
                        type="text"
                        placeholder="Host Name"
                        value={hostName}
                        onChange={(e) => setHostName(e.target.value)}
                    />
                    <input
                        type="text"
                        placeholder="IP Address"
                        value={ipAddress}
                        onChange={(e) => setIpAddress(e.target.value)}
                    />
                    <input
                        type="text"
                        placeholder="Zabbix Endpoint (optional)"
                        value={zabbixEndpoint}
                        onChange={(e) => setZabbixEndpoint(e.target.value)}
                    />
                    <div className="host-form-buttons">
                        <button onClick={handleAdd}>Add Host</button>
                        <button onClick={handleCancel} className="cancel-btn">Cancel</button>
                    </div>
                </div>
            )}
        </div>
    );
}
