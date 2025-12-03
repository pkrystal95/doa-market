import { EventHandler } from './EventHandler';
import { PaymentGateway } from './PaymentGateway';
import { PaymentRepository } from './PaymentRepository';
import { EventPublisher } from './EventPublisher';
import { logger } from '../../../core/utils/logger';
import { v4 as uuidv4 } from 'uuid';

/**
 * Payment Service Event Handler
 * 결제 관련 이벤트를 처리
 */
export class PaymentEventHandler implements EventHandler {
  constructor(
    private paymentGateway: PaymentGateway,
    private paymentRepository: PaymentRepository,
    private eventPublisher: EventPublisher
  ) {}

  /**
   * 결제 요청 이벤트 처리
   * Event: payment.requested
   */
  async handlePaymentRequested(event: PaymentRequestedEvent): Promise<void> {
    const { orderId, userId, amount, paymentMethod, correlationId, sagaId } = event.data;

    logger.info('Handling payment request', {
      orderId,
      amount,
      correlationId,
      sagaId,
    });

    try {
      // 결제 레코드 생성
      const payment = await this.paymentRepository.create({
        orderId,
        userId,
        amount,
        paymentMethod,
        status: 'pending',
        sagaId,
      });

      // PG사 결제 요청
      const pgResult = await this.paymentGateway.processPayment({
        paymentId: payment.id,
        amount,
        paymentMethod,
        userId,
        orderId,
      });

      if (pgResult.success) {
        // 결제 성공
        await this.paymentRepository.update(payment.id, {
          status: 'completed',
          transactionId: pgResult.transactionId,
          completedAt: new Date(),
        });

        // 결제 완료 이벤트 발행
        await this.eventPublisher.publish({
          eventType: 'payment.completed',
          eventId: uuidv4(),
          correlationId,
          sagaId,
          timestamp: new Date().toISOString(),
          source: 'payment-service',
          data: {
            orderId,
            paymentId: payment.id,
            transactionId: pgResult.transactionId,
            amount,
          },
        });

        logger.info('Payment completed successfully', {
          orderId,
          paymentId: payment.id,
          transactionId: pgResult.transactionId,
        });
      } else {
        // 결제 실패
        await this.paymentRepository.update(payment.id, {
          status: 'failed',
          failureReason: pgResult.errorMessage,
        });

        // 결제 실패 이벤트 발행
        await this.eventPublisher.publish({
          eventType: 'payment.failed',
          eventId: uuidv4(),
          correlationId,
          sagaId,
          timestamp: new Date().toISOString(),
          source: 'payment-service',
          data: {
            orderId,
            paymentId: payment.id,
            reason: pgResult.errorMessage,
          },
        });

        logger.error('Payment failed', {
          orderId,
          paymentId: payment.id,
          reason: pgResult.errorMessage,
        });
      }
    } catch (error) {
      logger.error('Error processing payment', {
        orderId,
        error: error.message,
      });

      // 결제 실패 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'payment.failed',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        source: 'payment-service',
        data: {
          orderId,
          reason: error.message,
        },
      });
    }
  }

  /**
   * 환불 요청 이벤트 처리 (보상 트랜잭션)
   * Event: payment.refund_requested
   */
  async handleRefundRequested(event: PaymentRefundRequestedEvent): Promise<void> {
    const { orderId, sagaId, correlationId } = event.data;

    logger.info('Handling payment refund request', {
      orderId,
      sagaId,
      correlationId,
    });

    try {
      // 주문에 대한 결제 정보 조회
      const payment = await this.paymentRepository.findByOrder(orderId);

      if (!payment) {
        logger.warn('No payment found for order', { orderId });
        return;
      }

      if (payment.status !== 'completed') {
        logger.warn('Payment not completed, skipping refund', {
          orderId,
          paymentStatus: payment.status,
        });
        return;
      }

      // PG사 환불 요청
      const refundResult = await this.paymentGateway.refund({
        transactionId: payment.transactionId!,
        amount: payment.amount,
        reason: 'Order cancelled - Saga compensation',
      });

      if (refundResult.success) {
        // 환불 성공
        await this.paymentRepository.update(payment.id, {
          status: 'refunded',
          refundedAt: new Date(),
          refundTransactionId: refundResult.refundTransactionId,
        });

        // 환불 완료 이벤트 발행
        await this.eventPublisher.publish({
          eventType: 'payment.refunded',
          eventId: uuidv4(),
          correlationId,
          sagaId,
          timestamp: new Date().toISOString(),
          source: 'payment-service',
          data: {
            orderId,
            paymentId: payment.id,
            refundTransactionId: refundResult.refundTransactionId,
            amount: payment.amount,
          },
        });

        logger.info('Payment refunded successfully', {
          orderId,
          paymentId: payment.id,
          refundTransactionId: refundResult.refundTransactionId,
        });
      } else {
        logger.error('Payment refund failed', {
          orderId,
          paymentId: payment.id,
          reason: refundResult.errorMessage,
        });

        // 환불 실패는 치명적 - 수동 개입 필요
        await this.paymentRepository.update(payment.id, {
          status: 'refund_failed',
          refundFailureReason: refundResult.errorMessage,
        });

        // Alert 발송
        await this.sendCriticalAlert({
          type: 'REFUND_FAILED',
          orderId,
          paymentId: payment.id,
          reason: refundResult.errorMessage,
        });
      }
    } catch (error) {
      logger.error('Error processing refund', {
        orderId,
        error: error.message,
      });

      await this.sendCriticalAlert({
        type: 'REFUND_ERROR',
        orderId,
        error: error.message,
      });
    }
  }

  /**
   * 치명적 알림 발송 (Slack, PagerDuty 등)
   */
  private async sendCriticalAlert(alert: any): Promise<void> {
    logger.error('CRITICAL ALERT:', alert);
    // Send to monitoring/alerting system
    // await alertingService.sendCriticalAlert(alert);
  }
}

// Types
interface PaymentRequestedEvent {
  eventType: 'payment.requested';
  data: {
    orderId: string;
    userId: string;
    amount: number;
    paymentMethod: string;
    correlationId: string;
    sagaId: string;
  };
}

interface PaymentRefundRequestedEvent {
  eventType: 'payment.refund_requested';
  data: {
    orderId: string;
    sagaId: string;
    correlationId: string;
  };
}
