import { EventHandler } from './EventHandler';
import { ShippingRepository } from './ShippingRepository';
import { ShippingCarrierAPI } from './ShippingCarrierAPI';
import { EventPublisher } from './EventPublisher';
import { logger } from '../../../core/utils/logger';
import { v4 as uuidv4 } from 'uuid';

/**
 * Shipping Service Event Handler
 * 배송 관련 이벤트를 처리
 */
export class ShippingEventHandler implements EventHandler {
  constructor(
    private shippingRepository: ShippingRepository,
    private shippingCarrierAPI: ShippingCarrierAPI,
    private eventPublisher: EventPublisher
  ) {}

  /**
   * 배송 준비 요청 이벤트 처리
   * Event: shipping.prepare_requested
   */
  async handlePrepareRequested(event: ShippingPrepareRequestedEvent): Promise<void> {
    const { orderId, items, shippingAddress, correlationId, sagaId } = event.data;

    logger.info('Handling shipping prepare request', {
      orderId,
      correlationId,
      sagaId,
    });

    try {
      // 배송 레코드 생성
      const shipping = await this.shippingRepository.create({
        orderId,
        recipientName: shippingAddress.recipientName,
        phone: shippingAddress.phone,
        zipCode: shippingAddress.zipCode,
        address: shippingAddress.address,
        addressDetail: shippingAddress.addressDetail,
        status: 'preparing',
        items,
      });

      // 배송사 선택 (로직: 무게, 크기, 목적지 기반)
      const carrier = await this.selectCarrier(items, shippingAddress);

      // 배송사 API 호출 - 배송 등록
      const carrierResult = await this.shippingCarrierAPI.registerShipment({
        orderId,
        recipientName: shippingAddress.recipientName,
        phone: shippingAddress.phone,
        address: `${shippingAddress.zipCode} ${shippingAddress.address} ${shippingAddress.addressDetail}`,
        items: items.map((item) => ({
          name: item.productName,
          quantity: item.quantity,
        })),
      });

      // 배송 정보 업데이트
      await this.shippingRepository.update(shipping.id, {
        carrierId: carrier.id,
        carrierName: carrier.name,
        trackingNumber: carrierResult.trackingNumber,
        status: 'prepared',
      });

      // 배송 준비 완료 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'shipping.prepared',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        source: 'shipping-service',
        data: {
          orderId,
          shippingId: shipping.id,
          trackingNumber: carrierResult.trackingNumber,
          carrierName: carrier.name,
        },
      });

