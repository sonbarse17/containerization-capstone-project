import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    server: {
        port: 8080,
        proxy: {
            '/api': {
                target: 'http://taskflow-backend:5000',
                changeOrigin: true,
            },
        },
    },
});
