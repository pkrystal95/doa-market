# 4단계: API 설계 (OpenAPI/Swagger)

## 목차
- [API 설계 원칙](#api-설계-원칙)
- [공통 스펙](#공통-스펙)
- [서비스별 API](#서비스별-api)
  - [Auth Service](#1-auth-service-api)
  - [User Service](#2-user-service-api)
  - [Product Service](#3-product-service-api)
  - [Order Service](#4-order-service-api)
  - [Payment Service](#5-payment-service-api)
  - [Shipping Service](#6-shipping-service-api)
  - [Seller Service](#7-seller-service-api)
  - [Settlement Service](#8-settlement-service-api)
  - [Coupon Service](#9-coupon-service-api)
  - [Inventory Service](#10-inventory-service-api)
  - [Notification Service](#11-notification-service-api)
  - [Review Service](#12-review-service-api)
  - [Search Service](#13-search-service-api)
  - [Admin Service](#14-admin-service-api)
  - [File Service](#15-file-service-api)
  - [Stats Service](#16-stats-service-api)

---

## API 설계 원칙

### 1. RESTful API 규칙

#### URL 구조
```
https://api.doamarket.com/api/v1/{resource}
```

#### HTTP 메서드
| 메서드 | 용도 | 멱등성 |
|--------|------|--------|
| GET | 리소스 조회 | O |
| POST | 리소스 생성 | X |
| PUT | 리소스 전체 수정 | O |
| PATCH | 리소스 부분 수정 | X |
| DELETE | 리소스 삭제 | O |

#### HTTP 상태 코드
| 코드 | 의미 | 사용 케이스 |
|------|------|------------|
| 200 | OK | 성공적인 GET, PUT, PATCH, DELETE |
| 201 | Created | 성공적인 POST (리소스 생성) |
| 204 | No Content | 성공적인 DELETE (응답 바디 없음) |
| 400 | Bad Request | 잘못된 요청 (유효성 검증 실패) |
| 401 | Unauthorized | 인증 필요 |
| 403 | Forbidden | 권한 없음 |
| 404 | Not Found | 리소스를 찾을 수 없음 |
| 409 | Conflict | 리소스 충돌 (중복 등) |
| 422 | Unprocessable Entity | 비즈니스 로직 오류 |
| 429 | Too Many Requests | Rate Limit 초과 |
| 500 | Internal Server Error | 서버 오류 |
| 503 | Service Unavailable | 서비스 일시 중단 |

### 2. 페이지네이션

#### 커서 기반 페이지네이션 (추천)
```
GET /api/v1/products?cursor=eyJpZCI6MTIzfQ&limit=20
```

#### 오프셋 기반 페이지네이션
```
GET /api/v1/products?page=1&limit=20
```

### 3. 필터링 및 정렬

```
GET /api/v1/products?category=electronics&minPrice=10000&maxPrice=50000&sort=price&order=asc
```

### 4. 검색

```
GET /api/v1/products/search?q=노트북&category=electronics
```

### 5. 인증 헤더

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 6. Rate Limiting

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

---

## 공통 스펙

### 공통 요청 헤더

```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
X-Request-ID: {uuid}
X-Client-Version: 1.0.0
Accept-Language: ko-KR
```

### 공통 응답 구조

#### 성공 응답 (단일 리소스)
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "상품명",
    ...
  },
  "timestamp": "2025-01-01T00:00:00Z"
}
```

#### 성공 응답 (목록)
```json
{
  "success": true,
  "data": [
    { "id": "uuid1", ... },
    { "id": "uuid2", ... }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  },
  "timestamp": "2025-01-01T00:00:00Z"
}
```

#### 에러 응답
```json
{
  "success": false,
  "error": {
    "code": "PRODUCT_NOT_FOUND",
    "message": "상품을 찾을 수 없습니다",
    "details": {
      "productId": "abc-123"
    },
    "traceId": "trace-uuid"
  },
  "timestamp": "2025-01-01T00:00:00Z"
}
```

### 에러 코드 정의

| 코드 | HTTP 상태 | 설명 |
|------|-----------|------|
| INVALID_REQUEST | 400 | 잘못된 요청 |
| VALIDATION_ERROR | 400 | 유효성 검증 실패 |
| UNAUTHORIZED | 401 | 인증 필요 |
| FORBIDDEN | 403 | 권한 없음 |
| NOT_FOUND | 404 | 리소스 없음 |
| ALREADY_EXISTS | 409 | 이미 존재함 |
| OUT_OF_STOCK | 422 | 재고 부족 |
| PAYMENT_FAILED | 422 | 결제 실패 |
| RATE_LIMIT_EXCEEDED | 429 | Rate Limit 초과 |
| INTERNAL_ERROR | 500 | 서버 오류 |

---

## 서비스별 API

## 1. Auth Service API

**Base URL**: `https://api.doamarket.com/api/v1/auth`

### 1.1 회원가입

```yaml
POST /auth/register
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "name": "홍길동",
  "phone": "010-1234-5678",
  "role": "customer"  // customer, seller
}

Response (201):
{
  "success": true,
  "data": {
    "userId": "uuid",
    "email": "user@example.com",
    "name": "홍길동",
    "role": "customer"
  }
}

Response (409):
{
  "success": false,
  "error": {
    "code": "EMAIL_ALREADY_EXISTS",
    "message": "이미 사용 중인 이메일입니다"
  }
}
```

### 1.2 로그인

```yaml
POST /auth/login
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}

Response (200):
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 3600,
    "tokenType": "Bearer",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "홍길동",
      "role": "customer",
      "userGrade": "bronze"
    }
  }
}

Response (401):
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "이메일 또는 비밀번호가 올바르지 않습니다"
  }
}
```

### 1.3 토큰 갱신

```yaml
POST /auth/refresh
Content-Type: application/json

Request Body:
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}

Response (200):
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 3600
  }
}
```

### 1.4 로그아웃

```yaml
POST /auth/logout
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "message": "로그아웃되었습니다"
  }
}
```

### 1.5 비밀번호 재설정 요청

```yaml
POST /auth/password/reset-request
Content-Type: application/json

Request Body:
{
  "email": "user@example.com"
}

Response (200):
{
  "success": true,
  "data": {
    "message": "비밀번호 재설정 이메일이 발송되었습니다"
  }
}
```

### 1.6 비밀번호 재설정

```yaml
POST /auth/password/reset
Content-Type: application/json

Request Body:
{
  "token": "reset-token-from-email",
  "newPassword": "NewSecurePass123!"
}

Response (200):
{
  "success": true,
  "data": {
    "message": "비밀번호가 변경되었습니다"
  }
}
```

---

## 2. User Service API

**Base URL**: `https://api.doamarket.com/api/v1/users`

### 2.1 내 정보 조회

```yaml
GET /users/me
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "홍길동",
    "phone": "010-1234-5678",
    "role": "customer",
    "userGrade": "silver",
    "totalPurchaseAmount": 1500000,
    "emailVerified": true,
    "phoneVerified": true,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

### 2.2 프로필 수정

```yaml
PATCH /users/me
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "name": "홍길동",
  "phone": "010-9999-8888"
}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "홍길동",
    "phone": "010-9999-8888"
  }
}
```

### 2.3 배송지 목록 조회

```yaml
GET /users/me/addresses
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "recipientName": "홍길동",
      "phone": "010-1234-5678",
      "postalCode": "12345",
      "address": "서울시 강남구 테헤란로 123",
      "addressDetail": "456호",
      "isDefault": true,
      "label": "home"
    }
  ]
}
```

### 2.4 배송지 추가

```yaml
POST /users/me/addresses
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "recipientName": "홍길동",
  "phone": "010-1234-5678",
  "postalCode": "12345",
  "address": "서울시 강남구 테헤란로 123",
  "addressDetail": "456호",
  "isDefault": false,
  "label": "office"
}

Response (201):
{
  "success": true,
  "data": {
    "id": "uuid",
    "recipientName": "홍길동",
    ...
  }
}
```

### 2.5 배송지 수정

```yaml
PATCH /users/me/addresses/{addressId}
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "recipientName": "홍길동2",
  "isDefault": true
}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "recipientName": "홍길동2",
    "isDefault": true,
    ...
  }
}
```

### 2.6 배송지 삭제

```yaml
DELETE /users/me/addresses/{addressId}
Authorization: Bearer {token}

Response (204):
No Content
```

### 2.7 찜 목록 조회

```yaml
GET /users/me/wishlists?page=1&limit=20
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": [
    {
      "productId": "uuid",
      "productName": "상품명",
      "productImage": "https://...",
      "price": 29900,
      "discountRate": 10,
      "addedAt": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45
  }
}
```

### 2.8 찜 추가

```yaml
POST /users/me/wishlists
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "productId": "uuid"
}

Response (201):
{
  "success": true,
  "data": {
    "productId": "uuid",
    "addedAt": "2024-01-01T00:00:00Z"
  }
}
```

### 2.9 찜 삭제

```yaml
DELETE /users/me/wishlists/{productId}
Authorization: Bearer {token}

Response (204):
No Content
```

---

## 3. Product Service API

**Base URL**: `https://api.doamarket.com/api/v1/products`

### 3.1 상품 목록 조회

```yaml
GET /products?page=1&limit=20&category=electronics&minPrice=10000&maxPrice=50000&sort=latest
Accept: application/json

Query Parameters:
- page: integer (default: 1)
- limit: integer (default: 20, max: 100)
- category: string (카테고리 slug)
- minPrice: number
- maxPrice: number
- sort: enum [latest, price_asc, price_desc, popular, rating]
- q: string (검색어)

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "삼성 갤럭시 노트북",
      "slug": "samsung-galaxy-notebook",
      "price": 1290000,
      "originalPrice": 1490000,
      "discountRate": 13,
      "thumbnail": "https://cdn.doamarket.com/products/...",
      "rating": 4.5,
      "reviewCount": 128,
      "isFeatured": false,
      "status": "active",
      "seller": {
        "id": "uuid",
        "name": "공식스토어"
      },
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### 3.2 상품 상세 조회

```yaml
GET /products/{productId}
Accept: application/json

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "삼성 갤럭시 노트북",
    "slug": "samsung-galaxy-notebook",
    "description": "최신 프로세서 탑재...",
    "price": 1290000,
    "originalPrice": 1490000,
    "discountRate": 13,
    "status": "active",
    "viewCount": 1234,
    "purchaseCount": 56,
    "rating": 4.5,
    "reviewCount": 128,
    "images": [
      {
        "url": "https://cdn.doamarket.com/products/main.jpg",
        "thumbnailUrl": "https://cdn.doamarket.com/products/main_thumb.jpg",
        "isPrimary": true
      }
    ],
    "category": {
      "id": "uuid",
      "name": "노트북",
      "slug": "notebooks"
    },
    "options": [
      {
        "id": "uuid",
        "name": "색상",
        "values": ["실버", "그레이", "블랙"]
      },
      {
        "id": "uuid",
        "name": "용량",
        "values": ["256GB", "512GB", "1TB"]
      }
    ],
    "variants": [
      {
        "id": "uuid",
        "sku": "SAM-NOTE-SV-256",
        "optionValues": {
          "색상": "실버",
          "용량": "256GB"
        },
        "priceAdjustment": 0,
        "stock": 10,
        "isActive": true
      }
    ],
    "seller": {
      "id": "uuid",
      "name": "공식스토어",
      "rating": 4.8
    },
    "metadata": {
      "brand": "Samsung",
      "warranty": "12개월"
    },
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-15T00:00:00Z"
  }
}

Response (404):
{
  "success": false,
  "error": {
    "code": "PRODUCT_NOT_FOUND",
    "message": "상품을 찾을 수 없습니다"
  }
}
```

### 3.3 상품 등록 (판매자)

```yaml
POST /products
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "name": "새 상품명",
  "description": "상품 설명",
  "price": 29900,
  "originalPrice": 39900,
  "categoryId": "uuid",
  "images": ["image-uuid-1", "image-uuid-2"],
  "options": [
    {
      "name": "색상",
      "values": ["빨강", "파랑"]
    }
  ],
  "variants": [
    {
      "sku": "PRD-RED-001",
      "optionValues": {"색상": "빨강"},
      "stock": 100
    }
  ],
  "metadata": {
    "brand": "MyBrand",
    "material": "cotton"
  }
}

Response (201):
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "새 상품명",
    "status": "pending",  // 관리자 승인 대기
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

### 3.4 상품 수정 (판매자)

```yaml
PATCH /products/{productId}
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "name": "수정된 상품명",
  "price": 27900,
  "description": "수정된 설명"
}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "수정된 상품명",
    "price": 27900,
    "updatedAt": "2024-01-15T00:00:00Z"
  }
}

Response (403):
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "해당 상품을 수정할 권한이 없습니다"
  }
}
```

### 3.5 상품 삭제 (판매자)

```yaml
DELETE /products/{productId}
Authorization: Bearer {token}

Response (204):
No Content

Response (403):
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "해당 상품을 삭제할 권한이 없습니다"
  }
}
```

### 3.6 카테고리 목록 조회

```yaml
GET /products/categories
Accept: application/json

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "전자기기",
      "slug": "electronics",
      "level": 1,
      "children": [
        {
          "id": "uuid",
          "name": "노트북",
          "slug": "notebooks",
          "level": 2
        }
      ]
    }
  ]
}
```

---

## 4. Order Service API

**Base URL**: `https://api.doamarket.com/api/v1/orders`

### 4.1 주문 생성

```yaml
POST /orders
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "items": [
    {
      "productId": "uuid",
      "variantId": "uuid",
      "quantity": 2
    }
  ],
  "shippingAddress": {
    "recipientName": "홍길동",
    "phone": "010-1234-5678",
    "postalCode": "12345",
    "address": "서울시 강남구 테헤란로 123",
    "addressDetail": "456호"
  },
  "couponId": "uuid",
  "deliveryMemo": "문 앞에 놓아주세요"
}

Response (201):
{
  "success": true,
  "data": {
    "orderId": "uuid",
    "orderNumber": "ORD-20250101-000001",
    "status": "pending",
    "items": [
      {
        "productId": "uuid",
        "productName": "삼성 갤럭시 노트북",
        "quantity": 2,
        "unitPrice": 1290000,
        "totalPrice": 2580000
      }
    ],
    "itemsTotal": 2580000,
    "shippingFee": 3000,
    "discountAmount": 50000,
    "totalAmount": 2533000,
    "orderedAt": "2024-01-01T12:00:00Z"
  }
}

Response (400):
{
  "success": false,
  "error": {
    "code": "OUT_OF_STOCK",
    "message": "재고가 부족합니다",
    "details": {
      "productId": "uuid",
      "requestedQuantity": 10,
      "availableStock": 5
    }
  }
}
```

### 4.2 주문 목록 조회

```yaml
GET /orders?status=paid&page=1&limit=20
Authorization: Bearer {token}

Query Parameters:
- status: enum [pending, paid, preparing, shipped, delivered, cancelled]
- page: integer
- limit: integer
- startDate: string (ISO 8601)
- endDate: string (ISO 8601)

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "orderNumber": "ORD-20250101-000001",
      "status": "paid",
      "totalAmount": 2533000,
      "itemCount": 2,
      "orderedAt": "2024-01-01T12:00:00Z",
      "paidAt": "2024-01-01T12:05:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45
  }
}
```

### 4.3 주문 상세 조회

```yaml
GET /orders/{orderId}
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "orderNumber": "ORD-20250101-000001",
    "status": "shipped",
    "items": [
      {
        "id": "uuid",
        "productId": "uuid",
        "productName": "삼성 갤럭시 노트북",
        "productImage": "https://...",
        "variantId": "uuid",
        "optionValues": {
          "색상": "실버",
          "용량": "256GB"
        },
        "quantity": 2,
        "unitPrice": 1290000,
        "totalPrice": 2580000
      }
    ],
    "itemsTotal": 2580000,
    "shippingFee": 3000,
    "discountAmount": 50000,
    "totalAmount": 2533000,
    "shippingAddress": {
      "recipientName": "홍길동",
      "phone": "010-1234-5678",
      "postalCode": "12345",
      "address": "서울시 강남구 테헤란로 123",
      "addressDetail": "456호"
    },
    "deliveryMemo": "문 앞에 놓아주세요",
    "shipment": {
      "carrier": "CJ대한통운",
      "trackingNumber": "123456789012",
      "status": "in_transit",
      "shippedAt": "2024-01-02T10:00:00Z",
      "estimatedDelivery": "2024-01-03T18:00:00Z"
    },
    "orderedAt": "2024-01-01T12:00:00Z",
    "paidAt": "2024-01-01T12:05:00Z",
    "shippedAt": "2024-01-02T10:00:00Z"
  }
}
```

### 4.4 주문 취소

```yaml
POST /orders/{orderId}/cancel
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "reason": "단순 변심"
}

Response (200):
{
  "success": true,
  "data": {
    "orderId": "uuid",
    "status": "cancelled",
    "cancelledAt": "2024-01-01T13:00:00Z",
    "refundAmount": 2533000,
    "refundMethod": "원결제수단",
    "estimatedRefundDate": "2024-01-08T00:00:00Z"
  }
}

Response (400):
{
  "success": false,
  "error": {
    "code": "CANNOT_CANCEL_ORDER",
    "message": "이미 배송이 시작된 주문은 취소할 수 없습니다"
  }
}
```

### 4.5 장바구니 조회

```yaml
GET /orders/cart
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "items": [
      {
        "productId": "uuid",
        "variantId": "uuid",
        "productName": "상품명",
        "productImage": "https://...",
        "optionValues": {
          "색상": "빨강"
        },
        "quantity": 2,
        "unitPrice": 29900,
        "totalPrice": 59800,
        "isAvailable": true,
        "addedAt": "2024-01-01T10:00:00Z"
      }
    ],
    "summary": {
      "totalItems": 3,
      "totalAmount": 89700,
      "estimatedShippingFee": 3000
    }
  }
}
```

### 4.6 장바구니 추가

```yaml
POST /orders/cart
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "productId": "uuid",
  "variantId": "uuid",
  "quantity": 2
}

Response (201):
{
  "success": true,
  "data": {
    "productId": "uuid",
    "variantId": "uuid",
    "quantity": 2,
    "addedAt": "2024-01-01T10:00:00Z"
  }
}
```

### 4.7 장바구니 수정

```yaml
PATCH /orders/cart/{productId}
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "quantity": 3
}

Response (200):
{
  "success": true,
  "data": {
    "productId": "uuid",
    "quantity": 3,
    "updatedAt": "2024-01-01T10:30:00Z"
  }
}
```

### 4.8 장바구니 삭제

```yaml
DELETE /orders/cart/{productId}
Authorization: Bearer {token}

Response (204):
No Content
```

---

## 5. Payment Service API

**Base URL**: `https://api.doamarket.com/api/v1/payments`

### 5.1 결제 준비

```yaml
POST /payments/prepare
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "orderId": "uuid",
  "amount": 2533000,
  "method": "card"  // card, virtual_account, transfer, mobile
}

Response (200):
{
  "success": true,
  "data": {
    "paymentKey": "payment-key-from-pg",
    "orderId": "uuid",
    "amount": 2533000,
    "method": "card"
  }
}
```

### 5.2 결제 승인

```yaml
POST /payments/confirm
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "paymentKey": "payment-key-from-pg",
  "orderId": "uuid",
  "amount": 2533000
}

Response (200):
{
  "success": true,
  "data": {
    "paymentId": "uuid",
    "orderId": "uuid",
    "status": "completed",
    "amount": 2533000,
    "method": "card",
    "pgTransactionId": "pg-txn-12345",
    "approvedAt": "2024-01-01T12:05:00Z"
  }
}

Response (400):
{
  "success": false,
  "error": {
    "code": "PAYMENT_FAILED",
    "message": "결제 승인에 실패했습니다",
    "details": {
      "pgErrorCode": "INSUFFICIENT_BALANCE",
      "pgErrorMessage": "잔액이 부족합니다"
    }
  }
}
```

### 5.3 결제 내역 조회

```yaml
GET /payments?page=1&limit=20
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "orderId": "uuid",
      "orderNumber": "ORD-20250101-000001",
      "amount": 2533000,
      "status": "completed",
      "method": "card",
      "cardCompany": "신한카드",
      "cardNumber": "1234-****-****-5678",
      "approvedAt": "2024-01-01T12:05:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 23
  }
}
```

### 5.4 환불 요청

```yaml
POST /payments/{paymentId}/refund
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "amount": 2533000,
  "reason": "단순 변심"
}

Response (200):
{
  "success": true,
  "data": {
    "refundId": "uuid",
    "paymentId": "uuid",
    "refundAmount": 2533000,
    "status": "processing",
    "estimatedCompletionDate": "2024-01-08T00:00:00Z",
    "requestedAt": "2024-01-01T13:00:00Z"
  }
}
```

---

## 6. Shipping Service API

**Base URL**: `https://api.doamarket.com/api/v1/shipping`

### 6.1 배송 추적

```yaml
GET /shipping/track/{trackingNumber}
Accept: application/json

Response (200):
{
  "success": true,
  "data": {
    "trackingNumber": "123456789012",
    "carrier": "CJ대한통운",
    "status": "in_transit",
    "estimatedDelivery": "2024-01-03T18:00:00Z",
    "trackingHistory": [
      {
        "status": "picked_up",
        "location": "서울 강남구 물류센터",
        "description": "상품을 픽업했습니다",
        "trackedAt": "2024-01-02T10:00:00Z"
      },
      {
        "status": "in_transit",
        "location": "경기 성남시 분당센터",
        "description": "배송 중입니다",
        "trackedAt": "2024-01-02T15:30:00Z"
      }
    ]
  }
}
```

### 6.2 배송지 변경

```yaml
PATCH /shipping/{shipmentId}/address
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "recipientName": "김철수",
  "phone": "010-9999-8888",
  "postalCode": "54321",
  "address": "서울시 송파구 올림픽로 300",
  "addressDetail": "101동 1001호"
}

Response (200):
{
  "success": true,
  "data": {
    "shipmentId": "uuid",
    "address": {
      "recipientName": "김철수",
      "phone": "010-9999-8888",
      "postalCode": "54321",
      "address": "서울시 송파구 올림픽로 300",
      "addressDetail": "101동 1001호"
    },
    "updatedAt": "2024-01-02T09:00:00Z"
  }
}

Response (400):
{
  "success": false,
  "error": {
    "code": "CANNOT_CHANGE_ADDRESS",
    "message": "이미 배송이 시작되어 주소를 변경할 수 없습니다"
  }
}
```

---

## 7. Seller Service API

**Base URL**: `https://api.doamarket.com/api/v1/sellers`

### 7.1 판매자 등록

```yaml
POST /sellers/register
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "businessName": "홍길동 상점",
  "businessNumber": "123-45-67890",
  "businessType": "개인",
  "representativeName": "홍길동",
  "businessAddress": "서울시 강남구 테헤란로 123",
  "businessPhone": "02-1234-5678",
  "bankAccountHolder": "홍길동",
  "bankName": "신한은행",
  "bankAccountNumber": "110-123-456789"
}

Response (201):
{
  "success": true,
  "data": {
    "sellerId": "uuid",
    "status": "pending",
    "message": "판매자 심사가 진행 중입니다"
  }
}
```

### 7.2 판매자 정보 조회

```yaml
GET /sellers/me
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "businessName": "홍길동 상점",
    "businessNumber": "123-45-67890",
    "status": "approved",
    "commissionRate": 10.5,
    "approvalDate": "2024-01-01T00:00:00Z",
    "bankAccount": {
      "bankName": "신한은행",
      "accountNumber": "110-123-******",
      "accountHolder": "홍길동"
    },
    "createdAt": "2023-12-15T00:00:00Z"
  }
}
```

### 7.3 판매 대시보드

```yaml
GET /sellers/me/dashboard?period=month
Authorization: Bearer {token}

Query Parameters:
- period: enum [today, week, month, year]

Response (200):
{
  "success": true,
  "data": {
    "period": "month",
    "sales": {
      "totalRevenue": 15000000,
      "totalOrders": 123,
      "averageOrderValue": 121951
    },
    "orderStatus": {
      "pending": 5,
      "paid": 12,
      "shipped": 89,
      "delivered": 15,
      "cancelled": 2
    },
    "topProducts": [
      {
        "productId": "uuid",
        "productName": "베스트 상품",
        "salesCount": 45,
        "revenue": 3500000
      }
    ],
    "recentOrders": [
      {
        "orderId": "uuid",
        "orderNumber": "ORD-20250101-000001",
        "totalAmount": 129000,
        "status": "paid",
        "orderedAt": "2024-01-15T10:00:00Z"
      }
    ]
  }
}
```

---

## 8. Settlement Service API

**Base URL**: `https://api.doamarket.com/api/v1/settlements`

### 8.1 정산 내역 조회

```yaml
GET /settlements?page=1&limit=20
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "settlementNumber": "SETTLE-202501-0001",
      "periodStart": "2025-01-01",
      "periodEnd": "2025-01-31",
      "totalSales": 15000000,
      "commissionAmount": 1500000,
      "shippingFee": 120000,
      "refundAmount": 50000,
      "settlementAmount": 13570000,
      "status": "paid",
      "paidAt": "2025-02-05T00:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 12
  }
}
```

### 8.2 정산 상세 조회

```yaml
GET /settlements/{settlementId}
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "settlementNumber": "SETTLE-202501-0001",
    "periodStart": "2025-01-01",
    "periodEnd": "2025-01-31",
    "totalSales": 15000000,
    "commissionAmount": 1500000,
    "commissionRate": 10.0,
    "shippingFee": 120000,
    "refundAmount": 50000,
    "adjustmentAmount": 0,
    "settlementAmount": 13570000,
    "status": "paid",
    "bankAccount": {
      "bankName": "신한은행",
      "accountNumber": "110-123-******",
      "accountHolder": "홍길동"
    },
    "settlementDocumentUrl": "https://s3.../settlement-202501-0001.pdf",
    "items": [
      {
        "orderNumber": "ORD-20250101-000001",
        "orderAmount": 129000,
        "commissionAmount": 12900,
        "shippingFee": 3000,
        "itemSettlementAmount": 119100,
        "orderedAt": "2025-01-01T10:00:00Z",
        "deliveredAt": "2025-01-03T15:00:00Z"
      }
    ],
    "calculatedAt": "2025-02-01T00:00:00Z",
    "paidAt": "2025-02-05T00:00:00Z"
  }
}
```

---

## 9. Coupon Service API

**Base URL**: `https://api.doamarket.com/api/v1/coupons`

### 9.1 내 쿠폰 목록 조회

```yaml
GET /coupons/me?status=available
Authorization: Bearer {token}

Query Parameters:
- status: enum [available, used, expired]

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "couponId": "uuid",
      "code": "WELCOME2025",
      "name": "신규 회원 환영 쿠폰",
      "discountType": "percentage",
      "discountValue": 10,
      "maxDiscountAmount": 10000,
      "minPurchaseAmount": 50000,
      "status": "available",
      "issuedAt": "2024-01-01T00:00:00Z",
      "expiresAt": "2024-12-31T23:59:59Z"
    }
  ]
}
```

### 9.2 쿠폰 다운로드

```yaml
POST /coupons/{couponId}/download
Authorization: Bearer {token}

Response (201):
{
  "success": true,
  "data": {
    "userCouponId": "uuid",
    "couponId": "uuid",
    "code": "WELCOME2025",
    "issuedAt": "2024-01-15T10:00:00Z",
    "expiresAt": "2024-12-31T23:59:59Z"
  }
}

Response (409):
{
  "success": false,
  "error": {
    "code": "COUPON_ALREADY_ISSUED",
    "message": "이미 발급받은 쿠폰입니다"
  }
}
```

### 9.3 쿠폰 검증

```yaml
POST /coupons/validate
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "couponId": "uuid",
  "orderAmount": 100000
}

Response (200):
{
  "success": true,
  "data": {
    "isValid": true,
    "discountAmount": 10000,
    "finalAmount": 90000
  }
}

Response (400):
{
  "success": false,
  "error": {
    "code": "COUPON_MIN_PURCHASE_NOT_MET",
    "message": "최소 구매 금액을 충족하지 않습니다",
    "details": {
      "minPurchaseAmount": 50000,
      "currentAmount": 30000
    }
  }
}
```

---

## 10. Inventory Service API

**Base URL**: `https://api.doamarket.com/api/v1/inventory`

### 10.1 재고 조회

```yaml
GET /inventory/{productId}
Accept: application/json

Response (200):
{
  "success": true,
  "data": {
    "productId": "uuid",
    "variants": [
      {
        "variantId": "uuid",
        "sku": "PRD-RED-001",
        "stock": 100,
        "reservedStock": 5,
        "availableStock": 95
      }
    ],
    "updatedAt": "2024-01-15T10:00:00Z"
  }
}
```

### 10.2 재고 조정 (판매자)

```yaml
POST /inventory/{productId}/adjust
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "variantId": "uuid",
  "quantity": 50,
  "reason": "입고"
}

Response (200):
{
  "success": true,
  "data": {
    "productId": "uuid",
    "variantId": "uuid",
    "previousStock": 100,
    "newStock": 150,
    "adjustedQuantity": 50,
    "adjustedAt": "2024-01-15T10:00:00Z"
  }
}
```

---

## 11. Notification Service API

**Base URL**: `https://api.doamarket.com/api/v1/notifications`

### 11.1 알림 목록 조회

```yaml
GET /notifications?type=order&page=1&limit=20
Authorization: Bearer {token}

Query Parameters:
- type: enum [order, payment, shipping, promotion, system]
- isRead: boolean

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "type": "order",
      "title": "주문이 접수되었습니다",
      "message": "주문번호 ORD-20250101-000001이 접수되었습니다.",
      "data": {
        "orderId": "uuid",
        "orderNumber": "ORD-20250101-000001"
      },
      "isRead": false,
      "createdAt": "2024-01-01T12:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "unreadCount": 12
  }
}
```

### 11.2 알림 읽음 처리

```yaml
PATCH /notifications/{notificationId}/read
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "isRead": true,
    "readAt": "2024-01-01T13:00:00Z"
  }
}
```

### 11.3 알림 설정 조회

```yaml
GET /notifications/settings
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "channels": {
      "push": true,
      "email": true,
      "sms": false
    },
    "preferences": {
      "order": true,
      "payment": true,
      "shipping": true,
      "promotion": false,
      "marketing": false,
      "nightTime": false
    }
  }
}
```

### 11.4 알림 설정 변경

```yaml
PATCH /notifications/settings
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "channels": {
    "push": true,
    "email": false
  },
  "preferences": {
    "promotion": false,
    "marketing": false
  }
}

Response (200):
{
  "success": true,
  "data": {
    "channels": {
      "push": true,
      "email": false,
      "sms": false
    },
    "preferences": {
      "order": true,
      "payment": true,
      "shipping": true,
      "promotion": false,
      "marketing": false,
      "nightTime": false
    },
    "updatedAt": "2024-01-01T13:00:00Z"
  }
}
```

---

## 12. Review Service API

**Base URL**: `https://api.doamarket.com/api/v1/reviews`

### 12.1 상품 리뷰 목록 조회

```yaml
GET /reviews?productId={productId}&page=1&limit=20&sort=latest
Accept: application/json

Query Parameters:
- productId: string (required)
- rating: integer (1-5)
- sort: enum [latest, helpful, rating_high, rating_low]
- page: integer
- limit: integer

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "productId": "uuid",
      "user": {
        "id": "uuid",
        "name": "홍*동",
        "userGrade": "vip"
      },
      "rating": 5,
      "title": "정말 좋아요!",
      "content": "배송도 빠르고 품질도 훌륭합니다.",
      "images": [
        {
          "url": "https://...",
          "thumbnailUrl": "https://..."
        }
      ],
      "isVerifiedPurchase": true,
      "helpfulCount": 12,
      "createdAt": "2024-01-10T10:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 128,
    "averageRating": 4.5,
    "ratingDistribution": {
      "5": 80,
      "4": 30,
      "3": 10,
      "2": 5,
      "1": 3
    }
  }
}
```

### 12.2 리뷰 작성

```yaml
POST /reviews
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "productId": "uuid",
  "orderId": "uuid",
  "rating": 5,
  "title": "정말 좋아요!",
  "content": "배송도 빠르고 품질도 훌륭합니다.",
  "images": ["image-uuid-1", "image-uuid-2"]
}

Response (201):
{
  "success": true,
  "data": {
    "id": "uuid",
    "productId": "uuid",
    "rating": 5,
    "title": "정말 좋아요!",
    "createdAt": "2024-01-10T10:00:00Z"
  }
}

Response (409):
{
  "success": false,
  "error": {
    "code": "REVIEW_ALREADY_EXISTS",
    "message": "이미 리뷰를 작성한 주문입니다"
  }
}
```

### 12.3 리뷰 수정

```yaml
PATCH /reviews/{reviewId}
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "rating": 4,
  "title": "수정된 제목",
  "content": "수정된 내용"
}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "rating": 4,
    "title": "수정된 제목",
    "updatedAt": "2024-01-11T10:00:00Z"
  }
}
```

### 12.4 리뷰 삭제

```yaml
DELETE /reviews/{reviewId}
Authorization: Bearer {token}

Response (204):
No Content
```

### 12.5 리뷰 도움 표시

```yaml
POST /reviews/{reviewId}/helpful
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "reviewId": "uuid",
    "helpfulCount": 13
  }
}
```

---

## 13. Search Service API

**Base URL**: `https://api.doamarket.com/api/v1/search`

### 13.1 통합 검색

```yaml
GET /search?q=노트북&category=electronics&page=1&limit=20
Accept: application/json

Query Parameters:
- q: string (required) - 검색어
- category: string
- minPrice: number
- maxPrice: number
- rating: integer (1-5)
- sort: enum [relevance, latest, price_asc, price_desc, popular]
- page: integer
- limit: integer

Response (200):
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "uuid",
        "name": "삼성 갤럭시 노트북",
        "price": 1290000,
        "thumbnail": "https://...",
        "rating": 4.5,
        "reviewCount": 128,
        "matchScore": 0.95
      }
    ],
    "facets": {
      "categories": [
        {"slug": "notebooks", "name": "노트북", "count": 45},
        {"slug": "tablets", "name": "태블릿", "count": 12}
      ],
      "priceRanges": [
        {"min": 0, "max": 500000, "count": 10},
        {"min": 500000, "max": 1000000, "count": 25}
      ],
      "brands": [
        {"name": "Samsung", "count": 30},
        {"name": "LG", "count": 15}
      ]
    }
  },
  "meta": {
    "query": "노트북",
    "page": 1,
    "limit": 20,
    "total": 57,
    "took": 45
  }
}
```

### 13.2 자동완성

```yaml
GET /search/autocomplete?q=노트
Accept: application/json

Response (200):
{
  "success": true,
  "data": {
    "suggestions": [
      "노트북",
      "노트북 파우치",
      "노트북 거치대",
      "노트북 쿨러"
    ]
  }
}
```

### 13.3 인기 검색어

```yaml
GET /search/popular?limit=10
Accept: application/json

Response (200):
{
  "success": true,
  "data": {
    "keywords": [
      {"rank": 1, "keyword": "갤럭시 S24", "change": "up"},
      {"rank": 2, "keyword": "아이폰 15", "change": "same"},
      {"rank": 3, "keyword": "에어팟 프로", "change": "down"}
    ],
    "updatedAt": "2024-01-15T10:00:00Z"
  }
}
```

---

## 14. Admin Service API

**Base URL**: `https://api.doamarket.com/api/v1/admin`

### 14.1 대시보드

```yaml
GET /admin/dashboard
Authorization: Bearer {token}
X-Admin-Role: admin

Response (200):
{
  "success": true,
  "data": {
    "summary": {
      "totalUsers": 15234,
      "totalSellers": 523,
      "totalProducts": 8912,
      "totalOrders": 45678,
      "totalRevenue": 2345678900
    },
    "todayStats": {
      "newUsers": 45,
      "newOrders": 234,
      "revenue": 12345600
    },
    "pendingApprovals": {
      "sellers": 12,
      "products": 89
    },
    "recentActivity": [
      {
        "type": "order",
        "description": "새 주문 접수",
        "timestamp": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

### 14.2 사용자 관리 - 목록

```yaml
GET /admin/users?page=1&limit=20&status=active&role=customer
Authorization: Bearer {token}
X-Admin-Role: admin

Response (200):
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "email": "user@example.com",
      "name": "홍길동",
      "role": "customer",
      "status": "active",
      "userGrade": "silver",
      "totalPurchaseAmount": 1500000,
      "createdAt": "2024-01-01T00:00:00Z",
      "lastLoginAt": "2024-01-15T09:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 15234
  }
}
```

### 14.3 사용자 정지

```yaml
POST /admin/users/{userId}/suspend
Authorization: Bearer {token}
X-Admin-Role: admin
Content-Type: application/json

