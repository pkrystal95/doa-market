# 11. 이벤트 기반 주문 처리 흐름 구현 예시

## 개요

이 문서는 DOA Market의 이벤트 기반 아키텍처를 활용한 주문 처리 흐름의 완전한 구현 예시를 제공합니다.

## Saga 패턴

분산 트랜잭션을 관리하기 위해 **Orchestration 기반 Saga 패턴**을 사용합니다.

### Saga 패턴 선택 이유

1. **Choreography vs Orchestration**
   - Choreography: 각 서비스가 독립적으로 이벤트를 발행하고 구독
   - Orchestration: 중앙 조정자(Saga)가 전체 프로세스를 관리

2. **Orchestration 선택 이유**
   - 복잡한 비즈니스 로직을 한 곳에서 관리
   - 전체 흐름 파악 용이
   - 보상 트랜잭션 관리 명확
   - 디버깅 및 모니터링 쉬움

## 주문 처리 흐름

```
User → Order Service (Saga Orchestrator)
          ↓
          ├──→ Inventory Service (재고 예약)
          │         ↓
          │    inventory.reserved
          │         ↓
          ├──→ Payment Service (결제 처리)
          │         ↓
          │    payment.completed
          │         ↓
          ├──→ Shipping Service (배송 준비)
          │         ↓
          │    shipping.prepared
          │         ↓
          └──→ Notification Service (알림 발송)
                    ↓
               order.completed
```

## 1. Order Saga (주문 오케스트레이터)

```typescript
// examples/event-driven-order-flow/order-service/OrderSaga.ts

export class OrderSaga {
  /**
   * 주문 생성 Saga 시작
   */
  async createOrder(orderData: CreateOrderRequest): Promise<OrderSagaResult> {
    const sagaId = uuidv4();
    const correlationId = uuidv4();

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

      return { success: true, orderId: order.id, sagaId };
    } catch (error) {
      // 실패 시 보상 트랜잭션 실행
      await this.compensate(sagaId, correlationId);
      return { success: false, error: error.message, sagaId };
    }
  }

  /**
   * Step 1: 주문 생성
   */
  private async createOrderStep(orderData, sagaId, correlationId) {
    const order = await this.orderRepository.create({
      ...orderData,
      status: 'pending',
      sagaId,
    });

    // 이벤트 발행
    await this.eventPublisher.publish({
      eventType: 'order.created',
      correlationId,
      sagaId,
      data: {
        orderId: order.id,
        userId: order.userId,
        items: order.items,
        totalAmount: order.totalAmount,
      },
    });

    return order;
  }

  /**
   * Step 2: 재고 예약
   */
  private async reserveInventoryStep(order, sagaId, correlationId) {
    // 재고 예약 요청 이벤트 발행
    await this.eventPublisher.publish({
      eventType: 'inventory.reserve_requested',
      correlationId,
      sagaId,
      data: {
        orderId: order.id,
        items: order.items,
      },
    });

    // 재고 예약 완료 이벤트 대기
    await this.waitForEvent('inventory.reserved', correlationId, 30000);

    // 주문 상태 업데이트
    await this.orderRepository.update(order.id, {
      status: 'inventory_reserved',
    });
  }

  /**
   * 보상 트랜잭션 (Compensation)
   */
  private async compensate(sagaId: string, correlationId: string) {
    // 배송 취소
    await this.eventPublisher.publish({
      eventType: 'shipping.cancel_requested',
      correlationId,
      sagaId,
      data: { sagaId },
    });

    // 결제 취소
    await this.eventPublisher.publish({
      eventType: 'payment.refund_requested',
      correlationId,
      sagaId,
      data: { sagaId },
    });

    // 재고 복구
    await this.eventPublisher.publish({
      eventType: 'inventory.release_requested',
      correlationId,
      sagaId,
      data: { sagaId },
    });

    // 주문 취소
    await this.eventPublisher.publish({
      eventType: 'order.cancelled',
      correlationId,
      sagaId,
      data: { sagaId, reason: 'saga_compensation' },
    });
  }
}
```

**핵심 개념:**
- `sagaId`: Saga 인스턴스 식별자
- `correlationId`: 모든 관련 이벤트를 추적하는 ID
- 각 단계는 이벤트 발행 → 응답 대기 패턴
- 실패 시 자동 보상 트랜잭션 실행

## 2. Inventory Service (재고 서비스)

