import { Router } from 'express';

const router = Router();

router.get('/products', async (req, res) => {
  const { q } = req.query;
  // TODO: OpenSearch integration
  res.json({ success: true, data: [], query: q, message: 'OpenSearch integration pending' });
});

router.get('/autocomplete', async (req, res) => {
  const { q } = req.query;
  res.json({ success: true, data: [], query: q });
});

export default router;

