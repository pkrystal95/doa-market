import { Router } from 'express';
import Product from '../models/product.model';

const router = Router();

router.get('/', async (req, res) => {
  const products = await Product.findAll();
  res.json({ success: true, data: products });
});

router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }
    res.json({ success: true, data: product });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch product' });
  }
});

router.post('/', async (req, res) => {
  const product = await Product.create(req.body);
  res.json({ success: true, data: product });
});

export default router;