      logger.info('Shipping prepared successfully', {
        orderId,
        shippingId: shipping.id,
        trackingNumber: carrierResult.trackingNumber,
      });
    } catch (error) {
      logger.error('Failed to prepare shipping', {
        orderId,
        error: error.message,
      });

      // 배송 준비 실패 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'shipping.prepare_failed',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        source: 'shipping-service',
        data: {
          orderId,
          reason: error.message,
        },
      });
    }
  }

  /**
   * 배송 취소 요청 이벤트 처리 (보상 트랜잭션)
   * Event: shipping.cancel_requested
   */
  async handleCancelRequested(event: ShippingCancelRequestedEvent): Promise<void> {
    const { orderId, sagaId, correlationId } = event.data;

    logger.info('Handling shipping cancel request', {
      orderId,
      sagaId,
    });

    try {
      // 주문에 대한 배송 정보 조회
      const shipping = await this.shippingRepository.findByOrder(orderId);

      if (!shipping) {
        logger.warn('No shipping found for order', { orderId });
        return;
      }

      if (shipping.status === 'dispatched' || shipping.status === 'in_transit') {
        logger.warn('Shipping already dispatched, cannot cancel', {
          orderId,
          status: shipping.status,
        });

        // 이미 발송된 경우 반품 프로세스 시작
        await this.initiateReturn(shipping);
        return;
      }

      // 배송사 API 호출 - 배송 취소
      if (shipping.trackingNumber) {
        await this.shippingCarrierAPI.cancelShipment(shipping.trackingNumber);
      }

      // 배송 상태 업데이트
      await this.shippingRepository.update(shipping.id, {
        status: 'cancelled',
        cancelledAt: new Date(),
      });

      // 배송 취소 완료 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'shipping.cancelled',
        eventId: uuidv4(),
        correlationId,
        sagaId,
        timestamp: new Date().toISOString(),
        source: 'shipping-service',
        data: {
          orderId,
          shippingId: shipping.id,
        },
      });

      logger.info('Shipping cancelled successfully', {
        orderId,
        shippingId: shipping.id,
      });
    } catch (error) {
      logger.error('Failed to cancel shipping', {
        orderId,
        error: error.message,
      });
    }
  }

  /**
   * 결제 완료 이벤트 처리 - 배송 시작
   * Event: payment.completed
   */
  async handlePaymentCompleted(event: PaymentCompletedEvent): Promise<void> {
    const { orderId } = event.data;

    logger.info('Payment completed, dispatching shipment', { orderId });

    try {
      const shipping = await this.shippingRepository.findByOrder(orderId);

      if (!shipping) {
        logger.error('No shipping found for order', { orderId });
        return;
      }

      // 배송 출고 처리
      await this.shippingCarrierAPI.dispatchShipment(shipping.trackingNumber!);

      // 배송 상태 업데이트
      await this.shippingRepository.update(shipping.id, {
        status: 'dispatched',
        dispatchedAt: new Date(),
      });

      // 배송 출고 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'shipping.dispatched',
        eventId: uuidv4(),
        correlationId: event.correlationId,
        sagaId: event.sagaId,
        timestamp: new Date().toISOString(),
        source: 'shipping-service',
        data: {
          orderId,
          shippingId: shipping.id,
          trackingNumber: shipping.trackingNumber,
          carrierName: shipping.carrierName,
          estimatedDeliveryDate: this.calculateEstimatedDelivery(),
        },
      });

      logger.info('Shipment dispatched', {
        orderId,
        trackingNumber: shipping.trackingNumber,
      });
    } catch (error) {
      logger.error('Failed to dispatch shipment', {
        orderId,
        error: error.message,
      });
    }
  }

  /**
   * 배송사 선택 로직
   */
  private async selectCarrier(items: any[], address: any): Promise<Carrier> {
    // 실제로는 무게, 크기, 배송지, 배송사 API 상태 등을 고려
    // 여기서는 간단히 기본 배송사 반환
    return {
      id: 'cj-logistics',
      name: 'CJ대한통운',
    };
  }

  /**
   * 예상 배송일 계산
   */
  private calculateEstimatedDelivery(): Date {
    const deliveryDays = 2; // 2일 후
    const estimatedDate = new Date();
    estimatedDate.setDate(estimatedDate.getDate() + deliveryDays);
    return estimatedDate;
  }

  /**
   * 반품 프로세스 시작
   */
  private async initiateReturn(shipping: any): Promise<void> {
    logger.info('Initiating return process', {
      orderId: shipping.orderId,
      shippingId: shipping.id,
    });

    // 반품 프로세스 시작 이벤트 발행
    await this.eventPublisher.publish({
      eventType: 'return.initiated',
      eventId: uuidv4(),
      correlationId: uuidv4(),
      sagaId: shipping.sagaId,
      timestamp: new Date().toISOString(),
      source: 'shipping-service',
      data: {
        orderId: shipping.orderId,
        shippingId: shipping.id,
        reason: 'order_cancelled_after_dispatch',
      },
    });
  }
}

// Types
interface ShippingPrepareRequestedEvent {
  eventType: 'shipping.prepare_requested';
  data: {
    orderId: string;
    items: any[];
    shippingAddress: any;
    correlationId: string;
    sagaId: string;
  };
}

interface ShippingCancelRequestedEvent {
  eventType: 'shipping.cancel_requested';
  data: {
    orderId: string;
    sagaId: string;
    correlationId: string;
  };
}

interface PaymentCompletedEvent {
  eventType: 'payment.completed';
  data: {
    orderId: string;
  };
  correlationId: string;
  sagaId: string;
}

interface Carrier {
  id: string;
  name: string;
}
