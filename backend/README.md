# DOA Market - Backend Services

마이크로서비스 아키텍처 기반 백엔드 시스템입니다.

## 🏗️ 서비스 구조

```
backend/
├── auth-service/          ✅ 구현 완료 (인증/인가)
├── user-service/          📋 구현 예정
├── product-service/       📋 구현 예정
├── order-service/         📋 구현 예정
├── payment-service/       📋 구현 예정
├── shipping-service/      📋 구현 예정
├── seller-service/        📋 구현 예정
├── settlement-service/    📋 구현 예정
├── coupon-service/        📋 구현 예정
├── inventory-service/     📋 구현 예정
├── notification-service/  📋 구현 예정
├── review-service/        📋 구현 예정
├── search-service/        📋 구현 예정
├── admin-service/         📋 구현 예정
├── file-service/          📋 구현 예정
└── stats-service/         📋 구현 예정
```

## 🚀 빠른 시작

### Prerequisites

- Node.js 20+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+

### Docker Compose로 전체 환경 실행

```bash
# 루트 디렉토리에서
docker-compose up -d

# 서비스 확인
docker-compose ps

# 로그 확인
docker-compose logs -f auth-service
```

### 개별 서비스 실행

```bash
# Auth Service
cd backend/auth-service
npm install
cp .env.example .env
npm run dev  # http://localhost:3001
```

## 📋 서비스 포트

| 서비스 | 포트 | 상태 |
|--------|------|------|
| auth-service | 3001 | ✅ |
| user-service | 3002 | 📋 |
| product-service | 3003 | 📋 |
| order-service | 3004 | 📋 |
| payment-service | 3005 | 📋 |
| shipping-service | 3006 | 📋 |
| seller-service | 3007 | 📋 |
| settlement-service | 3008 | 📋 |
| coupon-service | 3009 | 📋 |
| inventory-service | 3010 | 📋 |
| notification-service | 3011 | 📋 |
| review-service | 3012 | 📋 |
| search-service | 3013 | 📋 |
| admin-service | 3014 | 📋 |
| file-service | 3015 | 📋 |
| stats-service | 3016 | 📋 |

## 🔧 인프라 서비스

| 서비스 | 포트 | 용도 |
|--------|------|------|
| PostgreSQL | 5432 | 관계형 데이터베이스 |
| Redis | 6379 | 캐시 & 세션 |
| PgAdmin | 5050 | DB 관리 UI |

## ✅ Auth Service (완료)

### 기능
- 회원가입 (이메일/비밀번호)
- 로그인 (JWT)
- 토큰 갱신
- 로그아웃
- 현재 사용자 정보

### API 테스트

```bash
# Health Check
curl http://localhost:3001/health

# 회원가입
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@doamarket.com",
    "password": "admin123!",
    "name": "Admin User",
    "role": "admin"
  }'

# 로그인
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@doamarket.com",
    "password": "admin123!"
  }'

# 토큰으로 사용자 정보 조회
curl -X GET http://localhost:3001/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 🧪 테스트

### Auth Service 테스트

```bash
cd backend/auth-service

# 단위 테스트
npm test

# 테스트 (watch 모드)
npm run test:watch

# 커버리지
npm run test:coverage
```

## 🗄️ 데이터베이스

### 접속 정보

```
Host: localhost
Port: 5432
Username: postgres
Password: postgres
```

### 데이터베이스 목록

- `doa_auth` - 인증 서비스
- `doa_users` - 사용자 서비스
- `doa_products` - 상품 서비스
- `doa_orders` - 주문 서비스
- `doa_payments` - 결제 서비스
- `doa_settlements` - 정산 서비스

### PgAdmin 접속

```
URL: http://localhost:5050
Email: admin@doamarket.com
Password: admin
```

## 🔑 환경변수

각 서비스의 `.env.example`을 복사하여 `.env` 파일을 만드세요:

```bash
cd backend/auth-service
cp .env.example .env
```

## 📊 모니터링

### 서비스 상태 확인

```bash
# Health Check 모든 서비스
curl http://localhost:3001/health  # Auth Service
curl http://localhost:3002/health  # User Service
# ... 등등
```

### Docker 로그 확인

```bash
# 모든 서비스 로그
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs -f auth-service
```

## 🛠️ 문제 해결

### 포트 충돌

```bash
# 사용 중인 포트 확인 (Mac/Linux)
lsof -i :3001

# 프로세스 종료
kill -9 <PID>
```

### Docker 컨테이너 재시작

```bash
# 모든 서비스 재시작
docker-compose restart

# 특정 서비스만 재시작
docker-compose restart auth-service
```

### 데이터베이스 초기화

```bash
# 볼륨 포함 전체 삭제
docker-compose down -v

# 재시작
docker-compose up -d
```

## 📚 개발 가이드

### 새로운 서비스 추가

1. 서비스 디렉토리 생성
2. package.json 설정
3. TypeScript 설정
4. 모델 정의
5. API 엔드포인트 구현
6. 테스트 작성
7. Docker 설정 추가

### 코드 스타일

- ESLint + Prettier
- TypeScript strict mode
- Jest for testing

### Git Workflow

```bash
# Feature 브랜치 생성
git checkout -b feature/your-feature

# 커밋
git commit -m "feat: add feature"

# Push
git push origin feature/your-feature
```

## 📖 추가 문서

- [아키텍처 설계](../docs/01-architecture-design.md)
- [마이크로서비스 및 이벤트](../docs/02-microservices-and-events.md)
- [CI/CD 파이프라인](../docs/14-cicd-pipeline.md)

## 📝 라이선스

MIT

