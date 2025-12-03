import { v4 as uuidv4 } from 'uuid';
import { EventPublisher } from './EventPublisher';
import { OrderRepository } from './OrderRepository';
import { logger } from '../../../core/utils/logger';

/**
 * Order Saga - 주문 처리를 위한 Saga 패턴 구현
 * Orchestration 방식으로 주문 프로세스를 관리
 */
export class OrderSaga {
  constructor(
    private eventPublisher: EventPublisher,
    private orderRepository: OrderRepository
  ) {}

  /**
   * 주문 생성 Saga 시작
   * 1. 주문 생성 (Order Service)
   * 2. 재고 예약 (Inventory Service)
   * 3. 결제 처리 (Payment Service)
   * 4. 배송 준비 (Shipping Service)
   * 5. 알림 발송 (Notification Service)
   */
  async createOrder(orderData: CreateOrderRequest): Promise<OrderSagaResult> {
    const sagaId = uuidv4();
    const correlationId = uuidv4();

    logger.info('Order Saga started', { sagaId, correlationId });

    try {
      // Step 1: Create Order
      const order = await this.createOrderStep(orderData, sagaId, correlationId);

      // Step 2: Reserve Inventory
      await this.reserveInventoryStep(order, sagaId, correlationId);

      // Step 3: Process Payment
      await this.processPaymentStep(order, sagaId, correlationId);

      // Step 4: Prepare Shipping
      await this.prepareShippingStep(order, sagaId, correlationId);

      // Step 5: Send Notifications
      await this.sendNotificationsStep(order, sagaId, correlationId);

      logger.info('Order Saga completed successfully', { sagaId, orderId: order.id });

      return {
        success: true,
        orderId: order.id,
        sagaId,
      };
    } catch (error) {
      logger.error('Order Saga failed, starting compensation', {
        sagaId,
        error,
      });

      // 실패 시 보상 트랜잭션 실행
      await this.compensate(sagaId, correlationId);

      return {
        success: false,
        error: error.message,
        sagaId,
      };
    }
  }

  /**
   * Step 1: 주문 생성
   */
  private async createOrderStep(
    orderData: CreateOrderRequest,
    sagaId: string,
    correlationId: string
  ): Promise<Order> {
    logger.info('[Saga Step 1] Creating order', { sagaId });

    // 주문 생성
    const order = await this.orderRepository.create({
      userId: orderData.userId,
      items: orderData.items,
      shippingAddress: orderData.shippingAddress,
      paymentMethod: orderData.paymentMethod,
      totalAmount: this.calculateTotalAmount(orderData.items),
      status: 'pending',
      sagaId,
    });

    // 주문 생성 이벤트 발행
    await this.eventPublisher.publish({
      eventType: 'order.created',
      eventId: uuidv4(),
      correlationId,
      sagaId,
      timestamp: new Date().toISOString(),
      data: {
        orderId: order.id,
        userId: order.userId,
        items: order.items,
        totalAmount: order.totalAmount,
      },
    });

    logger.info('[Saga Step 1] Order created', {
      sagaId,
      orderId: order.id,
    });

    return order;
  }

  /**
   * Step 2: 재고 예약
   */
  private async reserveInventoryStep(
    order: Order,
    sagaId: string,
    correlationId: string
  ): Promise<void> {
    logger.info('[Saga Step 2] Reserving inventory', { sagaId, orderId: order.id });

    // 재고 예약 요청 이벤트 발행
    await this.eventPublisher.publish({
      eventType: 'inventory.reserve_requested',
      eventId: uuidv4(),
      correlationId,
      sagaId,
      timestamp: new Date().toISOString(),
      data: {
        orderId: order.id,
        items: order.items.map((item) => ({
          productId: item.productId,
          variantId: item.variantId,
          quantity: item.quantity,
        })),
      },
    });

    // 재고 예약 완료 이벤트 대기 (실제로는 메시지 큐에서 수신)
    await this.waitForEvent('inventory.reserved', correlationId, 30000);

    logger.info('[Saga Step 2] Inventory reserved', { sagaId, orderId: order.id });

    // 주문 상태 업데이트
    await this.orderRepository.update(order.id, {
      status: 'inventory_reserved',
    });
  }

  /**
   * Step 3: 결제 처리
   */
  private async processPaymentStep(
    order: Order,
    sagaId: string,
    correlationId: string
  ): Promise<void> {
    logger.info('[Saga Step 3] Processing payment', { sagaId, orderId: order.id });

    // 결제 요청 이벤트 발행
    await this.eventPublisher.publish({
      eventType: 'payment.requested',
      eventId: uuidv4(),
      correlationId,
      sagaId,
      timestamp: new Date().toISOString(),
      data: {
        orderId: order.id,
        userId: order.userId,
        amount: order.totalAmount,
        paymentMethod: order.paymentMethod,
      },
    });

    // 결제 완료 이벤트 대기
    await this.waitForEvent('payment.completed', correlationId, 60000);

    logger.info('[Saga Step 3] Payment processed', { sagaId, orderId: order.id });

    // 주문 상태 업데이트
    await this.orderRepository.update(order.id, {
      status: 'paid',
    });
  }