```typescript
// examples/event-driven-order-flow/inventory-service/InventoryEventHandler.ts

export class InventoryEventHandler {
  /**
   * 재고 예약 요청 처리
   * Event: inventory.reserve_requested
   */
  async handleReserveRequested(event) {
    const { orderId, items, correlationId, sagaId } = event.data;

    try {
      // 재고 확인 및 예약
      const reservations = await Promise.all(
        items.map(async (item) => {
          const inventory = await this.inventoryRepository.findByProduct(
            item.productId,
            item.variantId
          );

          if (inventory.availableQuantity < item.quantity) {
            throw new Error('Insufficient inventory');
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

          return { productId: item.productId, reserved: item.quantity };
        })
      );

      // 재고 예약 성공 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'inventory.reserved',
        correlationId,
        sagaId,
        data: { orderId, reservations },
      });
    } catch (error) {
      // 재고 예약 실패 이벤트 발행
      await this.eventPublisher.publish({
        eventType: 'inventory.reserve_failed',
        correlationId,
        sagaId,
        data: { orderId, reason: error.message },
      });
    }
  }

  /**
   * 재고 해제 요청 처리 (보상 트랜잭션)
   * Event: inventory.release_requested
   */
  async handleReleaseRequested(event) {
    const { orderId, sagaId, correlationId } = event.data;

    // 주문에 대한 모든 재고 예약 해제
    await this.inventoryRepository.releaseByOrder(orderId);

    // 재고 해제 완료 이벤트 발행
    await this.eventPublisher.publish({
      eventType: 'inventory.released',
      correlationId,
      sagaId,
      data: { orderId },
    });
  }
}
```

**핵심 기능:**
- 재고 예약 시 `availableQuantity` 감소, `reservedQuantity` 증가
- 30분 후 자동 만료 (타임아웃)
- 보상 트랜잭션으로 재고 복구

## 3. Payment Service (결제 서비스)

```typescript
// examples/event-driven-order-flow/payment-service/PaymentEventHandler.ts

export class PaymentEventHandler {
  /**
   * 결제 요청 처리
   * Event: payment.requested
   */
  async handlePaymentRequested(event) {
    const { orderId, userId, amount, paymentMethod, correlationId, sagaId } = event.data;

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
          correlationId,
          sagaId,
          data: {
            orderId,
            paymentId: payment.id,
            transactionId: pgResult.transactionId,
            amount,
          },
        });
      } else {
        // 결제 실패
        await this.eventPublisher.publish({
          eventType: 'payment.failed',
          correlationId,
          sagaId,
          data: { orderId, reason: pgResult.errorMessage },
        });
      }
    } catch (error) {
      await this.eventPublisher.publish({
        eventType: 'payment.failed',
        correlationId,
        sagaId,
        data: { orderId, reason: error.message },
      });
    }
  }

  /**
   * 환불 요청 처리 (보상 트랜잭션)
   * Event: payment.refund_requested
   */
  async handleRefundRequested(event) {
    const { orderId, sagaId, correlationId } = event.data;

    const payment = await this.paymentRepository.findByOrder(orderId);

    if (payment && payment.status === 'completed') {
      // PG사 환불 요청
      const refundResult = await this.paymentGateway.refund({
        transactionId: payment.transactionId,
        amount: payment.amount,
        reason: 'Order cancelled - Saga compensation',
      });

      if (refundResult.success) {
        await this.paymentRepository.update(payment.id, {
          status: 'refunded',
          refundedAt: new Date(),
        });

        await this.eventPublisher.publish({
          eventType: 'payment.refunded',
          correlationId,
          sagaId,
          data: { orderId, paymentId: payment.id },
        });
      } else {
        // 환불 실패는 치명적 - 수동 개입 필요
        await this.sendCriticalAlert({
          type: 'REFUND_FAILED',
          orderId,
          paymentId: payment.id,
        });
      }
    }
  }
}
```

**핵심 기능:**
- PG사 API 연동 (실제 결제 처리)
- 환불 실패 시 Critical Alert 발송
- 결제 상태 관리 (pending → completed/failed)

## 4. Shipping Service (배송 서비스)

