# DOA Market API Documentation

이 문서는 DOA Market 마이크로서비스 아키텍처의 전체 API를 설명합니다.

## 목차
- [API Gateway](#api-gateway)
- [서비스 목록](#서비스-목록)
- [인증](#인증)
- [공통 응답 형식](#공통-응답-형식)

## API Gateway

모든 요청은 API Gateway를 통해 라우팅됩니다.

**Base URL:** `http://localhost:3000`

API Gateway는 다음 서비스들로 요청을 프록시합니다:

| 경로 | 서비스 | 포트 |
|------|--------|------|
| `/api/v1/auth` | Auth Service | 3001 |
| `/api/v1/users` | User Service | 3002 |
| `/api/v1/products` | Product Service | 3003 |
| `/api/v1/sellers` | Seller Service | 3004 |
| `/api/v1/orders` | Order Service | 3005 |
| `/api/v1/payments` | Payment Service | 3006 |
| `/api/v1/carts` | Cart Service | 3007 |
| `/api/v1/reviews` | Review Service | 3008 |
| `/api/v1/notifications` | Notification Service | 3009 |
| `/api/v1/search` | Search Service | 3010 |
| `/api/v1/shipping` | Shipping Service | 3011 |
| `/api/v1/coupons` | Coupon Service | 3012 |
| `/api/v1/wishlist` | Wishlist Service | 3013 |
| `/api/v1/analytics` | Analytics Service | 3014 |
| `/api/v1/admin` | Admin Service | 3015 |

## 서비스 목록

### 1. Auth Service (포트 3001)
사용자 인증 및 권한 관리

**주요 엔드포인트:**
- `POST /api/v1/auth/register` - 회원가입
- `POST /api/v1/auth/login` - 로그인
- `POST /api/v1/auth/logout` - 로그아웃
- `POST /api/v1/auth/refresh` - 토큰 갱신

### 2. User Service (포트 3002)
사용자 정보 관리

**주요 엔드포인트:**
- `GET /api/v1/users/me` - 내 정보 조회
- `GET /api/v1/users/:userId` - 사용자 정보 조회
- `PUT /api/v1/users/:userId` - 사용자 정보 수정
- `GET /api/v1/users` - 사용자 목록 조회

### 3. Product Service (포트 3003)
상품 관리

**주요 엔드포인트:**
- `GET /api/v1/products` - 상품 목록
- `GET /api/v1/products/:productId` - 상품 상세
- `POST /api/v1/products` - 상품 등록
- `PUT /api/v1/products/:productId` - 상품 수정
- `DELETE /api/v1/products/:productId` - 상품 삭제
- `GET /api/v1/products/search` - 상품 검색
- `GET /api/v1/products/category/:categoryId` - 카테고리별 상품
- `GET /api/v1/products/seller/:sellerId` - 판매자별 상품

### 4. Seller Service (포트 3004)
판매자 관리

**주요 엔드포인트:**
- `POST /api/v1/sellers` - 판매자 등록
- `GET /api/v1/sellers/:sellerId` - 판매자 정보
- `PUT /api/v1/sellers/:sellerId` - 판매자 정보 수정
- `GET /api/v1/sellers/:sellerId/products` - 판매자 상품 목록

### 5. Order Service (포트 3005)
주문 관리

**주요 엔드포인트:**
- `POST /api/v1/orders` - 주문 생성
- `GET /api/v1/orders/:orderId` - 주문 상세
- `GET /api/v1/orders/user/:userId` - 사용자 주문 목록
- `PATCH /api/v1/orders/:orderId/status` - 주문 상태 변경
- `POST /api/v1/orders/:orderId/cancel` - 주문 취소

### 6. Payment Service (포트 3006)
결제 처리

**주요 엔드포인트:**
- `POST /api/v1/payments` - 결제 생성
- `POST /api/v1/payments/:paymentId/verify` - 결제 검증
- `GET /api/v1/payments/:paymentId` - 결제 정보 조회
- `GET /api/v1/payments/order/:orderId` - 주문별 결제 조회
- `POST /api/v1/payments/:paymentId/refund` - 환불 처리

### 7. Cart Service (포트 3007)
장바구니 관리

**주요 엔드포인트:**
- `POST /api/v1/carts` - 장바구니에 상품 추가
- `GET /api/v1/carts/:userId` - 장바구니 조회
- `DELETE /api/v1/carts/:userId/:cartItemId` - 장바구니 상품 삭제
- `PATCH /api/v1/carts/:userId/:cartItemId` - 수량 변경
- `DELETE /api/v1/carts/:userId` - 장바구니 비우기

### 8. Review Service (포트 3008)
리뷰 관리

**주요 엔드포인트:**
- `POST /api/v1/reviews` - 리뷰 작성
- `GET /api/v1/reviews/product/:productId` - 상품 리뷰 조회
- `PUT /api/v1/reviews/:reviewId` - 리뷰 수정
- `DELETE /api/v1/reviews/:reviewId` - 리뷰 삭제

### 9. Notification Service (포트 3009)
알림 관리

**주요 엔드포인트:**
- `POST /api/v1/notifications` - 알림 생성
- `GET /api/v1/notifications/user/:userId` - 사용자 알림 조회
- `PATCH /api/v1/notifications/:notificationId/read` - 알림 읽음 처리
- `DELETE /api/v1/notifications/:notificationId` - 알림 삭제

### 10. Search Service (포트 3010)
검색 및 검색 로그

**주요 엔드포인트:**
- `POST /api/v1/search` - 검색 실행
- `GET /api/v1/search/popular` - 인기 검색어
- `GET /api/v1/search/history/:userId` - 사용자 검색 기록

### 11. Shipping Service (포트 3011)
배송 추적

**주요 엔드포인트:**
- `POST /api/v1/shipping` - 배송 정보 생성
- `GET /api/v1/shipping/:shippingId` - 배송 정보 조회
- `GET /api/v1/shipping/track/:trackingNumber` - 운송장 번호로 추적
- `PATCH /api/v1/shipping/:shippingId/status` - 배송 상태 변경
- `GET /api/v1/shipping/user/:userId` - 사용자 배송 목록

### 12. Coupon Service (포트 3012)
쿠폰 관리

**주요 엔드포인트:**
- `POST /api/v1/coupons` - 쿠폰 생성
- `GET /api/v1/coupons/:couponId` - 쿠폰 정보 조회
- `GET /api/v1/coupons/code/:code` - 쿠폰 코드로 조회
- `POST /api/v1/coupons/validate` - 쿠폰 검증
- `POST /api/v1/coupons/apply` - 쿠폰 적용
- `DELETE /api/v1/coupons/:couponId` - 쿠폰 삭제

### 13. Wishlist Service (포트 3013)
찜 목록 관리

**주요 엔드포인트:**
- `POST /api/v1/wishlist` - 찜 추가
- `DELETE /api/v1/wishlist/:userId/:productId` - 찜 삭제
- `GET /api/v1/wishlist/user/:userId` - 사용자 찜 목록
- `GET /api/v1/wishlist/check/:userId/:productId` - 찜 여부 확인
- `GET /api/v1/wishlist/count/:userId` - 찜 개수

### 14. Analytics Service (포트 3014)
데이터 분석

**주요 엔드포인트:**
- `POST /api/v1/analytics/track` - 이벤트 추적
- `GET /api/v1/analytics/events` - 이벤트 조회
- `GET /api/v1/analytics/user/:userId` - 사용자 이벤트
- `GET /api/v1/analytics/count` - 이벤트 카운트
- `GET /api/v1/analytics/top-products` - 인기 상품

### 15. Admin Service (포트 3015)
관리자 기능

**주요 엔드포인트:**
- `POST /api/v1/admin/logs` - 관리자 액션 로그
- `GET /api/v1/admin/logs` - 로그 조회
- `GET /api/v1/admin/stats` - 시스템 통계

## 인증

대부분의 엔드포인트는 JWT 토큰 기반 인증이 필요합니다.

### 인증 헤더

```
Authorization: Bearer {access_token}
```

### 토큰 획득 방법

1. 회원가입 또는 로그인
2. 응답에서 `accessToken`과 `refreshToken` 받기
3. 이후 요청에 `accessToken` 사용
4. `accessToken` 만료 시 `refreshToken`으로 갱신

## 공통 응답 형식

### 성공 응답

```json
{
  "success": true,
  "data": {
    // 응답 데이터
  }
}
```

### 오류 응답

```json
{
  "success": false,
  "error": "에러 메시지"
}
```

### HTTP 상태 코드

- `200 OK` - 성공
- `201 Created` - 리소스 생성 성공
- `400 Bad Request` - 잘못된 요청
- `401 Unauthorized` - 인증 필요
- `403 Forbidden` - 권한 없음
- `404 Not Found` - 리소스 없음
- `500 Internal Server Error` - 서버 오류
- `502 Bad Gateway` - 게이트웨이 오류 (서비스 다운)

## Postman Collection

전체 API를 테스트할 수 있는 Postman Collection이 제공됩니다.

**파일 위치:** `docs/api/postman-collection.json`

### Postman에서 사용하기

1. Postman 열기
2. Import 클릭
3. `postman-collection.json` 파일 선택
4. Collection 사용 시작

### 환경 변수 설정

Collection은 다음 환경 변수를 사용합니다:

- `gateway_url` - API Gateway URL (기본값: http://localhost:3000)
- `auth_url` - Auth Service URL (기본값: http://localhost:3001)
- 기타 서비스별 URL 변수들

## 헬스 체크

모든 서비스는 헬스 체크 엔드포인트를 제공합니다:

```
GET /api/v1/health
```

**응답:**
```json
{
  "success": true,
  "data": {
    "service": "service-name",
    "status": "healthy",
    "timestamp": "2025-12-06T10:00:00.000Z",
    "uptime": 12345
  }
}
```

## 문의

추가 정보나 문의사항은 개발팀에 연락 바랍니다.
