import React, { useState } from 'react';
import './styles.css';

export function HostManager({ onAddHost }) {
    const [isFormVisible, setFormVisible] = useState(false);
    const [name, setName] = useState('');
    const [ip, setIp] = useState('');

    const handleAdd = () => {
        if (name && ip) {
            // Pass the correct object structure to onAddHost
            onAddHost({ name, ip});
            setName('');
            setIp('');
            setFormVisible(false);
        }
    };

    const handleCancel = () => {
        setFormVisible(false);
        setName('');
        setIp('');
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
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                    />
                    <input
                        type="text"
                        placeholder="IP Address"
                        value={ip}
                        onChange={(e) => setIp(e.target.value)}
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