```typescript
// examples/event-driven-order-flow/shipping-service/ShippingEventHandler.ts

export class ShippingEventHandler {
  /**
   * 배송 준비 요청 처리
   * Event: shipping.prepare_requested
   */
  async handlePrepareRequested(event) {
    const { orderId, items, shippingAddress, correlationId, sagaId } = event.data;

    try {
      // 배송 레코드 생성
      const shipping = await this.shippingRepository.create({
        orderId,
        ...shippingAddress,
        status: 'preparing',
        items,
      });

      // 배송사 선택
      const carrier = await this.selectCarrier(items, shippingAddress);

      // 배송사 API 호출 - 배송 등록
      const carrierResult = await this.shippingCarrierAPI.registerShipment({
        orderId,
        ...shippingAddress,
        items,
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
        correlationId,
        sagaId,
        data: {
          orderId,
          shippingId: shipping.id,
          trackingNumber: carrierResult.trackingNumber,
          carrierName: carrier.name,
        },
      });
    } catch (error) {
      await this.eventPublisher.publish({
        eventType: 'shipping.prepare_failed',
        correlationId,
        sagaId,
        data: { orderId, reason: error.message },
      });
    }
  }

  /**
   * 배송 취소 요청 처리 (보상 트랜잭션)
   * Event: shipping.cancel_requested
   */
  async handleCancelRequested(event) {
    const { orderId, sagaId } = event.data;

    const shipping = await this.shippingRepository.findByOrder(orderId);

    if (shipping.status === 'dispatched') {
      // 이미 발송된 경우 반품 프로세스 시작
      await this.initiateReturn(shipping);
      return;
    }

    // 배송사 API 호출 - 배송 취소
    if (shipping.trackingNumber) {
      await this.shippingCarrierAPI.cancelShipment(shipping.trackingNumber);
    }

    await this.shippingRepository.update(shipping.id, {
      status: 'cancelled',
      cancelledAt: new Date(),
    });

    await this.eventPublisher.publish({
      eventType: 'shipping.cancelled',
      sagaId,
      data: { orderId, shippingId: shipping.id },
    });
  }

  /**
   * 결제 완료 시 배송 출고
   * Event: payment.completed
   */
  async handlePaymentCompleted(event) {
    const { orderId } = event.data;

    const shipping = await this.shippingRepository.findByOrder(orderId);

    // 배송 출고 처리
    await this.shippingCarrierAPI.dispatchShipment(shipping.trackingNumber);

    await this.shippingRepository.update(shipping.id, {
      status: 'dispatched',
      dispatchedAt: new Date(),
    });

    // 배송 출고 이벤트 발행
    await this.eventPublisher.publish({
      eventType: 'shipping.dispatched',
      data: {
        orderId,
        trackingNumber: shipping.trackingNumber,
        carrierName: shipping.carrierName,
        estimatedDeliveryDate: this.calculateEstimatedDelivery(),
      },
    });
  }
}
```

**핵심 기능:**
- 배송사 API 연동
- 이미 발송된 경우 반품 프로세스 시작
- 배송 상태 관리 (preparing → prepared → dispatched → delivered)

## 5. Notification Service (알림 서비스)

```typescript
// examples/event-driven-order-flow/notification-service/NotificationEventHandler.ts

export class NotificationEventHandler {
  /**
   * 주문 생성 알림
   * Event: order.created
   */
  async handleOrderCreated(event) {
    const { orderId, userId } = event.data;

    await this.notificationService.sendMultiChannel({
      userId,
      channels: ['email', 'push'],
      type: 'order_confirmed',
      data: { orderId },
    });
  }

  /**
   * 배송 출고 알림
   * Event: shipping.dispatched
   */
  async handleShippingDispatched(event) {
    const { orderId, userId, trackingNumber, carrierName } = event.data;

    await this.notificationService.sendMultiChannel({
      userId,
      channels: ['push', 'sms'],
      type: 'shipping_started',
      data: { orderId, trackingNumber, carrierName },
    });
  }

  /**
   * 배송 완료 알림
   * Event: shipping.delivered
   */
  async handleShippingDelivered(event) {
    const { orderId, userId } = event.data;

    await this.notificationService.sendMultiChannel({
      userId,
      channels: ['email', 'push', 'sms'],
      type: 'delivery_completed',
      data: { orderId },
    });
  }
}
```

**핵심 기능:**
- Multi-channel 알림 (Email, Push, SMS)
- Fire-and-forget 방식 (실패해도 Saga에 영향 없음)
- 템플릿 기반 메시지 생성

## 이벤트 흐름 시퀀스

### 성공 케이스

```
1. User → POST /api/v1/orders
2. Order Service: order.created → EventBridge
3. Inventory Service: inventory.reserve_requested → inventory.reserved
4. Payment Service: payment.requested → payment.completed
5. Shipping Service: shipping.prepare_requested → shipping.prepared
6. Notification Service: notification.send_requested → (Email, Push, SMS)
7. Shipping Service: shipping.dispatched (결제 완료 후)
8. Notification Service: 배송 시작 알림
9. Shipping Service: shipping.delivered (배송사 콜백)
10. Notification Service: 배송 완료 알림
```

### 실패 케이스 (결제 실패)

