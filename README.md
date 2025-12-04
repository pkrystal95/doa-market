# DOA Market - 오픈마켓 시스템

MSA 기반의 대규모 오픈마켓 플랫폼

## 프로젝트 개요

DOA Market은 마이크로서비스 아키텍처(MSA)와 이벤트 기반 아키텍처를 적용한 엔터프라이즈급 오픈마켓 시스템입니다.

### 주요 특징

- ✅ **마이크로서비스 아키텍처**: 16개의 독립적인 서비스로 구성
- ✅ **이벤트 기반 통신**: Amazon EventBridge를 통한 느슨한 결합
- ✅ **확장 가능한 인프라**: AWS EKS/ECS를 활용한 컨테이너 오케스트레이션
- ✅ **3가지 클라이언트 앱**: Admin Web, Seller Web, User Mobile App
- ✅ **실시간 통계 및 분석**: OpenSearch와 DynamoDB를 활용한 데이터 분석

## 시스템 구조

```
doa-market/
├── docs/                    # 아키텍처 문서
│   ├── 01-architecture-design.md
│   ├── 02-microservices-and-events.md
│   └── 14-cicd-pipeline.md
│
├── frontend/               # 프론트엔드 애플리케이션
│   ├── admin-web/         # 관리자 웹 (Next.js)
│   ├── seller-web/        # 판매자 웹 (Next.js)
│   └── user-app/          # 사용자 앱 (Flutter)
│
├── backend/                # 백엔드 마이크로서비스
│   ├── auth-service/      # 인증 서비스
│   ├── user-service/      # 사용자 서비스
│   ├── product-service/   # 상품 서비스
│   ├── order-service/     # 주문 서비스
│   ├── payment-service/   # 결제 서비스
│   ├── shipping-service/  # 배송 서비스
│   ├── seller-service/    # 판매자 서비스
│   ├── settlement-service/# 정산 서비스
│   ├── coupon-service/    # 쿠폰 서비스
│   ├── inventory-service/ # 재고 서비스
│   ├── notification-service/ # 알림 서비스
│   ├── review-service/    # 리뷰 서비스
│   ├── search-service/    # 검색 서비스
│   ├── admin-service/     # 관리자 서비스
│   ├── file-service/      # 파일 서비스
│   └── stats-service/     # 통계 서비스
│
└── examples/              # 예제 코드 및 설정
```

## 기술 스택

### Frontend
- **Admin/Seller Web**: Next.js 15, TypeScript, TanStack Query, Zustand, Tailwind CSS
- **User Mobile App**: Flutter 3.x, Riverpod, Dio, Freezed

### Backend
- **Runtime**: Node.js 20 LTS
- **Framework**: Express.js / NestJS
- **Language**: TypeScript
- **Database**: PostgreSQL (RDS), DynamoDB
- **Cache**: Redis (ElastiCache)
- **Search**: OpenSearch
- **Message Queue**: Amazon SQS
- **Event Bus**: Amazon EventBridge

### Infrastructure (AWS)
- **Compute**: EKS (Kubernetes) / ECS Fargate
- **API Gateway**: AWS API Gateway
- **Storage**: S3, CloudFront
- **Auth**: AWS Cognito
- **Monitoring**: CloudWatch, X-Ray

## 빠른 시작 (Quick Start)

**⚡️ 백엔드 서버를 바로 실행하고 API를 테스트하고 싶다면:**

### 📖 [상세 퀵스타트 가이드 보기 →](./QUICKSTART.md)

```bash
# 1. 인프라 서비스 시작 (PostgreSQL, Redis, OpenSearch, LocalStack)
docker-compose up -d postgres redis localstack opensearch

# 2. Product Service 실행
cd backend/services/product-service
npm install
cp .env.example .env
npm run migration:run
npm run dev

# 3. API 테스트
./test-api.sh
# 또는 curl 직접 사용
curl http://localhost:3003/api/v1/health
curl http://localhost:3003/api/v1/products
```

**제공되는 도구:**
- 📄 **QUICKSTART.md**: 단계별 상세 가이드
- 🧪 **test-api.sh**: 자동화된 API 테스트 스크립트
- 📮 **Postman Collection**: `docs/api/postman-collection.json`
- 🔧 **Admin Tools**:
  - pgAdmin: http://localhost:5050
  - Redis Commander: http://localhost:8081
  - Mailhog: http://localhost:8025

---

## 시작하기

### Prerequisites
- Node.js 20+
- Flutter 3.x
- Docker & Docker Compose
- AWS CLI (배포 시)

### Frontend 개발

각 프론트엔드 앱별 자세한 가이드는 [Frontend README](./frontend/README.md)를 참고하세요.

```bash
# Admin Web
cd frontend/admin-web
npm install
npm run dev  # http://localhost:3100

# Seller Web
cd frontend/seller-web
npm install
npm run dev  # http://localhost:3200

# User Mobile App
cd frontend/user-app
flutter pub get
flutter run
```

### Backend 개발

각 마이크로서비스별 README를 참고하세요.

```bash
# 예시: Product Service
cd backend/services/product-service
npm install
cp .env.example .env
npm run dev  # http://localhost:3003
```

## 주요 기능

### 관리자 (Admin Web)
- 📊 대시보드 및 통계
- 👥 사용자 관리
- 🏪 판매자 승인/관리
- 📦 상품 심사
- 🛒 주문 모니터링
- 💰 정산 관리
- ⭐ 리뷰 관리
- 🎟️ 쿠폰 관리
- 📢 공지사항 관리

### 판매자 (Seller Web)
- 📊 판매 대시보드
- 📦 상품 등록/관리
- 🛒 주문 처리
- 💰 정산 조회
- 🏪 스토어 관리
- 📈 판매 통계

### 사용자 (Mobile App)
- 🏠 홈 (배너, 카테고리, 추천상품)
- 🔍 상품 검색/필터
- 📦 상품 상세
- 🛒 장바구니
- 💳 주문/결제
- 📋 주문 내역
- ⭐ 리뷰 작성
- 👤 마이페이지

## 아키텍처 문서

상세한 아키텍처 설계는 `docs/` 디렉토리를 참고하세요:

1. [전체 시스템 아키텍처](./docs/01-architecture-design.md)
2. [마이크로서비스 및 이벤트 흐름](./docs/02-microservices-and-events.md)
3. [CI/CD 파이프라인](./docs/14-cicd-pipeline.md)

## API 문서

각 서비스는 OpenAPI 3.0 스펙을 제공합니다:
- Swagger UI: `http://localhost:PORT/api-docs`

## 배포

### Docker로 로컬 환경 구성

```bash
docker-compose up -d
```

### AWS 배포

CI/CD 파이프라인을 통한 자동 배포:
- GitHub Actions 사용
- 각 서비스는 독립적으로 배포
- 컨테이너 이미지는 ECR에 저장
- EKS/ECS에 배포

## 모니터링

- **Logs**: CloudWatch Logs
- **Metrics**: CloudWatch Metrics
- **Tracing**: AWS X-Ray
- **Alerts**: CloudWatch Alarms
- **Dashboard**: CloudWatch Dashboard

## 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

MIT License

## 연락처

- **Email**: support@doamarket.com
- **Website**: https://doamarket.com

---

**작성일**: 2025-12-03
**버전**: 1.0.0
