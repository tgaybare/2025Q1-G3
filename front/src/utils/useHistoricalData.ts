import { useEffect, useState } from 'react';

type HistoricalDataPoint = {
    time: string;
    cpu: number;
    memory: number;
    processes: number;
};

export const useHistoricalData = (host: string) => {
    const [data, setData] = useState<HistoricalDataPoint[]>([]);
    const apiUrl = import.meta.env.VITE_REST_API_URL;

    useEffect(() => {
        if (!host) return;
        fetch(`${apiUrl}/historical?host=${encodeURIComponent(host)}`)
            .then(res => res.json())
            .then(setData)
            .catch(() => setData([]));
    }, [host, apiUrl]);

    return data;
};
