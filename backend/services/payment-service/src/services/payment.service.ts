import { Repository } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { AppDataSource } from '@config/database';
import { Payment, PaymentMethod, PaymentStatus } from '@models/Payment';
import logger from '@utils/logger';

export interface CreatePaymentInput {
  orderId: string;
  userId: string;
  amount: number;
  paymentMethod: PaymentMethod;
  cardNumber?: string;
  cardType?: string;
  cardIssuer?: string;
}

export class PaymentService {
  private repository: Repository<Payment>;

  constructor() {
    this.repository = AppDataSource.getRepository(Payment);
  }

  async createPayment(input: CreatePaymentInput): Promise<Payment> {
    const existingPayment = await this.repository.findOne({
      where: { orderId: input.orderId },
    });

    if (existingPayment) {
      throw new Error('Payment already exists for this order');
    }

    const payment = this.repository.create({
      paymentId: uuidv4(),
      orderId: input.orderId,
      userId: input.userId,
      amount: input.amount,
      paymentMethod: input.paymentMethod,
      status: PaymentStatus.PENDING,
      currency: 'KRW',
      cardNumber: input.cardNumber ? this.maskCardNumber(input.cardNumber) : null,
      cardType: input.cardType || null,
      cardIssuer: input.cardIssuer || null,
    });

    await this.repository.save(payment);
    logger.info(`Payment created: ${payment.paymentId} for order: ${input.orderId}`);

    return payment;
  }

  async processPayment(paymentId: string): Promise<Payment> {
    const payment = await this.repository.findOne({ where: { paymentId } });

    if (!payment) {
      throw new Error('Payment not found');
    }

    if (payment.status !== PaymentStatus.PENDING) {
      throw new Error('Payment cannot be processed');
    }

    // Simulate PG processing
    const pgResponse = await this.simulatePGRequest(payment);

    if (pgResponse.success) {
      payment.status = PaymentStatus.COMPLETED;
      payment.paidAt = new Date();
      payment.pgProvider = pgResponse.provider;
      payment.pgTransactionId = pgResponse.transactionId;
      payment.pgResponse = pgResponse;
      payment.receiptUrl = pgResponse.receiptUrl;
    } else {
      payment.status = PaymentStatus.FAILED;
      payment.failureReason = pgResponse.message;
      payment.pgResponse = pgResponse;
    }

    await this.repository.save(payment);
    logger.info(`Payment processed: ${paymentId} - Status: ${payment.status}`);

    return payment;
  }

  async getPayment(paymentId: string): Promise<Payment | null> {
    return this.repository.findOne({ where: { paymentId } });
  }

  async getPaymentByOrder(orderId: string): Promise<Payment | null> {
    return this.repository.findOne({ where: { orderId } });
  }

  async cancelPayment(paymentId: string, reason: string): Promise<Payment> {
    const payment = await this.repository.findOne({ where: { paymentId } });

    if (!payment) {
      throw new Error('Payment not found');
    }

    if (payment.status !== PaymentStatus.COMPLETED) {
      throw new Error('Only completed payments can be cancelled');
    }

    payment.status = PaymentStatus.CANCELLED;
    payment.cancelledAt = new Date();
    payment.cancelReason = reason;

    await this.repository.save(payment);
    logger.info(`Payment cancelled: ${paymentId}`);

    return payment;
  }

  async refundPayment(
    paymentId: string,
    amount: number,
    reason: string
  ): Promise<Payment> {
    const payment = await this.repository.findOne({ where: { paymentId } });

    if (!payment) {
      throw new Error('Payment not found');
    }

    if (payment.status !== PaymentStatus.COMPLETED) {
      throw new Error('Only completed payments can be refunded');
    }

    if (amount > payment.amount) {
      throw new Error('Refund amount cannot exceed payment amount');
    }

    const isPartialRefund = amount < payment.amount;

    payment.status = isPartialRefund
      ? PaymentStatus.PARTIAL_REFUNDED
      : PaymentStatus.REFUNDED;
    payment.refundedAt = new Date();
    payment.refundAmount = amount;
    payment.refundReason = reason;

    await this.repository.save(payment);
    logger.info(`Payment refunded: ${paymentId} - Amount: ${amount}`);

    return payment;
  }

  private maskCardNumber(cardNumber: string): string {
    const cleaned = cardNumber.replace(/\s/g, '');
    if (cleaned.length < 8) return '****';
    return cleaned.slice(0, 4) + '****' + cleaned.slice(-4);
  }

  private async simulatePGRequest(payment: Payment): Promise<any> {
    // Simulate PG processing delay
    await new Promise((resolve) => setTimeout(resolve, 1000));

    // 90% success rate simulation
    const success = Math.random() < 0.9;

    if (success) {
      return {
        success: true,
        provider: 'SIMULATED_PG',
        transactionId: `TXN_${uuidv4()}`,
        message: 'Payment processed successfully',
        receiptUrl: `https://example.com/receipt/${payment.paymentId}`,
        processedAt: new Date().toISOString(),
      };
    } else {
      return {
        success: false,
        provider: 'SIMULATED_PG',
        transactionId: null,
        message: 'Payment failed - Insufficient funds or card declined',
        processedAt: new Date().toISOString(),
      };
    }
  }
}
