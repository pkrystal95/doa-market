import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import paymentRoutes from './routes/payment.routes';
import { sequelize } from './config/database';
import { logger } from './utils/logger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3005;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'payment-service', timestamp: new Date().toISOString() });
});

app.use('/api/v1/payments', paymentRoutes);

const startServer = async () => {
  await sequelize.sync({ alter: true });
  app.listen(PORT, () => logger.info(`Payment Service on port ${PORT}`));
};

startServer();
export default app;