```
1. User → POST /api/v1/orders
2. Order Service: order.created → EventBridge
3. Inventory Service: inventory.reserved (재고 예약 성공)
4. Payment Service: payment.failed (결제 실패)
5. Order Service: Saga 보상 트랜잭션 시작
6. Inventory Service: inventory.release_requested → inventory.released
7. Order Service: order.cancelled
8. Notification Service: 주문 취소 알림
```

## EventBridge 룰 설정

```yaml
# EventBridge Rules

# Rule 1: Order Created → Multiple Services
order-created-rule:
  eventPattern:
    source: order-service
    detail-type: order.created
  targets:
    - inventory-service-queue
    - notification-service-queue
    - stats-service-queue

# Rule 2: Inventory Reserved → Order Service
inventory-reserved-rule:
  eventPattern:
    source: inventory-service
    detail-type: inventory.reserved
  targets:
    - order-service-queue

# Rule 3: Payment Completed → Multiple Services
payment-completed-rule:
  eventPattern:
    source: payment-service
    detail-type: payment.completed
  targets:
    - order-service-queue
    - shipping-service-queue
    - notification-service-queue

# Rule 4: Shipping Dispatched → Notification
shipping-dispatched-rule:
  eventPattern:
    source: shipping-service
    detail-type: shipping.dispatched
  targets:
    - notification-service-queue
```

## SQS 큐 구성

```yaml
# SQS Queues

order-service-queue:
  visibility_timeout: 300s  # 5분
  message_retention: 14days
  dlq: order-service-dlq
  max_receive_count: 3

inventory-service-queue:
  visibility_timeout: 60s   # 1분
  message_retention: 14days
  dlq: inventory-service-dlq
  max_receive_count: 3

payment-service-queue:
  visibility_timeout: 300s  # 5분 (PG 처리 시간)
  message_retention: 14days
  dlq: payment-service-dlq
  max_receive_count: 3

# Dead Letter Queues
*-dlq:
  message_retention: 14days
  alarm: CloudWatch Alarm (메시지 수신 시)
```

## 모니터링 및 추적

### 1. Correlation ID

모든 관련 이벤트를 추적할 수 있는 ID:

```typescript
const correlationId = uuidv4();

// 모든 이벤트에 포함
event.correlationId = correlationId;

// CloudWatch Logs Insights 쿼리
fields @timestamp, @message
| filter correlationId = "abc-123-def-456"
| sort @timestamp asc
```

### 2. Saga State 관리

```typescript
// Saga 상태 저장 (DynamoDB)
{
  sagaId: "saga-uuid",
  orderId: "order-uuid",
  status: "in_progress",
  currentStep: "payment",
  steps: [
    { name: "create_order", status: "completed", timestamp: "..." },
    { name: "reserve_inventory", status: "completed", timestamp: "..." },
    { name: "process_payment", status: "in_progress", timestamp: "..." },
  ],
  compensated: false,
  createdAt: "...",
  updatedAt: "...",
}
```

### 3. X-Ray 분산 트레이싱

```typescript
const AWSXRay = require('aws-xray-sdk');

// Segment 생성
const segment = AWSXRay.getSegment();
segment.addAnnotation('sagaId', sagaId);
segment.addAnnotation('orderId', orderId);
segment.addMetadata('orderDetails', orderData);
```

## 에러 처리 전략

1. **Retry (재시도)**
   - 일시적 오류 (네트워크, 타임아웃)
   - SQS 자동 재시도 (max 3회)

2. **Compensation (보상)**
   - 비즈니스 로직 실패
   - Saga 보상 트랜잭션 실행

3. **Dead Letter Queue**
   - 3회 재시도 후에도 실패
   - 수동 개입 필요

4. **Circuit Breaker**
   - 연속 실패 감지
   - 일시적으로 요청 차단

## 핵심 설계 원칙

1. **멱등성 (Idempotency)**
   - 같은 이벤트를 여러 번 처리해도 결과 동일
   - eventId로 중복 처리 방지

2. **At-Least-Once Delivery**
   - SQS는 최소 1회 전달 보장
   - 멱등성으로 중복 처리 대응

3. **Eventual Consistency**
   - 최종적으로 일관성 보장
   - 실시간 일관성은 보장 안 함

4. **Timeout 관리**
   - 각 단계마다 타임아웃 설정
   - 타임아웃 시 보상 트랜잭션

## 다음 단계

다음 문서에서는:
- 보안 설계 (IAM, WAF, VPC, Secret Manager)
- 모니터링 설계 (CloudWatch, X-Ray, OpenSearch)

를 다룹니다.
