# DOA Market - Frontend

DOA Market 오픈마켓 시스템의 프론트엔드 애플리케이션입니다.

## 프로젝트 구조

```
frontend/
├── admin-web/        # 관리자 웹 (Next.js)
├── seller-web/       # 판매자 웹 (Next.js)
└── user-app/         # 사용자 모바일 앱 (Flutter)
```

## Admin Web (관리자 웹)

### 기술 스택
- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **State Management**: Zustand
- **Data Fetching**: TanStack Query (React Query)
- **HTTP Client**: Axios
- **UI Components**: Radix UI, Tailwind CSS
- **Charts**: Recharts
- **Form**: React Hook Form + Zod

### 주요 기능
- 대시보드 (통계 및 차트)
- 사용자 관리 (조회, 정지, 삭제)
- 판매자 관리 (승인, 거부, 정지)
- 상품 관리 (심사, 승인, 거부)
- 주문 관리 (조회, 상태변경, 취소)
- 정산 관리 (확정, 지급처리)
- 리뷰 관리
- 쿠폰 관리
- 공지사항 관리

### 시작하기

```bash
cd admin-web

# 의존성 설치
npm install

# 개발 서버 실행 (포트: 3100)
npm run dev

# 빌드
npm run build

# 프로덕션 실행
npm run start
```

### 환경변수

`.env.local` 파일을 생성하고 다음 변수를 설정하세요:

```env
NEXT_PUBLIC_API_URL=https://api.doamarket.com
```

---

## Seller Web (판매자 웹)

### 기술 스택
- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **State Management**: Zustand
- **Data Fetching**: TanStack Query
- **HTTP Client**: Axios
- **UI Components**: Radix UI, Tailwind CSS
- **Charts**: Recharts

### 주요 기능
- 대시보드 (판매 통계)
- 상품 관리 (등록, 수정, 삭제)
- 주문 관리 (조회, 상태변경)
- 정산 관리 (조회, 정산서 다운로드)
- 스토어 관리
- 통계 (매출, 상품별 통계)

### 시작하기

```bash
cd seller-web

# 의존성 설치
npm install

# 개발 서버 실행 (포트: 3200)
npm run dev

# 빌드
npm run build

# 프로덕션 실행
npm run start
```

### 환경변수

`.env.local` 파일을 생성하고 다음 변수를 설정하세요:

```env
NEXT_PUBLIC_API_URL=https://api.doamarket.com
```

---

## User App (사용자 모바일 앱)

### 기술 스택
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio + Retrofit
- **Local Storage**: SharedPreferences, FlutterSecureStorage
- **Code Generation**: Freezed, JsonSerializable

### 주요 기능
- 홈 (배너, 카테고리, 인기상품)
- 상품 목록 (검색, 필터, 정렬)
- 상품 상세 (이미지, 설명, 리뷰)
- 장바구니
- 주문하기
- 주문 목록/상세
- 마이페이지 (프로필, 주소, 찜 목록)
- 로그인/회원가입

### 시작하기

```bash
cd user-app

# 의존성 설치
flutter pub get

# 코드 생성 (Freezed, JsonSerializable)
flutter pub run build_runner build --delete-conflicting-outputs

# iOS 실행
flutter run -d ios

# Android 실행
flutter run -d android

# 빌드 (iOS)
flutter build ios --release

# 빌드 (Android)
flutter build apk --release
```

### 환경변수

앱 실행 시 환경변수를 전달할 수 있습니다:

```bash
flutter run --dart-define=API_BASE_URL=https://api.doamarket.com
```

---

## 공통 아키텍처 원칙

### API 통신
- RESTful API 사용
- JWT 기반 인증 (Access Token + Refresh Token)
- Axios/Dio Interceptor를 통한 토큰 자동 갱신
- 통일된 API Response 형식

### 상태 관리
- **Next.js**: Zustand (전역 상태) + TanStack Query (서버 상태)
- **Flutter**: Riverpod (전역 상태 + 서버 상태)

### 라우팅
- **Next.js**: App Router (파일 기반 라우팅)
- **Flutter**: GoRouter (선언적 라우팅)

### 스타일링
- **Next.js**: Tailwind CSS + Radix UI
- **Flutter**: Material Design 3

### 타입 안정성
- **Next.js**: TypeScript 사용
- **Flutter**: Freezed + JsonSerializable 사용

---

## API 엔드포인트 구조

### 인증
- `POST /api/v1/auth/login` - 로그인
- `POST /api/v1/auth/register` - 회원가입
- `POST /api/v1/auth/refresh` - 토큰 갱신
- `POST /api/v1/auth/logout` - 로그아웃

### 관리자 (Admin)
- `GET /api/v1/admin/dashboard/stats` - 대시보드 통계
- `GET /api/v1/admin/users` - 사용자 목록
- `GET /api/v1/admin/sellers` - 판매자 목록
- `POST /api/v1/admin/sellers/:id/approve` - 판매자 승인
- `GET /api/v1/admin/products` - 상품 목록
- `POST /api/v1/admin/products/:id/approve` - 상품 승인
- `GET /api/v1/admin/orders` - 주문 목록
- `GET /api/v1/admin/settlements` - 정산 목록

### 판매자 (Seller)
- `GET /api/v1/seller/dashboard/stats` - 대시보드 통계
- `GET /api/v1/seller/products` - 내 상품 목록
- `POST /api/v1/seller/products` - 상품 등록
- `GET /api/v1/seller/orders` - 내 주문 목록
- `PATCH /api/v1/seller/orders/:id/status` - 주문 상태 변경
- `GET /api/v1/seller/settlements` - 내 정산 목록

### 사용자 (User)
- `GET /api/v1/products` - 상품 목록
- `GET /api/v1/products/:id` - 상품 상세
- `GET /api/v1/cart` - 장바구니 조회
- `POST /api/v1/cart/items` - 장바구니 추가
- `POST /api/v1/orders` - 주문 생성
- `GET /api/v1/orders` - 내 주문 목록
- `GET /api/v1/user/profile` - 프로필 조회

---

## 개발 가이드

### 코드 스타일
- **Next.js**: ESLint + Prettier
- **Flutter**: flutter_lints + dartfmt

### 브랜치 전략
- `main`: 프로덕션 배포
- `develop`: 개발 통합
- `feature/*`: 기능 개발
- `bugfix/*`: 버그 수정

### 커밋 메시지
```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 코드 리팩토링
test: 테스트 추가/수정
chore: 빌드 업무, 패키지 설정 등
```

---

## 문제 해결

### Next.js 빌드 에러
```bash
# node_modules 재설치
rm -rf node_modules package-lock.json
npm install

# 캐시 클리어
rm -rf .next
npm run build
```

### Flutter 코드 생성 에러
```bash
# 기존 생성 파일 삭제 후 재생성
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 라이선스

MIT License

---

## 문의

- **이메일**: support@doamarket.com
- **문서**: [Architecture Docs](../docs/)

