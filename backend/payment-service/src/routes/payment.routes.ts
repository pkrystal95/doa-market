import { Router } from 'express';
import crypto from 'crypto';
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

// 결제 준비 (KG Inicis)
router.post('/prepare', async (req, res) => {
  try {
    const { orderId, userId, amount, productName, method } = req.body;

    if (!orderId || !userId || !amount || !productName) {
      return res.status(400).json({
        success: false,
        message: '필수 파라미터가 누락되었습니다',
      });
    }

    // Generate unique payment ID
    const paymentId = crypto.randomUUID();

    // KG Inicis 연동을 위한 파라미터 생성
    // 실제 운영시에는 이니시스에서 발급받은 MID, 인증키 등을 사용해야 합니다
    const inicisParams = {
      version: '1.0',
      mid: process.env.INICIS_MID || 'INIpayTest', // 테스트 MID
      oid: orderId, // 주문번호
      price: amount.toString(),
      timestamp: new Date().getTime().toString(),
      use_chkfake: 'Y',
      currency: 'WON',
      goodname: productName,
      buyername: '구매자', // 실제로는 사용자 정보를 받아야 함
      buyertel: '010-0000-0000', // 실제로는 사용자 정보를 받아야 함
      buyeremail: 'test@test.com', // 실제로는 사용자 정보를 받아야 함
      returnUrl: `http://localhost:3006/api/v1/payments/callback`,
      closeUrl: `http://localhost:8081/checkout`,
    };

    // Payment 레코드 생성
    const payment = await Payment.create({
      id: paymentId,
      orderId,
      userId,
      amount,
      method: method || 'card',
      status: 'pending',
    });

    // KG Inicis 모바일 결제 URL (실제 운영시에는 이니시스 정책에 따라 변경)
    const paymentUrl = 'https://mobile.inicis.com/smart/payment/';

    res.json({
      success: true,
      data: {
        paymentId,
        paymentUrl,
        inicisParams,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || '결제 준비 중 오류가 발생했습니다',
    });
  }
});

// 결제 완료 처리
router.post('/:id/complete', async (req, res) => {
  try {
    const { id } = req.params;
    const { transactionId, status } = req.body;

    const payment = await Payment.findByPk(id);
    if (!payment) {
      return res.status(404).json({
        success: false,
        message: '결제 정보를 찾을 수 없습니다',
      });
    }

    // Update payment status
    await payment.update({
      transactionId,
      status: status || 'completed',
    });

    res.json({
      success: true,
      data: payment,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || '결제 완료 처리 중 오류가 발생했습니다',
    });
  }
});

// 결제 조회
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const payment = await Payment.findByPk(id);

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: '결제 정보를 찾을 수 없습니다',
      });
    }

    res.json({
      success: true,
      data: payment,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || '결제 조회 중 오류가 발생했습니다',
    });
  }
});

// KG Inicis 결제 콜백 처리
router.post('/callback', async (req, res) => {
  try {
    // 이니시스로부터 받은 결제 결과 처리
    const { resultCode, resultMsg, tid, orderId } = req.body;

    if (resultCode === '00') {
      // 결제 성공
      // 주문 상태 업데이트 등의 로직 추가 필요
      res.send('<script>alert("결제가 완료되었습니다."); window.close();</script>');
    } else {
      // 결제 실패
      res.send(`<script>alert("결제 실패: ${resultMsg}"); window.close();</script>`);
    }
  } catch (error: any) {
    res.status(500).send('<script>alert("결제 처리 중 오류가 발생했습니다."); window.close();</script>');
  }
});

export default router;

