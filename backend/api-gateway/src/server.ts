import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { createProxyMiddleware } from 'http-proxy-middleware';
import logger from './utils/logger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGINS?.split(',') || '*' }));
app.use(express.json());

app.get('/api/v1/health', (req, res) => {
  res.json({
    success: true,
    data: {
      service: 'api-gateway',
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    },
  });
});

app.get('/', (req, res) => {
  res.json({
    service: 'DOA Market API Gateway',
    version: '1.0.0',
    status: 'running',
    services: {
      auth: 'http://localhost:3001',
      users: 'http://localhost:3002',
      products: 'http://localhost:3003',
      sellers: 'http://localhost:3004',
      orders: 'http://localhost:3005',
      payments: 'http://localhost:3006',
      carts: 'http://localhost:3007',
      reviews: 'http://localhost:3008',
      notifications: 'http://localhost:3009',
      search: 'http://localhost:3010',
      shipping: 'http://localhost:3011',
      coupons: 'http://localhost:3012',
      wishlist: 'http://localhost:3013',
      admin: 'http://localhost:3014',
    },
  });
});

const services = [
  { path: '/api/v1/auth', target: 'http://localhost:3001' },
  { path: '/api/v1/users', target: 'http://localhost:3002' },
  { path: '/api/v1/profiles', target: 'http://localhost:3002' },
  { path: '/api/v1/products', target: 'http://localhost:3003' },
  { path: '/api/v1/orders', target: 'http://localhost:3004' },
  { path: '/api/v1/payments', target: 'http://localhost:3005' },
  { path: '/api/v1/shipping', target: 'http://localhost:3006' },
  { path: '/api/v1/sellers', target: 'http://localhost:3007' },
  { path: '/api/v1/settlements', target: 'http://localhost:3008' },
  { path: '/api/v1/coupons', target: 'http://localhost:3009' },
  { path: '/api/v1/inventory', target: 'http://localhost:3010' },
  { path: '/api/v1/notifications', target: 'http://localhost:3011' },
  { path: '/api/v1/reviews', target: 'http://localhost:3012' },
  { path: '/api/v1/search', target: 'http://localhost:3013' },
  { path: '/api/v1/admin', target: 'http://localhost:3014' },
];

services.forEach(({ path, target }) => {
  app.use(
    path,
    createProxyMiddleware({
      target,
      changeOrigin: true,
      onProxyReq: (proxyReq, req) => {
        logger.info(`Proxying ${req.method} ${req.url} to ${target}`);
      },
      onError: (err, req, res) => {
        logger.error(`Proxy error for ${target}:`, err);
        res.status(502).json({
          success: false,
          error: 'Bad Gateway',
          message: `Service unavailable: ${target}`,
        });
      },
    })
  );
});

app.use((req, res) => {
  res.status(404).json({ success: false, error: 'Route not found' });
});

app.listen(PORT, () => {
  logger.info(`API Gateway running on port ${PORT}`);
  logger.info('All services proxied and ready');
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT signal received');
  process.exit(0);
});
