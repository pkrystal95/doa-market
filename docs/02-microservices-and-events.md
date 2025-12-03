# 2단계: 마이크로서비스 목록 및 이벤트 흐름 정의

## 목차
- [마이크로서비스 상세 정의](#1-마이크로서비스-상세-정의)
- [이벤트 정의](#2-이벤트-정의)
- [서비스 간 통신 패턴](#3-서비스-간-통신-패턴)
- [주요 비즈니스 플로우](#4-주요-비즈니스-플로우별-이벤트-체인)
- [서비스 간 의존성 매트릭스](#5-서비스-간-의존성-매트릭스)
- [이벤트 버스 라우팅 규칙](#6-이벤트-버스-라우팅-규칙)

---

## 1. 마이크로서비스 상세 정의

### 1.1 Auth Service (인증 서비스)
**포트**: 3001
**책임**: 인증, 인가, 토큰 관리

**주요 기능**:
- 로그인/로그아웃 (이메일, 소셜 로그인)
- JWT Access/Refresh Token 발급 및 검증
- Cognito 연동 (선택적)
- 비밀번호 재설정
- 2FA (Two-Factor Authentication)
- 세션 관리

**데이터베이스**:
- RDS: `users_db.auth_tokens`, `users_db.refresh_tokens`
- DynamoDB: `Sessions`

**발행 이벤트**:
- `auth.user.login`
- `auth.user.logout`
- `auth.token.refreshed`
- `auth.password.reset`

**구독 이벤트**: 없음

---

### 1.2 User Service (사용자 서비스)
**포트**: 3002
**책임**: 사용자 프로필 및 정보 관리

**주요 기능**:
- 사용자 회원가입 (일반, 판매자)
- 프로필 조회/수정
- 배송지 관리 (CRUD)
- 찜 목록 관리
- 최근 본 상품
- 사용자 등급 관리

**데이터베이스**:
- RDS: `users_db.users`, `users_db.addresses`
- DynamoDB: `Wishlists`, `ProductViews`

**발행 이벤트**:
- `user.created`
- `user.updated`
- `user.deleted`
- `user.address.created`

**구독 이벤트**:
- `order.completed` (사용자 구매 이력 업데이트)
- `payment.completed` (사용자 등급 계산)

---

### 1.3 Product Service (상품 서비스)
**포트**: 3003
**책임**: 상품 정보 관리

**주요 기능**:
- 상품 등록/수정/삭제 (판매자)
- 카테고리 관리
- 상품 옵션 관리 (색상, 사이즈 등)
- 상품 상세 조회
- 상품 목록 조회 (필터링, 정렬)
- 상품 이미지 관리

**데이터베이스**:
- RDS: `products_db.products`, `products_db.categories`, `products_db.product_options`
- OpenSearch: `products` 인덱스 (검색용)
- S3: 상품 이미지

**발행 이벤트**:
- `product.created`
- `product.updated`
- `product.deleted`
- `product.stock.changed`

**구독 이벤트**:
- `order.item.confirmed` (재고 차감 확정)
- `order.cancelled` (재고 복구)
- `inventory.adjusted` (재고 동기화)

---

### 1.4 Order Service (주문 서비스)
**포트**: 3004
**책임**: 주문 생성 및 라이프사이클 관리

**주요 기능**:
- 장바구니 관리
- 주문 생성 (단일/다중 상품)
- 주문 조회/취소
- 주문 상태 추적
- 주문 히스토리

**데이터베이스**:
- RDS: `orders_db.orders`, `orders_db.order_items`
- DynamoDB: `Carts`, `OrderEvents` (이벤트 소싱)

**발행 이벤트**:
- `order.created`
- `order.item.confirmed`
- `order.cancelled`
- `order.completed`
- `order.refund.requested`

**구독 이벤트**:
- `payment.completed` (주문 상태 → 결제완료)
- `payment.failed` (주문 취소)
- `shipping.dispatched` (주문 상태 → 배송중)
- `shipping.delivered` (주문 상태 → 배송완료)

---

### 1.5 Payment Service (결제 서비스)
**포트**: 3005
**책임**: 결제 처리 및 PG 연동

**주요 기능**:
- 결제 요청 처리
- PG사 연동 (토스페이먼츠, 이니시스 등)
- 결제 승인/취소
- 환불 처리
- 결제 내역 조회
- 결제 수단 관리 (카드, 계좌이체 등)

**데이터베이스**:
- RDS: `payments_db.payments`, `payments_db.refunds`, `payments_db.payment_methods`

**발행 이벤트**:
- `payment.requested`
- `payment.completed`
- `payment.failed`
- `payment.refunded`
- `payment.cancelled`

**구독 이벤트**:
- `order.created` (결제 프로세스 시작)
- `order.cancelled` (결제 취소)
- `order.refund.requested` (환불 처리)

---

### 1.6 Shipping Service (배송 서비스)
**포트**: 3006
**책임**: 배송 처리 및 물류 관리

**주요 기능**:
- 배송 요청 생성
- 택배사 API 연동 (CJ대한통운, 로젠택배 등)
- 배송 추적
- 배송 상태 업데이트
- 반품/교환 배송 처리

**데이터베이스**:
- RDS: `orders_db.shipments`, `orders_db.tracking`

**발행 이벤트**:
- `shipping.requested`
- `shipping.dispatched`
- `shipping.in_transit`
- `shipping.delivered`
- `shipping.failed`
- `shipping.return.requested`

**구독 이벤트**:
- `payment.completed` (배송 준비 시작)
- `order.cancelled` (배송 취소)

---

### 1.7 Seller Service (판매자 서비스)
**포트**: 3007
**책임**: 판매자 정보 및 스토어 관리

**주요 기능**:
- 판매자 회원가입/인증
- 스토어 정보 관리
- 사업자 정보 관리
- 판매 대시보드
- 판매자 등급 관리

**데이터베이스**:
- RDS: `users_db.sellers`, `users_db.stores`, `users_db.business_info`

**발행 이벤트**:
- `seller.created`
- `seller.verified`
- `seller.suspended`
- `store.updated`

**구독 이벤트**:
- `order.created` (판매자 알림)
- `settlement.completed` (판매자 정산 알림)

---

### 1.8 Settlement Service (정산 서비스)
**포트**: 3008
**책임**: 판매자 정산 관리

**주요 기능**:
- 정산 데이터 집계
- 정산 금액 계산 (수수료, 배송비, 쿠폰 차감)
- 정산 내역 생성
- 정산서 발급
- 정산 지급 처리

**데이터베이스**:
- RDS: `settlements_db.settlements`, `settlements_db.settlement_items`
- S3: 정산서 PDF

**발행 이벤트**:
- `settlement.calculated`
- `settlement.completed`
- `settlement.paid`

**구독 이벤트**:
- `order.completed` (정산 데이터 수집)
- `order.refund.completed` (정산 차감)
- `shipping.delivered` (정산 확정)

---

### 1.9 Coupon Service (쿠폰 서비스)
**포트**: 3009
**책임**: 쿠폰 및 프로모션 관리

**주요 기능**:
- 쿠폰 생성/삭제
- 쿠폰 발급 (사용자별, 전체)
- 쿠폰 사용 검증
- 프로모션 관리
- 할인 계산

**데이터베이스**:
- RDS: `products_db.coupons`, `products_db.user_coupons`
- Redis: 쿠폰 재고 (선착순)

**발행 이벤트**:
- `coupon.created`
- `coupon.issued`
- `coupon.used`
- `coupon.expired`

**구독 이벤트**:
- `order.created` (쿠폰 사용 처리)
- `order.cancelled` (쿠폰 복구)

---

### 1.10 Inventory Service (재고 서비스)
**포트**: 3010
**책임**: 재고 실시간 관리

**주요 기능**:
- 재고 조회
- 재고 예약 (주문 시)
- 재고 차감 (결제 완료 시)
- 재고 복구 (주문 취소 시)
- 재고 조정 (입고, 출고)
- 재고 부족 알림

**데이터베이스**:
- RDS: `products_db.inventory`
- Redis: 실시간 재고 캐시

**발행 이벤트**:
- `inventory.reserved`
- `inventory.adjusted`
- `inventory.low_stock`
- `inventory.out_of_stock`

**구독 이벤트**:
- `order.created` (재고 예약)
- `payment.completed` (재고 확정 차감)
- `order.cancelled` (재고 복구)

---

### 1.11 Notification Service (알림 서비스)
**포트**: 3011
**책임**: 통합 알림 발송

**주요 기능**:
- 푸시 알림 (FCM, APNS)
- 이메일 발송 (SES)
- SMS 발송 (SNS)
- 알림 템플릿 관리
- 알림 히스토리
- 알림 설정 관리 (사용자별)

**데이터베이스**:
- DynamoDB: `Notifications`, `NotificationSettings`

**발행 이벤트**:
- `notification.sent`
- `notification.failed`

**구독 이벤트**:
- `order.created` → "주문이 접수되었습니다"
- `payment.completed` → "결제가 완료되었습니다"
- `shipping.dispatched` → "상품이 발송되었습니다"
- `shipping.delivered` → "배송이 완료되었습니다"
- `settlement.completed` → "정산이 완료되었습니다"

---

### 1.12 Review Service (리뷰 서비스)
**포트**: 3012
**책임**: 상품 리뷰 및 평점 관리

**주요 기능**:
- 리뷰 작성/수정/삭제
- 리뷰 조회 (상품별, 사용자별)
- 평점 계산
- 리뷰 이미지 관리
- 베스트 리뷰 선정

**데이터베이스**:
- RDS: `products_db.reviews`
- S3: 리뷰 이미지

**발행 이벤트**:
- `review.created`
- `review.updated`
- `review.deleted`

**구독 이벤트**:
- `shipping.delivered` (리뷰 작성 가능 알림)

---

### 1.13 Search Service (검색 서비스)
**포트**: 3013
**책임**: 통합 검색

**주요 기능**:
- 상품 전문 검색
- 자동 완성
- 검색어 추천
- 인기 검색어
- 필터링 (가격, 카테고리, 브랜드 등)
- 정렬 (인기순, 낮은가격순, 높은가격순 등)

**데이터베이스**:
- OpenSearch: `products`, `orders`
- Redis: 검색어 캐시, 인기 검색어

**발행 이벤트**: 없음

**구독 이벤트**:
- `product.created` (검색 인덱스 추가)
- `product.updated` (검색 인덱스 업데이트)
- `product.deleted` (검색 인덱스 삭제)

---

### 1.14 Admin Service (관리자 서비스)
**포트**: 3014
**책임**: 관리자 기능

**주요 기능**:
- 전체 데이터 조회 (읽기 전용)
- 사용자 관리 (정지, 복구)
- 판매자 승인/거부
- 상품 심사
- 통계 대시보드
- 공지사항 관리
- 시스템 설정

**데이터베이스**:
- 모든 DB에 읽기 권한
- RDS: `admin_db.notices`, `admin_db.system_configs`

**발행 이벤트**:
- `admin.user.suspended`
- `admin.seller.approved`
- `admin.notice.published`

**구독 이벤트**: 모든 이벤트 (모니터링 목적)

---

### 1.15 File Service (파일 서비스)
**포트**: 3015
**책임**: 파일 업로드/다운로드

**주요 기능**:
- 이미지 업로드 (S3)
- 이미지 리사이징 (Lambda)
- Presigned URL 생성
- 파일 삭제
- CDN 캐시 무효화

**데이터베이스**:
- S3: 모든 파일
- RDS: `files_db.file_metadata`

**발행 이벤트**:
- `file.uploaded`
- `file.deleted`

**구독 이벤트**: 없음

---

### 1.16 Stats Service (통계 서비스)
**포트**: 3016
**책임**: 데이터 분석 및 통계

**주요 기능**:
- 실시간 통계 집계
- 판매 통계 (일/주/월)
- 사용자 행동 분석
- 상품 조회수 추적
- 매출 분석
- 리포트 생성

**데이터베이스**:
- OpenSearch: `analytics`
- DynamoDB: `ProductViews`, `ClickEvents`

**발행 이벤트**:
- `stats.daily.calculated`
- `stats.report.generated`

**구독 이벤트**:
- `order.completed` (매출 통계)
- `product.created` (상품 통계)
- `user.created` (가입자 통계)

---

## 2. 이벤트 정의

### 2.1 이벤트 네이밍 규칙
```
<domain>.<entity>.<action>

예시:
- order.created
- payment.completed
- shipping.dispatched
```

### 2.2 이벤트 페이로드 표준 구조

```typescript
interface BaseEvent {
  eventId: string;          // UUID
  eventType: string;        // order.created
  eventVersion: string;     // v1
  timestamp: string;        // ISO 8601
  source: string;           // order-service
  correlationId: string;    // 추적 ID
  userId?: string;
  metadata: {
    traceId: string;        // X-Ray Trace ID
    environment: string;    // production, staging
  };
  data: any;               // 이벤트별 페이로드
}
```

### 2.3 주요 이벤트 상세 정의

#### Order Events

```typescript
// order.created
{
  eventType: "order.created",
  data: {
    orderId: string;
    userId: string;
    sellerId: string;
    items: [
      {
        productId: string;
        quantity: number;
        price: number;
        options: object;
      }
    ];
    totalAmount: number;
    shippingAddress: {
      recipient: string;
      phone: string;
      address: string;
      zipCode: string;
    };
    paymentMethod: string;
    couponId?: string;
  }
}

// order.cancelled
{
  eventType: "order.cancelled",
  data: {
    orderId: string;
    userId: string;
    reason: string;
    cancelledAt: string;
  }
}

// order.completed
{
  eventType: "order.completed",
  data: {
    orderId: string;
    completedAt: string;
  }
}
```

#### Payment Events

```typescript
// payment.completed
{
  eventType: "payment.completed",
  data: {
    paymentId: string;
    orderId: string;
    amount: number;
    method: string;  // card, transfer, virtual_account
    pgTransactionId: string;
    paidAt: string;
  }
}

// payment.failed
{
  eventType: "payment.failed",
  data: {
    paymentId: string;
    orderId: string;
    reason: string;
    errorCode: string;
    failedAt: string;
  }
}

// payment.refunded
{
  eventType: "payment.refunded",
  data: {
    refundId: string;
    paymentId: string;
    orderId: string;
    amount: number;
    reason: string;
    refundedAt: string;
  }
}
```

#### Shipping Events

```typescript
// shipping.dispatched
{
  eventType: "shipping.dispatched",
  data: {
    shipmentId: string;
    orderId: string;
    carrier: string;           // CJ, LOTTE, HANJIN
    trackingNumber: string;
    estimatedDelivery: string;
    dispatchedAt: string;
  }
}

// shipping.delivered
{
  eventType: "shipping.delivered",
  data: {
    shipmentId: string;
    orderId: string;
    deliveredAt: string;
    recipient: string;
  }
}
```

#### Product Events

```typescript
// product.created
{
  eventType: "product.created",
  data: {
    productId: string;
    sellerId: string;
    name: string;
    price: number;
    categoryId: string;
    stock: number;
  }
}

// product.stock.changed
{
  eventType: "product.stock.changed",
  data: {
    productId: string;
    previousStock: number;
    currentStock: number;
    changedBy: string;
  }
}
```

#### Inventory Events

```typescript
// inventory.reserved
{
  eventType: "inventory.reserved",
  data: {
    productId: string;
    orderId: string;
    quantity: number;
    reservationId: string;
  }
}

// inventory.low_stock
{
  eventType: "inventory.low_stock",
  data: {
    productId: string;
    currentStock: number;
    threshold: number;
  }
}
```

---

## 3. 서비스 간 통신 패턴

### 3.1 동기 통신 (REST API)
**사용 케이스**: 즉시 응답이 필요한 경우

```
User Service ─[HTTP GET]→ Product Service
  "사용자가 상품 상세를 조회할 때"

Order Service ─[HTTP POST]→ Inventory Service
  "주문 시 재고 확인이 필요할 때"

Admin Service ─[HTTP GET]→ 모든 서비스
  "관리자가 데이터를 조회할 때"
```

### 3.2 비동기 통신 (Event-Driven)
**사용 케이스**: 느슨한 결합, 최종 일관성 허용

```
Order Service ─[Event]→ EventBridge ─[Event]→ Payment Service
Order Service ─[Event]→ EventBridge ─[Event]→ Notification Service
Order Service ─[Event]→ EventBridge ─[Event]→ Stats Service
```

---

## 4. 주요 비즈니스 플로우별 이벤트 체인

### 4.1 상품 주문 완전한 플로우

```
[1] User App → Order Service
    POST /api/v1/orders
    ↓

[2] Order Service (동기)
    ├─→ Inventory Service (재고 확인/예약)
    ├─→ Coupon Service (쿠폰 검증)
    └─→ Product Service (상품 정보 검증)
    ↓

[3] Order Service → EventBridge
    Publish: order.created
    ↓
    ├─→ [Payment Service] payment.requested
    ├─→ [Notification Service] "주문 접수 알림"
    ├─→ [Seller Service] "신규 주문 알림"
    └─→ [Stats Service] 주문 통계 집계
    ↓

[4] Payment Service → PG API
    결제 승인 요청
    ↓

[5] Payment Service → EventBridge
    Publish: payment.completed
    ↓
    ├─→ [Order Service] 주문 상태 → "결제완료"
    ├─→ [Inventory Service] 재고 확정 차감
    ├─→ [Shipping Service] 배송 준비 시작
    ├─→ [Notification Service] "결제 완료 알림"
    └─→ [Settlement Service] 정산 데이터 수집
    ↓

[6] Shipping Service → 택배사 API
    배송 요청
    ↓

[7] Shipping Service → EventBridge
    Publish: shipping.dispatched
    ↓
    ├─→ [Order Service] 주문 상태 → "배송중"
    ├─→ [Notification Service] "배송 시작 알림"
    └─→ [User Service] 구매 이력 업데이트
    ↓

[8] Shipping Service → EventBridge (배송 완료 시)
    Publish: shipping.delivered
    ↓
    ├─→ [Order Service] 주문 상태 → "배송완료"
    ├─→ [Notification Service] "배송 완료 알림" + "리뷰 작성 요청"
    ├─→ [Settlement Service] 정산 확정
    └─→ [User Service] 사용자 등급 업데이트
    ↓

[9] Settlement Service → EventBridge (정산 처리 시)
    Publish: settlement.completed
    ↓
    ├─→ [Seller Service] 정산 완료 알림
    └─→ [Notification Service] 정산서 발송
```

### 4.2 주문 취소 플로우

```
[1] User App → Order Service
    POST /api/v1/orders/{orderId}/cancel
    ↓

[2] Order Service → EventBridge
    Publish: order.cancelled
    ↓
    ├─→ [Payment Service] 환불 처리 시작
    ├─→ [Inventory Service] 재고 복구
    ├─→ [Coupon Service] 쿠폰 복구
    ├─→ [Shipping Service] 배송 취소 (미발송시)
    └─→ [Notification Service] "주문 취소 알림"
    ↓

[3] Payment Service → EventBridge
    Publish: payment.refunded
    ↓
    ├─→ [Order Service] 주문 상태 → "환불완료"
    ├─→ [Settlement Service] 정산 차감
    └─→ [Notification Service] "환불 완료 알림"
```

### 4.3 재고 부족 플로우

```
[1] Inventory Service (주기적 체크 or 재고 변동 시)
    재고 < 임계값
    ↓

[2] Inventory Service → EventBridge
    Publish: inventory.low_stock
    ↓
    ├─→ [Notification Service] 판매자에게 재고 부족 알림
    ├─→ [Product Service] 상품 상태 업데이트 (품절임박)
    └─→ [Admin Service] 관리자 대시보드 알림
```

### 4.4 상품 등록 플로우

```
[1] Seller Web → Product Service
    POST /api/v1/products
    ↓

[2] Product Service → EventBridge
    Publish: product.created
    ↓
    ├─→ [Search Service] OpenSearch 인덱스 추가
    ├─→ [Inventory Service] 초기 재고 설정
    ├─→ [Admin Service] 상품 심사 대기 목록 추가
    └─→ [Stats Service] 상품 통계 업데이트
    ↓

[3] Admin Service (심사 완료 후)
    PATCH /api/v1/admin/products/{id}/approve
    ↓

[4] Product Service → EventBridge
    Publish: product.approved
    ↓
    └─→ [Notification Service] 판매자에게 승인 알림
```

---

## 5. 서비스 간 의존성 매트릭스

| 서비스 | 동기 호출 대상 | 이벤트 발행 | 이벤트 구독 |
|--------|--------------|------------|------------|
| Auth | User | auth.* | - |
| User | - | user.* | order.completed, payment.completed |
| Product | File | product.* | order.item.confirmed, order.cancelled |
| Order | Inventory, Coupon, Product | order.* | payment.*, shipping.* |
| Payment | PG API | payment.* | order.created, order.cancelled |
| Shipping | Carrier API | shipping.* | payment.completed, order.cancelled |
| Seller | - | seller.* | order.created, settlement.completed |
| Settlement | - | settlement.* | order.completed, shipping.delivered |
| Coupon | - | coupon.* | order.created, order.cancelled |
| Inventory | - | inventory.* | order.created, payment.completed, order.cancelled |
| Notification | SES, SNS, FCM | notification.* | 거의 모든 이벤트 |
| Review | File | review.* | shipping.delivered |
| Search | OpenSearch | - | product.*, order.* |
| Admin | 모든 서비스 (읽기) | admin.* | 모든 이벤트 (모니터링) |
| File | S3 | file.* | - |
| Stats | OpenSearch | stats.* | order.*, product.*, user.* |

---

## 6. 이벤트 버스 라우팅 규칙

EventBridge Rules 예시:

```typescript
// Rule 1: 주문 생성 시 결제 서비스로 라우팅
{
  "EventPattern": {
    "source": ["order-service"],
    "detail-type": ["order.created"]
  },
  "Targets": [
    { "Arn": "arn:aws:sqs:...:payment-queue" },
    { "Arn": "arn:aws:sqs:...:notification-queue" },
    { "Arn": "arn:aws:sqs:...:stats-queue" }
  ]
}

// Rule 2: 결제 완료 시 여러 서비스로 라우팅
{
  "EventPattern": {
    "source": ["payment-service"],
    "detail-type": ["payment.completed"]
  },
  "Targets": [
    { "Arn": "arn:aws:sqs:...:order-queue" },
    { "Arn": "arn:aws:sqs:...:shipping-queue" },
    { "Arn": "arn:aws:sqs:...:inventory-queue" },
    { "Arn": "arn:aws:sqs:...:settlement-queue" },
    { "Arn": "arn:aws:lambda:...:notification-handler" }
  ]
}

// Rule 3: 배송 완료 시
{
  "EventPattern": {
    "source": ["shipping-service"],
    "detail-type": ["shipping.delivered"]
  },
  "Targets": [
    { "Arn": "arn:aws:sqs:...:order-queue" },
    { "Arn": "arn:aws:sqs:...:settlement-queue" },
    { "Arn": "arn:aws:lambda:...:review-reminder-handler" }
  ]
}
```

---

**작성일**: 2025-12-03
**버전**: 1.0
