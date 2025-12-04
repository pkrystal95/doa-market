import { Router } from 'express';
import Review from '../models/review.model';

const router = Router();

router.get('/', async (req, res) => {
  const reviews = await Review.findAll();
  res.json({ success: true, data: reviews });
});

router.post('/', async (req, res) => {
  const review = await Review.create(req.body);
  res.json({ success: true, data: review });
});

router.get('/products/:productId', async (req, res) => {
  const reviews = await Review.findAll({ where: { productId: req.params.productId } });
  res.json({ success: true, data: reviews });
});

export default router;

