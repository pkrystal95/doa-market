# 7단계: 전체 폴더 구조 설계

## 목차
- [프로젝트 루트 구조](#프로젝트-루트-구조)
- [백엔드 마이크로서비스 구조](#백엔드-마이크로서비스-구조)
- [프론트엔드 구조](#프론트엔드-구조)
- [Lambda 함수 구조](#lambda-함수-구조)
- [Infrastructure 구조](#infrastructure-구조)
- [공통 패키지 및 설정](#공통-패키지-및-설정)

---

## 프로젝트 루트 구조

전체 프로젝트는 모노레포 구조로 관리됩니다.

```
doa-market/
├── .github/                    # GitHub Actions CI/CD
│   └── workflows/
│       ├── backend-ci.yml
│       ├── frontend-ci.yml
│       ├── lambda-ci.yml
│       └── terraform-ci.yml
│
├── backend/                    # 백엔드 마이크로서비스 (Node.js)
│   ├── packages/              # 공통 패키지
│   │   ├── common/            # 공통 유틸리티
│   │   ├── types/             # 공통 타입 정의
│   │   └── proto/             # Protocol Buffers (gRPC, 선택)
│   │
│   ├── services/              # 마이크로서비스들
│   │   ├── auth-service/
│   │   ├── user-service/
│   │   ├── product-service/
│   │   ├── order-service/
│   │   ├── payment-service/
│   │   ├── shipping-service/
│   │   ├── seller-service/
│   │   ├── settlement-service/
│   │   ├── coupon-service/
│   │   ├── inventory-service/
│   │   ├── notification-service/
│   │   ├── review-service/
│   │   ├── search-service/
│   │   ├── admin-service/
│   │   ├── file-service/
│   │   └── stats-service/
│   │
│   ├── package.json           # 루트 package.json (npm workspaces)
│   ├── tsconfig.json          # 공통 TypeScript 설정
│   ├── .eslintrc.js           # 공통 ESLint 설정
│   └── .prettierrc            # 공통 Prettier 설정
│
├── frontend/                   # 프론트엔드 애플리케이션
│   ├── admin-web/             # 관리자 웹 (Next.js App Router)
│   ├── seller-web/            # 판매자 웹 (Next.js App Router)
│   └── user-app/              # 사용자 모바일 앱 (Flutter)
│
├── lambda/                     # AWS Lambda 함수들
│   ├── payment-processor/
│   ├── inventory-updater/
│   ├── notification-sender/
│   ├── image-optimizer/
│   ├── settlement-calculator/
│   ├── settlement-pdf-generator/
│   ├── order-events-logger/
│   ├── api-authorizer/
│   ├── review-reminder/
│   ├── analytics-processor/
│   ├── low-stock-alert/
│   ├── product-sync-opensearch/
│   └── shared/                # Lambda 공통 코드
│       ├── layers/
│       └── utils/
│
├── infrastructure/             # IaC (Infrastructure as Code)
│   ├── terraform/             # Terraform 코드
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   ├── staging/
│   │   │   └── production/
│   │   └── modules/
│   │       ├── vpc/
│   │       ├── ecs/
│   │       ├── rds/
│   │       ├── dynamodb/
│   │       ├── s3/
│   │       ├── elasticache/
│   │       ├── opensearch/
│   │       ├── lambda/
│   │       ├── eventbridge/
│   │       ├── api-gateway/
│   │       └── cloudfront/
│   │
│   └── scripts/               # 배포 및 유틸리티 스크립트
│       ├── deploy-backend.sh
│       ├── deploy-frontend.sh
│       ├── deploy-lambda.sh
│       └── setup-db.sh
│
├── docs/                       # 프로젝트 문서
│   ├── 01-architecture-design.md
│   ├── 02-microservices-and-events.md
│   ├── 03-database-schema.md
│   ├── 04-api-design.md
│   ├── 05-lambda-functions.md
│   ├── 06-ecs-deployment-strategy.md
│   ├── 07-folder-structure.md
│   └── README.md
│
├── .gitignore
├── .editorconfig
├── README.md
└── package.json
```

---

## 백엔드 마이크로서비스 구조

### 루트 package.json (npm workspaces)

```json
{
  "name": "doa-market-backend",
  "version": "1.0.0",
  "private": true,
  "workspaces": [
    "packages/*",
    "services/*"
  ],
  "scripts": {
    "build": "npm run build --workspaces",
    "test": "npm run test --workspaces",
    "lint": "eslint . --ext .ts",
    "format": "prettier --write \"**/*.{ts,json,md}\""
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0",
    "typescript": "^5.0.0"
  }
}
```

---

### 개별 마이크로서비스 구조

각 마이크로서비스는 동일한 구조를 따릅니다.

#### Product Service 상세 구조

```
backend/services/product-service/
├── src/
│   ├── config/                 # 설정 파일
│   │   ├── database.ts        # PostgreSQL 연결 설정
│   │   ├── redis.ts           # Redis 연결 설정
│   │   ├── opensearch.ts      # OpenSearch 설정
│   │   ├── aws.ts             # AWS SDK 설정
│   │   └── index.ts
│   │
│   ├── controllers/            # HTTP 컨트롤러 (요청/응답 처리)
│   │   ├── product.controller.ts
│   │   ├── category.controller.ts
│   │   ├── health.controller.ts
│   │   └── index.ts
│   │
│   ├── services/               # 비즈니스 로직
│   │   ├── product.service.ts
│   │   ├── category.service.ts
│   │   ├── opensearch.service.ts
│   │   ├── cache.service.ts
│   │   └── index.ts
│   │
│   ├── repositories/           # 데이터 액세스 계층 (DAO)
│   │   ├── product.repository.ts
│   │   ├── category.repository.ts
│   │   ├── variant.repository.ts
│   │   └── index.ts
│   │
│   ├── models/                 # 데이터베이스 모델 (ORM)
│   │   ├── product.model.ts
│   │   ├── category.model.ts
│   │   ├── product-image.model.ts
│   │   ├── product-option.model.ts
│   │   ├── product-variant.model.ts
│   │   └── index.ts
│   │
│   ├── dto/                    # Data Transfer Objects
│   │   ├── requests/
│   │   │   ├── create-product.dto.ts
│   │   │   ├── update-product.dto.ts
│   │   │   ├── query-product.dto.ts
│   │   │   └── index.ts
│   │   └── responses/
│   │       ├── product.response.dto.ts
│   │       ├── category.response.dto.ts
│   │       └── index.ts
│   │
│   ├── middlewares/            # Express 미들웨어
│   │   ├── auth.middleware.ts
│   │   ├── validation.middleware.ts
│   │   ├── error.middleware.ts
│   │   ├── logging.middleware.ts
│   │   ├── rate-limit.middleware.ts
│   │   └── index.ts
│   │
│   ├── routes/                 # API 라우트 정의
│   │   ├── v1/
│   │   │   ├── product.routes.ts
│   │   │   ├── category.routes.ts
│   │   │   └── index.ts
│   │   ├── health.routes.ts
│   │   └── index.ts
│   │
│   ├── events/                 # 이벤트 처리
│   │   ├── publishers/        # 이벤트 발행
│   │   │   ├── product-created.publisher.ts
│   │   │   ├── product-updated.publisher.ts
│   │   │   ├── product-deleted.publisher.ts
│   │   │   └── index.ts
│   │   └── consumers/         # 이벤트 구독
│   │       ├── order-confirmed.consumer.ts
│   │       ├── inventory-adjusted.consumer.ts
│   │       └── index.ts
│   │
│   ├── utils/                  # 유틸리티 함수
│   │   ├── logger.ts
│   │   ├── errors.ts
│   │   ├── validators.ts
│   │   ├── helpers.ts
│   │   └── index.ts
│   │
│   ├── types/                  # TypeScript 타입 정의
│   │   ├── product.types.ts
│   │   ├── category.types.ts
│   │   ├── express.d.ts
│   │   └── index.ts
│   │
│   ├── database/               # 데이터베이스 관련
│   │   ├── migrations/        # DB 마이그레이션
│   │   │   ├── 001_create_products_table.ts
│   │   │   └── 002_create_categories_table.ts
│   │   └── seeds/             # 시드 데이터
│   │       └── categories.seed.ts
│   │
│   ├── app.ts                  # Express 앱 설정
│   └── server.ts               # 서버 시작점
│
├── tests/                      # 테스트 코드
│   ├── unit/
│   │   ├── services/
│   │   │   ├── product.service.test.ts
│   │   │   └── category.service.test.ts
│   │   └── repositories/
│   │       └── product.repository.test.ts
│   ├── integration/
│   │   └── api/
│   │       ├── product.api.test.ts
│   │       └── category.api.test.ts
│   └── e2e/
│       └── product.e2e.test.ts
│
├── Dockerfile                  # Docker 이미지 빌드
├── .dockerignore
├── docker-compose.yml          # 로컬 개발 환경
├── package.json
├── tsconfig.json
├── jest.config.js
├── .env.example
├── .eslintrc.js
└── README.md
```

---

### 공통 패키지 구조

#### backend/packages/common/

```
backend/packages/common/
├── src/
│   ├── logger/
│   │   └── index.ts           # Winston 로거 설정
│   ├── errors/
│   │   ├── app-error.ts
│   │   ├── not-found-error.ts
│   │   ├── validation-error.ts
│   │   └── index.ts
│   ├── middleware/
│   │   ├── error-handler.ts
│   │   ├── async-handler.ts
│   │   └── index.ts
│   ├── utils/
│   │   ├── response.ts        # 통일된 응답 포맷
│   │   ├── validators.ts
│   │   └── index.ts
│   └── index.ts
│
├── package.json
└── tsconfig.json
```

#### backend/packages/types/

```
backend/packages/types/
├── src/
│   ├── events/
│   │   ├── order-events.ts
│   │   ├── payment-events.ts
│   │   ├── product-events.ts
│   │   └── index.ts
│   ├── api/
│   │   ├── request.types.ts
│   │   ├── response.types.ts
│   │   └── index.ts
│   └── index.ts
│
├── package.json
└── tsconfig.json
```

---

## 프론트엔드 구조

### Admin Web (Next.js App Router)

```
frontend/admin-web/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (auth)/            # Auth 레이아웃 그룹
│   │   │   ├── login/
│   │   │   │   └── page.tsx
│   │   │   └── layout.tsx
│   │   │
│   │   ├── (dashboard)/       # Dashboard 레이아웃 그룹
│   │   │   ├── dashboard/
│   │   │   │   └── page.tsx
│   │   │   │
│   │   │   ├── users/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [id]/
│   │   │   │   │   ├── page.tsx
│   │   │   │   │   └── edit/
│   │   │   │   │       └── page.tsx
│   │   │   │   └── loading.tsx
│   │   │   │
│   │   │   ├── sellers/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [id]/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── approval/
│   │   │   │       └── page.tsx
│   │   │   │
│   │   │   ├── products/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [id]/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── review/
│   │   │   │       └── page.tsx
│   │   │   │
│   │   │   ├── orders/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/
│   │   │   │       └── page.tsx
│   │   │   │
│   │   │   ├── settlements/
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/
│   │   │   │       └── page.tsx
│   │   │   │
│   │   │   ├── notices/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── create/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── [id]/
│   │   │   │       ├── page.tsx
│   │   │   │       └── edit/
│   │   │   │           └── page.tsx
│   │   │   │
│   │   │   ├── settings/
│   │   │   │   └── page.tsx
│   │   │   │
│   │   │   └── layout.tsx
│   │   │
│   │   ├── api/               # API Routes
│   │   │   ├── auth/
│   │   │   │   └── [...nextauth]/
│   │   │   │       └── route.ts
│   │   │   └── revalidate/
│   │   │       └── route.ts
│   │   │
│   │   ├── layout.tsx         # Root Layout
│   │   ├── page.tsx           # Home Page
│   │   ├── loading.tsx        # Global Loading
│   │   ├── error.tsx          # Global Error
│   │   └── not-found.tsx      # 404 Page
│   │
│   ├── components/             # React 컴포넌트
│   │   ├── ui/                # shadcn/ui 컴포넌트
│   │   │   ├── button.tsx
│   │   │   ├── input.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── table.tsx
│   │   │   ├── form.tsx
│   │   │   └── ...
│   │   │
│   │   ├── layouts/           # 레이아웃 컴포넌트
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Footer.tsx
│   │   │   └── Container.tsx
│   │   │
│   │   ├── users/             # 사용자 관련 컴포넌트
│   │   │   ├── UserTable.tsx
│   │   │   ├── UserForm.tsx
│   │   │   └── UserFilters.tsx
│   │   │
│   │   ├── products/          # 상품 관련 컴포넌트
│   │   │   ├── ProductTable.tsx
│   │   │   ├── ProductReviewModal.tsx
│   │   │   └── ProductStatusBadge.tsx
│   │   │
│   │   ├── orders/
│   │   ├── sellers/
│   │   ├── settlements/
│   │   │
│   │   └── common/            # 공통 컴포넌트
│   │       ├── Pagination.tsx
│   │       ├── SearchBar.tsx
│   │       ├── DateRangePicker.tsx
│   │       └── LoadingSpinner.tsx
│   │
│   ├── lib/                    # 유틸리티 및 설정
│   │   ├── api/               # API 클라이언트
│   │   │   ├── client.ts
│   │   │   ├── users.ts
│   │   │   ├── sellers.ts
│   │   │   ├── products.ts
│   │   │   ├── orders.ts
│   │   │   ├── settlements.ts
│   │   │   └── index.ts
│   │   │
│   │   ├── utils.ts           # 유틸 함수
│   │   ├── constants.ts       # 상수
│   │   └── validators.ts      # 검증 함수
│   │
│   ├── hooks/                  # Custom Hooks
│   │   ├── useAuth.ts
│   │   ├── useUsers.ts
│   │   ├── useProducts.ts
│   │   ├── useOrders.ts
│   │   ├── useDebounce.ts
│   │   └── usePagination.ts
│   │
│   ├── store/                  # 상태 관리 (Zustand)
│   │   ├── authStore.ts
│   │   ├── uiStore.ts
│   │   └── index.ts
│   │
│   ├── types/                  # TypeScript 타입
│   │   ├── user.ts
│   │   ├── seller.ts
│   │   ├── product.ts
│   │   ├── order.ts
│   │   ├── settlement.ts
│   │   └── index.ts
│   │
│   └── styles/                 # 스타일
│       └── globals.css
│
├── public/
│   ├── images/
│   │   └── logo.png
│   ├── icons/
│   └── fonts/
│
├── .env.local.example
├── .env.production
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
├── package.json
└── README.md
```

---

### Seller Web (Next.js App Router)

```
frontend/seller-web/
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   └── register/
│   │   │
│   │   ├── (dashboard)/
│   │   │   ├── dashboard/        # 판매 대시보드
│   │   │   ├── products/         # 상품 관리
│   │   │   │   ├── page.tsx
│   │   │   │   ├── create/
│   │   │   │   └── [id]/
│   │   │   │       └── edit/
│   │   │   ├── orders/           # 주문 관리
│   │   │   ├── settlements/      # 정산 조회
│   │   │   ├── reviews/          # 리뷰 관리
│   │   │   ├── store/            # 스토어 설정
│   │   │   └── layout.tsx
│   │   │
│   │   └── layout.tsx
│   │
│   ├── components/
│   │   ├── ui/
│   │   ├── products/
│   │   ├── orders/
│   │   ├── settlements/
│   │   └── charts/              # Chart.js 차트 컴포넌트
│   │
│   ├── lib/
│   ├── hooks/
│   ├── store/
│   └── types/
│
└── ... (admin-web와 동일한 구조)
```

---

### User App (Flutter)

```
frontend/user-app/
├── lib/
│   ├── main.dart
│   │
│   ├── core/                   # 핵심 기능
│   │   ├── api/
│   │   │   ├── api_client.dart
│   │   │   ├── interceptors/
│   │   │   │   ├── auth_interceptor.dart
│   │   │   │   └── logging_interceptor.dart
│   │   │   └── endpoints.dart
│   │   │
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   └── env.dart
│   │   │
│   │   ├── constants/
│   │   │   ├── colors.dart
│   │   │   ├── strings.dart
│   │   │   ├── sizes.dart
│   │   │   └── api_constants.dart
│   │   │
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   │
│   │   └── utils/
│   │       ├── logger.dart
│   │       ├── validators.dart
│   │       └── formatters.dart
│   │
│   ├── features/               # 기능별 Clean Architecture
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   └── token_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── auth_remote_datasource.dart
│   │   │   │       └── auth_local_datasource.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login.dart
│   │   │   │       ├── logout.dart
│   │   │   │       └── register.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   ├── register_page.dart
│   │   │       │   └── profile_page.dart
│   │   │       ├── widgets/
│   │   │       │   ├── login_form.dart
│   │   │       │   └── social_login_buttons.dart
│   │   │       └── providers/
│   │   │           └── auth_provider.dart
│   │   │
│   │   ├── home/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── home_page.dart
│   │   │       └── widgets/
│   │   │           ├── category_list.dart
│   │   │           ├── banner_carousel.dart
│   │   │           └── product_grid.dart
│   │   │
│   │   ├── products/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── product_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   └── datasources/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── product.dart
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │       ├── get_products.dart
│   │   │   │       ├── get_product_detail.dart
│   │   │   │       └── search_products.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── product_list_page.dart
│   │   │       │   ├── product_detail_page.dart
│   │   │       │   └── search_page.dart
│   │   │       ├── widgets/
│   │   │       │   ├── product_card.dart
│   │   │       │   ├── product_image_carousel.dart
│   │   │       │   └── product_options.dart
│   │   │       └── providers/
│   │   │           └── product_provider.dart
│   │   │
│   │   ├── cart/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── cart_page.dart
│   │   │       └── widgets/
│   │   │           ├── cart_item.dart
│   │   │           └── cart_summary.dart
│   │   │
│   │   ├── orders/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── checkout_page.dart
│   │   │       │   ├── order_list_page.dart
│   │   │       │   └── order_detail_page.dart
│   │   │       └── widgets/
│   │   │           ├── address_selector.dart
│   │   │           ├── payment_method_selector.dart
│   │   │           └── order_summary.dart
│   │   │
│   │   ├── reviews/
│   │   ├── wishlist/
│   │   └── profile/
│   │
│   ├── shared/                 # 공통 위젯 및 유틸
│   │   ├── widgets/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── cached_image.dart
│   │   │   └── bottom_nav_bar.dart
│   │   │
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── app_colors.dart
│   │       └── app_text_styles.dart
│   │
│   ├── routes/                 # 라우팅
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   │
│   └── injection.dart          # Dependency Injection
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── placeholder.png
│   │   └── ...
│   ├── icons/
│   └── fonts/
│
├── test/
│   ├── unit/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   └── products/
│   │   └── core/
│   ├── widget/
│   │   └── features/
│   └── integration/
│
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

**pubspec.yaml 주요 의존성**:
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0

  # Network
  dio: ^5.3.0
  retrofit: ^4.0.0

  # Local Storage
  shared_preferences: ^2.2.0
  hive: ^2.2.3

  # UI
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.7

  # Utils
  intl: ^0.18.1
  logger: ^2.0.0

  # Dependency Injection
  get_it: ^7.6.0
```

---

## Lambda 함수 구조

```
lambda/payment-processor/
├── src/
│   ├── index.ts                # Lambda handler
│   ├── lib/
│   │   ├── payment.ts         # 결제 로직
│   │   ├── eventbridge.ts     # EventBridge 발행
│   │   └── db.ts              # 데이터베이스 연결
│   ├── types/
│   │   └── events.ts          # 이벤트 타입 정의
│   └── utils/
│       └── logger.ts
│
├── tests/
│   ├── index.test.ts
│   └── lib/
│       └── payment.test.ts
│
├── package.json
├── tsconfig.json
└── README.md
```

---

## Infrastructure 구조

### Terraform 구조

```
infrastructure/terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backend.tf          # S3 backend 설정
│   │   └── terraform.tfvars
│   │
│   ├── staging/
│   │   └── ... (동일 구조)
│   │
│   └── production/
│       └── ... (동일 구조)
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── ecs/
│   │   ├── cluster.tf
│   │   ├── service.tf
│   │   ├── task-definition.tf
│   │   ├── auto-scaling.tf
│   │   ├── alb.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── rds/
│   │   ├── main.tf
│   │   ├── subnet-group.tf
│   │   ├── parameter-group.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── dynamodb/
│   ├── s3/
│   ├── elasticache/
│   ├── opensearch/
│   ├── lambda/
│   ├── eventbridge/
│   ├── api-gateway/
│   ├── cloudfront/
│   ├── cognito/
│   └── cloudwatch/
│
└── scripts/
    ├── init.sh                # Terraform 초기화
    ├── plan.sh                # terraform plan 실행
    ├── apply.sh               # terraform apply 실행
    ├── destroy.sh             # terraform destroy 실행
    └── outputs.sh             # outputs 조회
```

---

## 공통 설정 파일

### 루트 .gitignore

```gitignore
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
*.log

# Production
build/
dist/
.next/
out/

# Environment
.env
.env.local
.env.*.local

# IDEs
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Terraform
*.tfstate
*.tfstate.backup
.terraform/
*.tfplan

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
pubspec.lock
build/

# AWS
.aws-sam/
```

---

### 루트 .editorconfig

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[*.py]
indent_size = 4

[Makefile]
indent_style = tab
```

---

**7단계 완료**: 전체 폴더 구조 설계가 완성되었습니다!

**작성일**: 2025-12-03
**버전**: 1.0
