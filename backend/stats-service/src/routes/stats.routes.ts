import { Router } from 'express';

const router = Router();

router.get('/sales', async (req, res) => {
  const { period } = req.query;
  res.json({ 
    success: true, 
    data: { 
      period,
      totalSales: 0,
      totalOrders: 0,
      averageOrderValue: 0
    } 
  });
});

router.get('/products/views', async (req, res) => {
  res.json({ success: true, data: [] });
});

export default router;

