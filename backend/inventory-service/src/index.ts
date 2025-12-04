import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import inventoryRoutes from './routes/inventory.routes';
import { sequelize } from './config/database';
import { logger } from './utils/logger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3010;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'inventory-service', timestamp: new Date().toISOString() });
});

app.use('/api/v1/inventory', inventoryRoutes);

const startServer = async () => {
  await sequelize.sync({ alter: true });
  app.listen(PORT, () => logger.info(`Inventory Service on port ${PORT}`));
};

startServer();
export default app;

