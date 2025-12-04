import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import adminRoutes from './routes/admin.routes';
import { logger } from './utils/logger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3014;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'admin-service', timestamp: new Date().toISOString() });
});

app.use('/api/v1/admin', adminRoutes);

app.listen(PORT, () => logger.info(`Admin Service on port ${PORT}`));
export default app;

