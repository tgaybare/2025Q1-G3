import { useEffect, useState } from 'react';

export const useHistoricalData = () => {
    const [data, setData] = useState([]);

    useEffect(() => {
        const initialData = [];
        for (let i = 30; i >= 0; i--) {
            const timestamp = new Date(Date.now() - i * 60000);
            initialData.push({
                time: timestamp.toLocaleTimeString(),
                cpu: Math.random() * 40 + 15,
                memory: Math.random() * 30 + 50,
                processes: Math.floor(Math.random() * 5) + 1
            });
        }
        setData(initialData);
    }, []);

    return data;
};
