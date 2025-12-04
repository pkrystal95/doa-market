import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import orderRoutes from './routes/order.routes';
import { sequelize } from './config/database';
import { logger } from './utils/logger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3004;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'order-service' });
});

app.use('/api/v1/orders', orderRoutes);

const startServer = async () => {
  await sequelize.sync({ alter: true });
  app.listen(PORT, () => logger.info(`Order Service on ${PORT}`));
};

startServer();
export default app;