Request Body:
{
  "reason": "부적절한 행위",
  "duration": "7days"  // 7days, 30days, permanent
}

Response (200):
{
  "success": true,
  "data": {
    "userId": "uuid",
    "status": "suspended",
    "suspendedUntil": "2024-01-22T00:00:00Z",
    "reason": "부적절한 행위"
  }
}
```

### 14.4 판매자 승인

```yaml
POST /admin/sellers/{sellerId}/approve
Authorization: Bearer {token}
X-Admin-Role: admin

Response (200):
{
  "success": true,
  "data": {
    "sellerId": "uuid",
    "status": "approved",
    "approvedAt": "2024-01-15T10:00:00Z"
  }
}
```

### 14.5 상품 심사

```yaml
POST /admin/products/{productId}/approve
Authorization: Bearer {token}
X-Admin-Role: admin
Content-Type: application/json

Request Body:
{
  "approved": true,
  "note": "승인되었습니다"
}

Response (200):
{
  "success": true,
  "data": {
    "productId": "uuid",
    "status": "approved",
    "approvedAt": "2024-01-15T10:00:00Z"
  }
}
```

### 14.6 공지사항 작성

```yaml
POST /admin/notices
Authorization: Bearer {token}
X-Admin-Role: admin
Content-Type: application/json

