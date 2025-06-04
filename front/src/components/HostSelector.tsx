import React from 'react';

export function HostSelector({ hosts, selectedHost, onSelectHost, onAddHost }) {
    const [newHost, setNewHost] = React.useState('');

    const handleAdd = () => {
        if (newHost.trim()) {
            onAddHost(newHost.trim());
            setNewHost('');
        }
    };

    return (
        <div className="host-selector">
            <select value={selectedHost} onChange={(e) => onSelectHost(e.target.value)}>
                {hosts.map((host) => (
                    <option key={host} value={host}>{host}</option>
                ))}
            </select>
            <input
                type="text"
                placeholder="Add new host IP"
                value={newHost}
                onChange={(e) => setNewHost(e.target.value)}
            />
            <button onClick={handleAdd}>Add</button>
        </div>
    );
}
