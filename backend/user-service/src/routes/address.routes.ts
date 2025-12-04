import { Router } from 'express';
const router = Router({ mergeParams: true });

router.get('/', (req, res) => res.json({ success: true, data: [] }));
router.post('/', (req, res) => res.json({ success: true, data: {} }));

export default router;

