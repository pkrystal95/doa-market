import { Router } from 'express';
import Order from '../models/order.model';

const router = Router();

router.get('/', async (req, res) => {
  const orders = await Order.findAll();
  res.json({ success: true, data: orders });
});

router.post('/', async (req, res) => {
  const order = await Order.create({
    ...req.body,
    orderNumber: `ORD-${Date.now()}`,
  });
  res.json({ success: true, data: order });
});

export default router;

