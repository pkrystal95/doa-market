import { Router } from 'express';
import Payment from '../models/payment.model';

const router = Router();

router.get('/', async (req, res) => {
  const payments = await Payment.findAll();
  res.json({ success: true, data: payments });
});

router.post('/', async (req, res) => {
  const payment = await Payment.create(req.body);
  res.json({ success: true, data: payment });
});

export default router;