  /**
   * Step 4: 배송 준비
   */
  private async prepareShippingStep(
    order: Order,
    sagaId: string,
    correlationId: string
  ): Promise<void> {
    logger.info('[Saga Step 4] Preparing shipping', { sagaId, orderId: order.id });

    // 배송 준비 요청 이벤트 발행
    await this.eventPublisher.publish({
      eventType: 'shipping.prepare_requested',
      eventId: uuidv4(),
      correlationId,
      sagaId,
      timestamp: new Date().toISOString(),
      data: {
        orderId: order.id,
        items: order.items,
        shippingAddress: order.shippingAddress,
      },
    });

    // 배송 준비 완료 이벤트 대기
    await this.waitForEvent('shipping.prepared', correlationId, 30000);

    logger.info('[Saga Step 4] Shipping prepared', { sagaId, orderId: order.id });

    // 주문 상태 업데이트
    await this.orderRepository.update(order.id, {
      status: 'preparing',
    });
  }

  /**
   * Step 5: 알림 발송
   */
  private async sendNotificationsStep(
    order: Order,
    sagaId: string,
    correlationId: string
  ): Promise<void> {
    logger.info('[Saga Step 5] Sending notifications', { sagaId, orderId: order.id });

    // 알림 발송 이벤트 발행 (Fire and Forget)
    await this.eventPublisher.publish({
      eventType: 'notification.send_requested',
      eventId: uuidv4(),
      correlationId,
      sagaId,
      timestamp: new Date().toISOString(),
      data: {
        orderId: order.id,
        userId: order.userId,
        type: 'order_confirmed',
        channels: ['email', 'push', 'sms'],
      },
    });

    logger.info('[Saga Step 5] Notifications sent', { sagaId, orderId: order.id });
  }

  /**
   * 보상 트랜잭션 (Compensation)
   * Saga 실패 시 이미 수행된 단계들을 롤백
   */
  private async compensate(sagaId: string, correlationId: string): Promise<void> {
    logger.warn('Starting compensation transaction', { sagaId });

    try {
      // 배송 취소
      await this.eventPublisher.publish({
        eventType: 'shipping.cancel_requested',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        data: { sagaId },
      });

      // 결제 취소
      await this.eventPublisher.publish({
        eventType: 'payment.refund_requested',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        data: { sagaId },
      });

      // 재고 복구
      await this.eventPublisher.publish({
        eventType: 'inventory.release_requested',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        data: { sagaId },
      });

      // 주문 취소
      await this.eventPublisher.publish({
        eventType: 'order.cancelled',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        data: { sagaId, reason: 'saga_compensation' },
      });

      logger.info('Compensation completed', { sagaId });
    } catch (error) {
      logger.error('Compensation failed', { sagaId, error });
      // Manual intervention required
      throw new Error('Compensation failed - manual intervention required');
    }
  }

  /**
   * 특정 이벤트 대기 (타임아웃 포함)
   */
  private async waitForEvent(
    eventType: string,
    correlationId: string,
    timeout: number
  ): Promise<void> {
    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        reject(new Error(`Timeout waiting for event: ${eventType}`));
      }, timeout);

      // 실제로는 메시지 큐에서 이벤트를 수신하여 처리
      // 여기서는 시뮬레이션
      const eventHandler = (event: any) => {
        if (event.correlationId === correlationId && event.eventType === eventType) {
          clearTimeout(timeoutId);
          resolve();
        }
      };

      // Event listener 등록 (실제 구현에서는 SQS/EventBridge 사용)
      // this.eventBus.on(eventType, eventHandler);
    });
  }

  private calculateTotalAmount(items: OrderItem[]): number {
    return items.reduce((total, item) => total + item.unitPrice * item.quantity, 0);
  }
}

// Types
interface CreateOrderRequest {
  userId: string;
  items: OrderItem[];
  shippingAddress: Address;
  paymentMethod: string;
}

interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  shippingAddress: Address;
  paymentMethod: string;
  totalAmount: number;
  status: string;
  sagaId: string;
}

interface OrderItem {
  productId: string;
  variantId?: string;
  quantity: number;
  unitPrice: number;
}

interface Address {
  recipientName: string;
  phone: string;
  zipCode: string;
  address: string;
  addressDetail: string;
}

interface OrderSagaResult {
  success: boolean;
  orderId?: string;
  error?: string;
  sagaId: string;
}
