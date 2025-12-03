import { EventHandler } from './EventHandler';
import { NotificationService } from './NotificationService';
import { logger } from '../../../core/utils/logger';

/**
 * Notification Service Event Handler
 * 알림 관련 이벤트를 처리
 */
export class NotificationEventHandler implements EventHandler {
  constructor(private notificationService: NotificationService) {}

  /**
   * 알림 발송 요청 이벤트 처리
   * Event: notification.send_requested
   */
  async handleSendRequested(event: NotificationSendRequestedEvent): Promise<void> {
    const { orderId, userId, type, channels } = event.data;

    logger.info('Handling notification send request', {
      orderId,
      userId,
      type,
      channels,
    });

    try {
      // 각 채널별로 알림 발송
      await Promise.all(
        channels.map(async (channel) => {
          switch (channel) {
            case 'email':
              await this.notificationService.sendEmail({
                userId,
                templateId: `order_${type}`,
                data: { orderId },
              });
              break;

            case 'push':
              await this.notificationService.sendPush({
                userId,
                title: this.getNotificationTitle(type),
                body: this.getNotificationBody(type, orderId),
                data: { orderId, type },
              });
              break;

            case 'sms':
              await this.notificationService.sendSMS({
                userId,
                message: this.getSMSMessage(type, orderId),
              });
              break;
          }
        })
      );

      logger.info('Notifications sent successfully', {
        orderId,
        channels,
      });
    } catch (error) {
      logger.error('Failed to send notifications', {
        orderId,
        error: error.message,
      });
      // 알림 실패는 치명적이지 않으므로 에러를 throw하지 않음
    }
  }

  /**
   * 주문 생성 이벤트 처리
   * Event: order.created
   */
  async handleOrderCreated(event: OrderCreatedEvent): Promise<void> {
    const { orderId, userId } = event.data;

    logger.info('Sending order confirmation notification', { orderId, userId });

    await this.notificationService.sendMultiChannel({
      userId,
      channels: ['email', 'push'],
      type: 'order_confirmed',
      data: { orderId },
    });
  }

  /**
   * 배송 출고 이벤트 처리
   * Event: shipping.dispatched
   */
  async handleShippingDispatched(event: ShippingDispatchedEvent): Promise<void> {
    const { orderId, trackingNumber, carrierName } = event.data;

    logger.info('Sending shipping notification', {
      orderId,
      trackingNumber,
    });

    // 사용자에게 배송 시작 알림
    await this.notificationService.sendMultiChannel({
      userId: event.data.userId,
      channels: ['push', 'sms'],
      type: 'shipping_started',
      data: {
        orderId,
        trackingNumber,
        carrierName,
      },
    });
  }

  /**
   * 배송 완료 이벤트 처리
   * Event: shipping.delivered
   */
  async handleShippingDelivered(event: ShippingDeliveredEvent): Promise<void> {
    const { orderId, userId } = event.data;

    logger.info('Sending delivery notification', { orderId });

    await this.notificationService.sendMultiChannel({
      userId,
      channels: ['email', 'push', 'sms'],
      type: 'delivery_completed',
      data: { orderId },
    });
  }

  /**
   * 주문 취소 이벤트 처리
   * Event: order.cancelled
   */
  async handleOrderCancelled(event: OrderCancelledEvent): Promise<void> {
    const { orderId, userId, reason } = event.data;

    logger.info('Sending cancellation notification', { orderId });

    await this.notificationService.sendMultiChannel({
      userId,
      channels: ['email', 'push'],
      type: 'order_cancelled',
      data: { orderId, reason },
    });
  }

  private getNotificationTitle(type: string): string {
    const titles: Record<string, string> = {
      order_confirmed: '주문이 완료되었습니다',
      shipping_started: '상품이 발송되었습니다',
      delivery_completed: '배송이 완료되었습니다',
      order_cancelled: '주문이 취소되었습니다',
    };
    return titles[type] || '알림';
  }

  private getNotificationBody(type: string, orderId: string): string {
    const bodies: Record<string, string> = {
      order_confirmed: `주문번호 ${orderId}의 결제가 완료되었습니다.`,
      shipping_started: `주문번호 ${orderId}의 상품이 발송되었습니다.`,
      delivery_completed: `주문번호 ${orderId}의 배송이 완료되었습니다.`,
      order_cancelled: `주문번호 ${orderId}가 취소되었습니다.`,
    };
    return bodies[type] || '';
  }

  private getSMSMessage(type: string, orderId: string): string {
    return `[DOA Market] ${this.getNotificationTitle(type)} 주문번호: ${orderId}`;
  }
}

// Types
interface NotificationSendRequestedEvent {
  eventType: 'notification.send_requested';
  data: {
    orderId: string;
    userId: string;
    type: string;
    channels: string[];
  };
}

interface OrderCreatedEvent {
  eventType: 'order.created';
  data: {
    orderId: string;
    userId: string;
  };
}

interface ShippingDispatchedEvent {
  eventType: 'shipping.dispatched';
  data: {
    orderId: string;
    userId: string;
    trackingNumber: string;
    carrierName: string;
  };
}

interface ShippingDeliveredEvent {
  eventType: 'shipping.delivered';
  data: {
    orderId: string;
    userId: string;
  };
}

interface OrderCancelledEvent {
  eventType: 'order.cancelled';
  data: {
    orderId: string;
    userId: string;
    reason: string;
  };
}
