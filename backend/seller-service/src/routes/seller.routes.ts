import { Router } from 'express';
import Seller from '../models/seller.model';

const router = Router();

router.get('/', async (req, res) => {
  const sellers = await Seller.findAll();
  res.json({ success: true, data: sellers });
});

router.post('/', async (req, res) => {
  const seller = await Seller.create(req.body);
  res.json({ success: true, data: seller });
});

router.get('/:id', async (req, res) => {
  const seller = await Seller.findByPk(req.params.id);
  res.json({ success: true, data: seller });
});

router.patch('/:id/verify', async (req, res) => {
  const seller = await Seller.findByPk(req.params.id);
  if (seller) {
    seller.status = 'verified';
    seller.verifiedAt = new Date();
    await seller.save();
  }
  res.json({ success: true, data: seller });
});

export default router;