Request Body:
{
  "type": "general",  // general, maintenance, event, urgent
  "title": "시스템 점검 안내",
  "content": "2024년 1월 20일 새벽 2시부터 5시까지...",
  "target": "all",  // all, customers, sellers
  "isPinned": true,
  "isPublished": true
}

Response (201):
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "시스템 점검 안내",
    "publishedAt": "2024-01-15T10:00:00Z"
  }
}
```

---

## 15. File Service API

**Base URL**: `https://api.doamarket.com/api/v1/files`

### 15.1 파일 업로드 URL 요청

```yaml
POST /files/upload-url
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "fileName": "product-image.jpg",
  "fileType": "image/jpeg",
  "fileSize": 2048576,
  "referenceType": "product"  // product, review, notice, profile
}

Response (200):
{
  "success": true,
  "data": {
    "fileId": "uuid",
    "uploadUrl": "https://s3.presigned.url...",
    "expiresIn": 3600
  }
}
```

### 15.2 파일 업로드 완료 확인

```yaml
POST /files/{fileId}/confirm
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "referenceId": "product-uuid"
}

Response (200):
{
  "success": true,
  "data": {
    "id": "uuid",
    "url": "https://cdn.doamarket.com/files/...",
    "thumbnailUrl": "https://cdn.doamarket.com/files/.../thumb.jpg",
    "uploadedAt": "2024-01-15T10:00:00Z"
  }
}
```

