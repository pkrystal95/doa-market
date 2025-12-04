import { Router } from 'express';
import Settlement from '../models/settlement.model';

const router = Router();

router.get('/', async (req, res) => {
  const settlements = await Settlement.findAll();
  res.json({ success: true, data: settlements });
});

router.post('/', async (req, res) => {
  const settlement = await Settlement.create(req.body);
  res.json({ success: true, data: settlement });
});

export default router;

