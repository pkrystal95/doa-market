# DOA Market - 마이크로서비스 기반 전자상거래 플랫폼

DOA Market은 현대적인 마이크로서비스 아키텍처로 구축된 전자상거래 플랫폼입니다.

## 아키텍처 개요

- **마이크로서비스:** 16개의 독립적인 서비스
- **API Gateway:** 단일 진입점 (포트 3000)
- **데이터베이스:** PostgreSQL (서비스별 독립 데이터베이스)
- **기술 스택:** Node.js, TypeScript, Express, TypeORM

## 서비스 목록

| # | 서비스 | 포트 | 설명 |
|---|--------|------|------|
| 1 | API Gateway | 3000 | 통합 API 진입점 |
| 2 | Auth Service | 3001 | 인증/권한 관리 |
| 3 | User Service | 3002 | 사용자 정보 관리 |
| 4 | Product Service | 3003 | 상품 관리 |
| 5 | Seller Service | 3004 | 판매자 관리 |
| 6 | Order Service | 3005 | 주문 관리 |
| 7 | Payment Service | 3006 | 결제 처리 |
| 8 | Cart Service | 3007 | 장바구니 |
| 9 | Review Service | 3008 | 리뷰 관리 |
| 10 | Notification Service | 3009 | 알림 |
| 11 | Search Service | 3010 | 검색/로그 |
| 12 | Shipping Service | 3011 | 배송 추적 |
| 13 | Coupon Service | 3012 | 쿠폰/할인 |
| 14 | Wishlist Service | 3013 | 찜 목록 |
| 15 | Analytics Service | 3014 | 데이터 분석 |
| 16 | Admin Service | 3015 | 관리자 기능 |

## 빠른 시작

### 사전 요구사항

- Node.js 18 이상
- Docker (PostgreSQL 컨테이너용)
- npm 또는 yarn

### 설치 및 실행

1. **저장소 클론**
```bash
git clone <repository-url>
cd doa-market
```

2. **PostgreSQL 시작**
```bash
docker run -d \
  --name doa-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_USER=postgres \
  -p 5432:5432 \
  postgres:15
```

3. **각 서비스 실행**

각 서비스 디렉토리에서:
```bash
cd backend/services/<service-name>
npm install
npm run dev
```

또는 API Gateway에서:
```bash
cd backend/api-gateway
npm install
npm run dev
```

### 데이터베이스 초기화

각 서비스는 자동으로 데이터베이스를 생성하고 스키마를 동기화합니다.

데이터베이스 목록:
- doa_auth
- doa_users
- doa_products
- doa_sellers
- doa_orders
- doa_payments
- doa_carts
- doa_reviews
- doa_notifications
- doa_search
- doa_shipping
- doa_coupons
- doa_wishlists
- doa_analytics
- doa_admin

## API 문서

상세한 API 문서는 `docs/api/README.md`를 참조하세요.

### Postman Collection

`docs/api/postman-collection.json` 파일을 Postman에 임포트하여 모든 API를 테스트할 수 있습니다.

## 프로젝트 구조

```
doa-market/
├── backend/
│   ├── api-gateway/           # API Gateway (포트 3000)
│   └── services/
│       ├── auth-service/      # 인증 서비스
│       ├── user-service/      # 사용자 서비스
│       ├── product-service/   # 상품 서비스
│       ├── seller-service/    # 판매자 서비스
│       ├── order-service/     # 주문 서비스
│       ├── payment-service/   # 결제 서비스
│       ├── cart-service/      # 장바구니 서비스
│       ├── review-service/    # 리뷰 서비스
│       ├── notification-service/ # 알림 서비스
│       ├── search-service/    # 검색 서비스
│       ├── shipping-service/  # 배송 서비스
│       ├── coupon-service/    # 쿠폰 서비스
│       ├── wishlist-service/  # 찜 서비스
│       ├── analytics-service/ # 분석 서비스
│       └── admin-service/     # 관리자 서비스
├── docs/                      # 문서
│   ├── api/                   # API 문서
│   │   ├── README.md
│   │   └── postman-collection.json
│   └── *.md                   # 기타 문서
└── README.md
```

## 기술 스택

### 백엔드
- **런타임:** Node.js 18+
- **언어:** TypeScript
- **프레임워크:** Express.js
- **ORM:** TypeORM
- **데이터베이스:** PostgreSQL 15
- **인증:** JWT (jsonwebtoken)
- **보안:** Helmet, CORS
- **로깅:** Winston
- **API Gateway:** http-proxy-middleware

### 개발 도구
- **타입스크립트 컴파일러:** tsc
- **런타임:** ts-node
- **Hot Reload:** nodemon

## 주요 기능

### 1. 사용자 관리
- 회원가입/로그인
- 프로필 관리
- JWT 기반 인증

### 2. 상품 관리
- 상품 CRUD
- 카테고리별 조회
- 검색 기능

### 3. 주문 및 결제
- 장바구니
- 주문 생성
- 결제 처리
- 주문 상태 추적

### 4. 배송
- 배송 정보 관리
- 운송장 추적
- 배송 상태 업데이트

### 5. 리뷰 및 평점
- 상품 리뷰 작성
- 평점 시스템

### 6. 쿠폰 및 할인
- 쿠폰 생성/관리
- 할인 적용
- 쿠폰 검증

### 7. 알림
- 주문 알림
- 배송 알림
- 시스템 알림

### 8. 분석
- 사용자 행동 추적
- 상품 조회 통계
- 인기 상품 분석

## 개발 가이드

### 환경 변수

각 서비스는 `.env` 파일을 통해 설정합니다:

```env
PORT=3001
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=doa_auth
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=1h
```

### 서비스 개발 패턴

각 서비스는 다음 구조를 따릅니다:

```
service-name/
├── src/
│   ├── models/          # 데이터 모델 (TypeORM entities)
│   ├── services/        # 비즈니스 로직
│   ├── controllers/     # HTTP 컨트롤러
│   ├── routes/          # API 라우트
│   ├── middlewares/     # Express 미들웨어
│   ├── utils/           # 유틸리티 함수
│   ├── config/          # 설정 파일
│   └── server.ts        # 진입점
├── package.json
└── tsconfig.json
```

## 테스트

### API 테스트

Postman Collection을 사용하여 API를 테스트할 수 있습니다:

```bash
# Postman에서 collection 임포트
docs/api/postman-collection.json
```

### 헬스 체크

모든 서비스의 상태 확인:

```bash
# API Gateway
curl http://localhost:3000/api/v1/health

# 개별 서비스
curl http://localhost:3001/api/v1/health  # Auth
curl http://localhost:3002/api/v1/health  # User
# ... 기타 서비스
```

## 배포

각 마이크로서비스는 독립적으로 배포 가능합니다.

### Docker 배포 (예정)
```bash
docker-compose up -d
```

### AWS ECS 배포 (예정)
- 각 서비스를 개별 ECS 서비스로 배포
- Application Load Balancer를 API Gateway로 사용

## 모니터링

### 로그
- Winston을 사용한 구조화된 로깅
- 각 서비스별 로그 파일

### 메트릭
- 서비스 헬스 체크 엔드포인트
- Admin Service를 통한 시스템 통계

## 보안

- JWT 기반 인증
- Helmet을 통한 HTTP 헤더 보안
- CORS 설정
- 환경 변수를 통한 민감 정보 관리
- TypeORM의 파라미터화된 쿼리 (SQL Injection 방지)

## 기여

프로젝트에 기여하시려면:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 라이선스

[라이선스 정보]

## 연락처

프로젝트 관련 문의: [연락처 정보]
