import { Router } from 'express';
import Shipping from '../models/shipping.model';

const router = Router();

router.get('/', async (req, res) => {
  const shippings = await Shipping.findAll();
  res.json({ success: true, data: shippings });
});

router.post('/', async (req, res) => {
  const shipping = await Shipping.create(req.body);
  res.json({ success: true, data: shipping });
});

router.get('/:id/track', async (req, res) => {
  const shipping = await Shipping.findByPk(req.params.id);
  res.json({ success: true, data: shipping });
});

export default router;

