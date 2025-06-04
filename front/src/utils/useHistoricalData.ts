import { useEffect, useState } from 'react';

type HistoricalDataPoint = {
    time: string;
    cpu: number;
    memory: number;
    processes: number;
};

export const useHistoricalData = () => {
    const [data, setData] = useState<HistoricalDataPoint[]>([]);

    useEffect(() => {
        const initialData: HistoricalDataPoint[] = [];
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
