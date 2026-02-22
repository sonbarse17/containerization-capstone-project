import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 8080;
const BACKEND_URL = process.env.BACKEND_URL || 'http://taskflow-backend:5000';

// Proxy /api requests to the backend service
app.use('/api', createProxyMiddleware({
    target: BACKEND_URL,
    changeOrigin: true,
}));

// Serve React static built files directly
app.use(express.static(path.join(__dirname, 'dist')));

// Fallback for React Router (Single Page Application)
app.use((req, res) => {
    res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(PORT, () => {
    console.log(`React frontend production server running on port ${PORT}`);
});
