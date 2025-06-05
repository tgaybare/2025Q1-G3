import React, { useState } from 'react';
import './styles.css';

export function HostManager({ onAddHost }) {
    const [isFormVisible, setFormVisible] = useState(false);
    const [name, setName] = useState('');
    const [ip, setIp] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        if (name && ip) {
            onAddHost({ name, ip });
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
                <form className="host-form" onSubmit={handleSubmit} autoComplete="off">
                    <h3>Add New Host</h3>
                    <input
                        type="text"
                        placeholder="Host Name"
                        value={name}
                        onChange={e => setName(e.target.value)}
                        required
                    />
                    <input
                        type="text"
                        placeholder="IP Address"
                        value={ip}
                        onChange={e => setIp(e.target.value)}
                        required
                    />
                    <div className="host-form-buttons">
                        <button type="submit">Add Host</button>
                        <button type="button" onClick={handleCancel} className="cancel-btn">Cancel</button>
                    </div>
                </form>
            )}
        </div>
    );
}
