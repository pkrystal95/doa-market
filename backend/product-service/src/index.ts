import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import productRoutes from './routes/product.routes';
import categoryRoutes from './routes/category.routes';
import { sequelize } from './config/database';
import { logger } from './utils/logger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3003;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'product-service' });
});

app.use('/api/v1/products', productRoutes);
app.use('/api/v1/categories', categoryRoutes);

const startServer = async () => {
  await sequelize.sync({ alter: true });
  app.listen(PORT, () => logger.info(`Product Service on ${PORT}`));
};

startServer();
export default app;

