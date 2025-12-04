import { Router } from 'express';
import Product from '../models/product.model';

const router = Router();

router.get('/', async (req, res) => {
  const products = await Product.findAll();
  res.json({ success: true, data: products });
});

router.post('/', async (req, res) => {
  const product = await Product.create(req.body);
  res.json({ success: true, data: product });
});

export default router;

