import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import searchRoutes from './routes/search.routes';
import { logger } from './utils/logger';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3013;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'search-service', timestamp: new Date().toISOString() });
});

app.use('/api/v1/search', searchRoutes);

app.listen(PORT, () => logger.info(`Search Service on port ${PORT}`));
export default app;

