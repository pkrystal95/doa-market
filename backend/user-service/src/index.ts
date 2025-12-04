import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { errorHandler } from './middleware/error-handler';
import { notFoundHandler } from './middleware/not-found-handler';
import userRoutes from './routes/user.routes';
import addressRoutes from './routes/address.routes';
import { logger } from './utils/logger';
import { sequelize } from './config/database';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3002;
const API_PREFIX = process.env.API_PREFIX || '/api/v1';

app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN?.split(',') || '*' }));
app.use(express.json());
app.use(morgan('combined', { stream: { write: (msg) => logger.info(msg.trim()) } }));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'user-service', timestamp: new Date().toISOString() });
});

app.use(`${API_PREFIX}/users`, userRoutes);
app.use(`${API_PREFIX}/users/:userId/addresses`, addressRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

const startServer = async () => {
  try {
    await sequelize.authenticate();
    logger.info('Database connected');
    
    if (process.env.NODE_ENV === 'development') {
      await sequelize.sync({ alter: true });
    }
    
    app.listen(PORT, () => {
      logger.info(`User Service running on port ${PORT}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
export default app;

