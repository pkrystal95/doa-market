import { EventHandler } from './EventHandler';
import { InventoryRepository } from './InventoryRepository';
import { EventPublisher } from './EventPublisher';
import { logger } from '../../../core/utils/logger';
import { v4 as uuidv4 } from 'uuid';

/**
 * Inventory Service Event Handler
 * 재고 관련 이벤트를 처리
 */
export class InventoryEventHandler implements EventHandler {
  constructor(
    private inventoryRepository: InventoryRepository,
    private eventPublisher: EventPublisher
  ) {}

  /**
   * 재고 예약 요청 이벤트 처리
   * Event: inventory.reserve_requested
   */
  async handleReserveRequested(event: InventoryReserveRequestedEvent): Promise<void> {
    const { orderId, items, correlationId, sagaId } = event.data;

    logger.info('Handling inventory reserve request', {
      orderId,
      correlationId,
      sagaId,
    });

    try {
      // 재고 확인 및 예약
      const reservationResults = await Promise.all(
        items.map(async (item) => {
          const inventory = await this.inventoryRepository.findByProduct(
            item.productId,
            item.variantId
          );

          if (!inventory || inventory.availableQuantity < item.quantity) {
            throw new Error(
              `Insufficient inventory for product ${item.productId}, variant ${item.variantId}`
            );
          }

          // 재고 예약 (available_quantity 감소, reserved_quantity 증가)
          await this.inventoryRepository.reserve({
            productId: item.productId,
            variantId: item.variantId,
            quantity: item.quantity,
            orderId,
            reservationId: uuidv4(),
            expiresAt: new Date(Date.now() + 30 * 60 * 1000), // 30분 후 만료
          });

          return {
            productId: item.productId,
            variantId: item.variantId,
            reserved: item.quantity,
          };
        })
      );

      // 재고 예약 성공 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'inventory.reserved',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        source: 'inventory-service',
        data: {
          orderId,
          reservations: reservationResults,
        },
      });

      logger.info('Inventory reserved successfully', {
        orderId,
        correlationId,
      });
    } catch (error) {
      logger.error('Failed to reserve inventory', {
        orderId,
        correlationId,
        error: error.message,
      });

      // 재고 예약 실패 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'inventory.reserve_failed',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        source: 'inventory-service',
        data: {
          orderId,
          reason: error.message,
        },
      });
    }
  }

  /**
   * 재고 해제 요청 이벤트 처리 (보상 트랜잭션)
   * Event: inventory.release_requested
   */
  async handleReleaseRequested(event: InventoryReleaseRequestedEvent): Promise<void> {
    const { orderId, sagaId, correlationId } = event.data;

    logger.info('Handling inventory release request', {
      orderId,
      sagaId,
      correlationId,
    });

    try {
      // 주문에 대한 모든 재고 예약 해제
      await this.inventoryRepository.releaseByOrder(orderId);

      // 재고 해제 완료 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'inventory.released',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        source: 'inventory-service',
        data: {
          orderId,
        },
      });

      logger.info('Inventory released successfully', { orderId });
    } catch (error) {
      logger.error('Failed to release inventory', {
        orderId,
        error: error.message,
      });
    }
  }

  /**
   * 주문 완료 이벤트 처리
   * Event: order.completed
   * 예약된 재고를 실제로 차감
   */
  async handleOrderCompleted(event: OrderCompletedEvent): Promise<void> {
    const { orderId, items } = event.data;

    logger.info('Handling order completed event', { orderId });

    try {
      // 예약된 재고를 실제 차감으로 확정
      await Promise.all(
        items.map(async (item) => {
          await this.inventoryRepository.confirmReservation(
            item.productId,
            item.variantId,
            orderId
          );
        })
      );

      logger.info('Inventory confirmed for completed order', { orderId });
    } catch (error) {
      logger.error('Failed to confirm inventory', {
        orderId,
        error: error.message,
      });
    }
  }

  /**
   * 주문 취소 이벤트 처리
   * Event: order.cancelled
   * 예약된 재고를 해제
   */
  async handleOrderCancelled(event: OrderCancelledEvent): Promise<void> {
    const { orderId } = event.data;

    logger.info('Handling order cancelled event', { orderId });

    try {
      // 재고 예약 해제
      await this.inventoryRepository.releaseByOrder(orderId);

      logger.info('Inventory released for cancelled order', { orderId });
    } catch (error) {
      logger.error('Failed to release inventory for cancelled order', {
        orderId,
        error: error.message,
      });
    }
  }
}

// Types
interface InventoryReserveRequestedEvent {
  eventType: 'inventory.reserve_requested';
  data: {
    orderId: string;
    items: Array<{
      productId: string;
      variantId?: string;
      quantity: number;
    }>;
    correlationId: string;
    sagaId: string;
  };
}

interface InventoryReleaseRequestedEvent {
  eventType: 'inventory.release_requested';
  data: {
    orderId: string;
    sagaId: string;
    correlationId: string;
  };
}

interface OrderCompletedEvent {
  eventType: 'order.completed';
  data: {
    orderId: string;
    items: Array<{
      productId: string;
      variantId?: string;
      quantity: number;
    }>;
  };
}

interface OrderCancelledEvent {
  eventType: 'order.cancelled';
  data: {
    orderId: string;
  };
}