### 15.3 파일 삭제

```yaml
DELETE /files/{fileId}
Authorization: Bearer {token}

Response (204):
No Content
```

---

## 16. Stats Service API

**Base URL**: `https://api.doamarket.com/api/v1/stats`

### 16.1 매출 통계

```yaml
GET /stats/sales?period=month&startDate=2025-01-01&endDate=2025-01-31
Authorization: Bearer {token}

Query Parameters:
- period: enum [day, week, month, year]
- startDate: string (ISO 8601)
- endDate: string (ISO 8601)

Response (200):
{
  "success": true,
  "data": {
    "period": "month",
    "startDate": "2025-01-01",
    "endDate": "2025-01-31",
    "totalRevenue": 15000000,
    "totalOrders": 123,
    "averageOrderValue": 121951,
    "dailyStats": [
      {
        "date": "2025-01-01",
        "revenue": 500000,
        "orders": 4
      }
    ]
  }
}
```

### 16.2 상품 통계

```yaml
GET /stats/products/top?period=month&limit=10
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "data": {
    "topSellingProducts": [
      {
        "productId": "uuid",
        "productName": "베스트 상품",
        "salesCount": 45,
        "revenue": 3500000
      }
    ],
    "topViewedProducts": [
      {
        "productId": "uuid",
        "productName": "인기 상품",
        "viewCount": 12345
      }
    ]
  }
}
```

---

**4단계 완료**: 16개 마이크로서비스의 전체 REST API 스펙이 완성되었습니다!

다음 단계로 넘어가시려면 **"다음"**이라고 입력해주세요.

**작성일**: 2025-12-03
**버전**: 1.0
