import { Router } from 'express';
import Coupon from '../models/coupon.model';

const router = Router();

router.get('/', async (req, res) => {
  const coupons = await Coupon.findAll();
  res.json({ success: true, data: coupons });
});

router.post('/', async (req, res) => {
  const coupon = await Coupon.create(req.body);
  res.json({ success: true, data: coupon });
});

router.post('/:code/issue', async (req, res) => {
  const coupon = await Coupon.findOne({ where: { code: req.params.code } });
  res.json({ success: true, data: coupon, message: 'Coupon issued' });
});

export default router;

