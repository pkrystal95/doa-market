# 🔄 DOA Market 마이크로서비스 간 통신 가이드

## 📌 목차
1. [현재 아키텍처 개요](#1-현재-아키텍처-개요)
2. [서비스 간 데이터 참조 방법](#2-서비스-간-데이터-참조-방법)
3. [타입 공유 전략](#3-타입-공유-전략)
4. [실제 구현 예시](#4-실제-구현-예시)
5. [베스트 프랙티스](#5-베스트-프랙티스)

---

## 1. 현재 아키텍처 개요

### 1.1 서비스 구조

```
┌─────────────┐
│   Client    │ (Flutter App, Admin Web, Seller Web)
└──────┬──────┘
       │
       ↓
┌─────────────────┐
│  API Gateway    │ :3000 (HTTP Proxy)
└────────┬────────┘
         │
         ├─→ Auth Service        :3001
         ├─→ User Service        :3002
         ├─→ Product Service     :3003
         ├─→ Order Service       :3005
         ├─→ Payment Service     :3006
         ├─→ Wishlist Service    :3013
         └─→ ... (총 16개 서비스)
```

### 1.2 통신 패턴

#### 🔹 Pattern 1: API Gateway를 통한 프록시
- **클라이언트 → API Gateway → 개별 서비스**
- 모든 외부 요청은 API Gateway(port 3000)를 거침
- API Gateway가 요청을 적절한 서비스로 라우팅

#### 🔹 Pattern 2: 데이터 비정규화 (Denormalization)
- **서비스 간 직접 DB 참조 금지**
- 필요한 데이터를 **복사해서 저장**
- 예: Order Service는 Product 정보를 저장 (productId, productName, price 등)

#### 🔹 Pattern 3: 이벤트 기반 통신 (Event-Driven)
- **비동기 통신용**
- EventBridge를 통한 Pub/Sub 패턴
- 예: `order.created` 이벤트 → Payment Service가 구독

---

## 2. 서비스 간 데이터 참조 방법

### 2.1 현재 방식: 데이터 비정규화 + 클라이언트가 데이터 전달

**예시: 주문 생성 시**

```typescript
// ❌ 이렇게 하지 않음 (Product Service 직접 호출)
async createOrder(orderId: string) {
  // Product Service에 HTTP 요청
  const product = await axios.get(`http://localhost:3003/api/v1/products/${productId}`);
  // ...
}

// ✅ 현재 방식: 클라이언트가 필요한 모든 정보를 전달
POST /api/v1/orders
{
  "userId": "user-123",
  "items": [
    {
      "productId": "prod-456",
      "productName": "노트북",           // Product 정보를 복사
      "productImageUrl": "https://...",  // Product 정보를 복사
      "unitPrice": 1200000,              // Product 정보를 복사
      "quantity": 1
    }
  ]
}
```

**Order Service 데이터베이스 스키마:**

```typescript
@Entity('order_items')
export class OrderItem {
  @Column('uuid')
  productId: string;           // Product Service의 ID만 참조
  
  @Column('varchar')
  productName: string;         // 비정규화: Product 정보 복사
  
  @Column('text')
  productImageUrl: string;     // 비정규화: Product 정보 복사
  
  @Column('decimal')
  unitPrice: number;           // 비정규화: 주문 당시 가격 저장
}
```

### 2.2 장점과 단점

#### ✅ 장점
1. **서비스 독립성**: Order Service는 Product Service가 다운되어도 주문 조회 가능
2. **성능**: 추가 HTTP 요청 불필요
3. **데이터 일관성**: 주문 시점의 정보를 정확히 보존 (가격 변경 영향 없음)

#### ⚠️ 단점
1. **데이터 중복**: 여러 서비스에 같은 데이터 저장
2. **동기화 이슈**: Product 이름이 변경되면 Order의 데이터는 업데이트되지 않음
3. **클라이언트 부담**: 클라이언트가 여러 서비스에서 데이터를 모아야 함

---

## 3. 타입 공유 전략

### 3.1 공통 타입 패키지 (준비됨, 미사용)

```
backend/
  packages/
    common/
      src/
        types/
          api.ts      ← 공통 API 타입
          events.ts   ← 이벤트 타입
        utils/
          errors.ts   ← 공통 에러 클래스
```

**`/backend/packages/common/package.json`:**

```json
{
  "name": "@doa-market/common",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts"
}
```

**`/backend/packages/common/src/types/api.ts`:**

```typescript
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: ApiError;
  meta?: PaginationMeta;
  timestamp: string;
}

export interface PaginationQuery {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'ASC' | 'DESC';
}
```

**`/backend/packages/common/src/types/events.ts`:**

```typescript
export interface BaseEvent {
  eventId: string;
  eventType: string;
  timestamp: string;
  source: string;
  correlationId: string;
  userId?: string;
  data: any;
}

export enum EventTypes {
  PRODUCT_CREATED = 'product.created',
  ORDER_CREATED = 'order.created',
  PAYMENT_COMPLETED = 'payment.completed',
  // ...
}
```

### 3.2 현재 상황: 각 서비스가 독립적으로 타입 정의

```typescript
// backend/services/order-service/src/services/order.service.ts
export interface CreateOrderInput {
  userId: string;
  items: CreateOrderItemInput[];
  // ...
}

// backend/services/payment-service/src/services/payment.service.ts
export interface CreatePaymentInput {
  orderId: string;
  amount: number;
  // ...
}
```

**문제점:**
- 같은 데이터 구조를 여러 서비스에서 중복 정의
- 타입 불일치 가능성
- 변경 시 모든 서비스 수동 업데이트 필요

---

## 4. 실제 구현 예시

### 4.1 Case 1: Order Service에서 Product 정보가 필요한 경우

#### 현재 방식 (데이터 비정규화)

```typescript
// 1️⃣ 클라이언트: Product Service에서 상품 정보 조회
const product = await fetch('http://localhost:3000/api/v1/products/prod-456');

// 2️⃣ 클라이언트: Order Service에 주문 생성 (Product 정보 포함)
const order = await fetch('http://localhost:3000/api/v1/orders', {
  method: 'POST',
  body: JSON.stringify({
    userId: 'user-123',
    items: [{
      productId: product.id,
      productName: product.name,      // ← Product 데이터 복사
      productImageUrl: product.imageUrl,
      unitPrice: product.price,
      quantity: 1
    }]
  })
});

// 3️⃣ Order Service: 받은 데이터를 그대로 저장
await this.orderRepository.save({
  orderId: uuid(),
  userId: input.userId,
  items: input.items  // ← Product 데이터가 포함됨
});
```

#### 개선 방안: 서비스 간 직접 통신 (문서에 명시됨, 미구현)

```typescript
// Order Service에서 Product Service 호출
import axios from 'axios';

async createOrder(input: CreateOrderInput) {
  // Product Service에 직접 HTTP 요청
  const response = await axios.get(
    `http://localhost:3003/api/v1/products/${input.items[0].productId}`
  );
  
  const product = response.data.data;
  
  // 최신 Product 정보로 주문 생성
  const order = await this.orderRepository.save({
    orderId: uuid(),
    userId: input.userId,
    items: [{
      productId: product.productId,
      productName: product.name,       // ← 서비스에서 직접 가져옴
      unitPrice: product.price,
      ...
    }]
  });
  
  return order;
}
```

### 4.2 Case 2: 이벤트 기반 비동기 통신

```typescript
// Order Service: 주문 생성 후 이벤트 발행
import { EventTypes } from '@doa-market/common';

async createOrder(input: CreateOrderInput) {
  const order = await this.orderRepository.save(...);
  
  // EventBridge에 이벤트 발행
  await eventBridge.publish({
    eventType: EventTypes.ORDER_CREATED,
    source: 'order-service',
    data: {
      orderId: order.orderId,
      userId: order.userId,
      totalAmount: order.totalAmount,
    }
  });
  
  return order;
}

// Payment Service: 이벤트 구독
eventBridge.subscribe(EventTypes.ORDER_CREATED, async (event) => {
  // 주문 생성 시 자동으로 결제 프로세스 시작
  await this.paymentService.createPayment({
    orderId: event.data.orderId,
    amount: event.data.totalAmount,
  });
});
```

### 4.3 Case 3: 공통 타입 사용 (개선 방안)

```typescript
// 1️⃣ 공통 패키지에 인터페이스 정의
// backend/packages/common/src/types/order.ts
export interface OrderDTO {
  orderId: string;
  userId: string;
  totalAmount: number;
  status: 'pending' | 'confirmed' | 'cancelled';
}

// 2️⃣ Order Service에서 사용
import { OrderDTO } from '@doa-market/common';

export class OrderService {
  async getOrder(orderId: string): Promise<OrderDTO> {
    const order = await this.orderRepository.findOne({ orderId });
    return {
      orderId: order.orderId,
      userId: order.userId,
      totalAmount: order.totalAmount,
      status: order.status,
    };
  }
}

// 3️⃣ Payment Service에서도 동일한 타입 사용
import { OrderDTO } from '@doa-market/common';

export class PaymentService {
  async processPayment(order: OrderDTO) {
    // 타입 안정성 보장!
  }
}
```

---

## 5. 베스트 프랙티스

### 5.1 서비스 간 통신 결정 기준

```
┌─────────────────────────────────┬─────────────────────────────────┐
│     동기 통신 (HTTP)            │    비동기 통신 (Event)          │
├─────────────────────────────────┼─────────────────────────────────┤
│ • 즉시 응답이 필요할 때         │ • 느슨한 결합이 필요할 때       │
│ • 데이터 정합성이 중요할 때     │ • 최종 일관성으로 충분할 때     │
│ • 트랜잭션이 필요할 때          │ • 여러 서비스에 알림 필요        │
│                                 │                                 │
│ 예시:                           │ 예시:                           │
│ - 재고 확인                     │ - 주문 완료 알림                │
│ - 상품 정보 조회                │ - 정산 데이터 수집              │
│ - 쿠폰 검증                     │ - 통계 업데이트                 │
└─────────────────────────────────┴─────────────────────────────────┘
```

### 5.2 타입 공유 가이드

#### ✅ 공통 타입으로 정의해야 하는 것
- API 응답 형식 (`ApiResponse`, `PaginationMeta`)
- 이벤트 구조 (`BaseEvent`, `EventTypes`)
- 공통 에러 클래스 (`AppError`, `ValidationError`)
- 도메인 공통 타입 (예: `UserId`, `OrderId`)

#### ❌ 각 서비스에서 독립적으로 정의하는 것
- 서비스 전용 비즈니스 로직
- 데이터베이스 엔티티 (TypeORM Models)
- 서비스 내부 헬퍼 함수

### 5.3 데이터 비정규화 가이드

#### ✅ 비정규화해야 하는 경우
1. **이력 데이터**: 주문 내역, 결제 기록 (시점 데이터 보존)
2. **성능 최적화**: 자주 조회되는 데이터
3. **서비스 독립성**: 다른 서비스 장애 시에도 동작해야 함

#### ❌ 비정규화하지 말아야 하는 경우
1. **마스터 데이터**: 사용자 정보, 상품 기본 정보
2. **실시간 데이터**: 재고 수량, 포인트 잔액
3. **보안 민감 데이터**: 비밀번호, 결제 정보

### 5.4 공통 패키지 설정 (개선 방안)

#### Step 1: 공통 패키지 빌드

```bash
cd backend/packages/common
npm run build
```

#### Step 2: 각 서비스에서 의존성 추가

```json
// backend/services/order-service/package.json
{
  "dependencies": {
    "@doa-market/common": "file:../../packages/common",
    ...
  }
}
```

#### Step 3: 각 서비스에서 import

```typescript
import { 
  ApiResponse, 
  PaginationQuery, 
  EventTypes,
  AppError 
} from '@doa-market/common';
```

---

## 6. 결론

### 현재 상태 요약
- ✅ API Gateway를 통한 프록시 구현됨
- ✅ 데이터 비정규화 패턴 사용 중
- ✅ 공통 패키지 구조는 준비됨
- ⚠️ 서비스 간 직접 HTTP 통신은 미구현 (문서에만 명시)
- ⚠️ 공통 타입 패키지는 아직 사용되지 않음
- ⚠️ 이벤트 기반 통신(EventBridge)은 설계만 되어 있음

### 개선 방향
1. **공통 패키지 활성화**: 타입 공유 시작
2. **서비스 간 HTTP Client 구현**: axios 기반
3. **이벤트 버스 구현**: EventBridge 또는 RabbitMQ
4. **API 명세 문서화**: OpenAPI/Swagger로 각 서비스 API 문서화

---

## 📚 참고 문서
- [마이크로서비스 및 이벤트 정의](./02-microservices-and-events.md)
- [API Gateway 구현](../backend/api-gateway/src/server.ts)
- [공통 패키지](../backend/packages/common/)

