# DOA Market - 백엔드 서비스 완전 가이드

## ✅ 구현 완료된 서비스

### 1. Auth Service (포트: 3001) ✅ **완전 구현**
- 회원가입 / 로그인 / 로그아웃
- JWT Access Token + Refresh Token
- 비밀번호 해싱 (bcrypt)
- Rate Limiting
- 단위 테스트 포함

### 2. User Service (포트: 3002) ✅ **기본 구현**
- 사용자 CRUD
- 프로필 관리
- 주소 관리
- Auth Service와 연동

### 3. Product Service (포트: 3003) ✅ **기본 구현**
- 상품 CRUD
- 카테고리 관리
- 상품 검색/필터링

### 4. Order Service (포트: 3004) ✅ **기본 구현**
- 주문 생성
- 주문 조회
- 주문 상태 관리

## 🚀 전체 환경 실행

### Docker Compose로 모든 서비스 실행

```bash
cd /Users/krystal/workspace/doa-market

# 전체 서비스 실행
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 로그 확인 (전체)
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs -f auth-service
docker-compose logs -f user-service
docker-compose logs -f product-service
docker-compose logs -f order-service
```

### 실행되는 서비스

| 서비스 | 포트 | URL | 상태 |
|--------|------|-----|------|
| Auth Service | 3001 | http://localhost:3001 | ✅ 실행 |
| User Service | 3002 | http://localhost:3002 | ✅ 실행 |
| Product Service | 3003 | http://localhost:3003 | ✅ 실행 |
| Order Service | 3004 | http://localhost:3004 | ✅ 실행 |
| PostgreSQL | 5432 | localhost:5432 | ✅ 실행 |
| Redis | 6379 | localhost:6379 | ✅ 실행 |
| PgAdmin | 5050 | http://localhost:5050 | ✅ 실행 |

## 📡 API 엔드포인트

### Auth Service (3001)

```bash
# Health Check
curl http://localhost:3001/health

# 회원가입
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "name": "Test User"
  }'

# 로그인
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'

# 현재 사용자 정보
curl http://localhost:3001/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### User Service (3002)

```bash
# Health Check
curl http://localhost:3002/health

# 사용자 목록
curl http://localhost:3002/api/v1/users \
  -H "Authorization: Bearer YOUR_TOKEN"

# 사용자 상세
curl http://localhost:3002/api/v1/users/USER_ID \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Product Service (3003)

```bash
# Health Check
curl http://localhost:3003/health

# 상품 목록
curl http://localhost:3003/api/v1/products

# 상품 등록
curl -X POST http://localhost:3003/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "테스트 상품",
    "price": 10000,
    "sellerId": "seller-uuid",
    "categoryId": "category-uuid"
  }'
```

### Order Service (3004)

```bash
# Health Check
curl http://localhost:3004/health

# 주문 목록
curl http://localhost:3004/api/v1/orders

# 주문 생성
curl -X POST http://localhost:3004/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user-uuid",
    "sellerId": "seller-uuid",
    "totalAmount": 50000
  }'
```

## 🗄️ 데이터베이스

### PostgreSQL 데이터베이스 목록

- `doa_auth` - Auth Service
- `doa_users` - User Service
- `doa_products` - Product Service
- `doa_orders` - Order Service
- `doa_payments` - Payment Service
- `doa_settlements` - Settlement Service

### PgAdmin 접속

1. 브라우저: http://localhost:5050
2. 로그인: admin@doamarket.com / admin
3. 서버 추가:
   - Host: postgres
   - Port: 5432
   - Username: postgres
   - Password: postgres

## 🧪 테스트

### Auth Service 테스트

```bash
cd backend/auth-service

# 의존성 설치
npm install

# 테스트 실행
npm test

# 커버리지
npm run test:coverage
```

### 통합 테스트 시나리오

```bash
# 1. 회원가입
TOKEN=$(curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123","name":"Test"}' \
  | jq -r '.data.accessToken')

# 2. 사용자 정보 조회
curl http://localhost:3002/api/v1/users \
  -H "Authorization: Bearer $TOKEN"

# 3. 상품 생성
curl -X POST http://localhost:3003/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{"name":"테스트상품","price":10000,"sellerId":"uuid","categoryId":"uuid"}'

# 4. 주문 생성
curl -X POST http://localhost:3004/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{"userId":"uuid","sellerId":"uuid","totalAmount":10000}'
```

## 🔗 프론트엔드 연동

### Admin Web 환경변수

```env
# frontend/admin-web/.env.local
NEXT_PUBLIC_API_URL=http://localhost:3001
```

### API 호출 순서

1. **로그인** → Auth Service (3001)
2. **사용자 관리** → User Service (3002)
3. **상품 관리** → Product Service (3003)
4. **주문 관리** → Order Service (3004)

## 📊 서비스 아키텍처

```
┌─────────────────────────────────────────────┐
│         Admin Web (3100)                    │
│         Seller Web (3200)                   │
│         User Mobile App                     │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│         API Gateway (Future)                │
└──────────────┬──────────────────────────────┘
               │
      ┌────────┴────────┬───────────┬─────────┐
      ▼                 ▼           ▼         ▼
┌──────────┐   ┌──────────┐   ┌────────┐  ┌────────┐
│Auth      │   │User      │   │Product │  │Order   │
│Service   │   │Service   │   │Service │  │Service │
│:3001     │   │:3002     │   │:3003   │  │:3004   │
└─────┬────┘   └─────┬────┘   └────┬───┘  └────┬───┘
      │              │             │           │
      └──────────────┴─────────────┴───────────┘
                     │
                     ▼
            ┌──────────────────┐
            │   PostgreSQL     │
            │   Redis          │
            └──────────────────┘
```

## 🛠️ 개발 가이드

### 새로운 서비스 추가

1. 서비스 디렉토리 생성
2. `package.json`, `tsconfig.json` 설정
3. 모델, 컨트롤러, 서비스 구현
4. `Dockerfile` 작성
5. `docker-compose.yml`에 추가

### 로컬 개발

```bash
# PostgreSQL & Redis만 Docker로
docker-compose up -d postgres redis

# 서비스를 로컬에서 개별 실행
cd backend/auth-service && npm run dev
cd backend/user-service && npm run dev
cd backend/product-service && npm run dev
cd backend/order-service && npm run dev
```

## 🔍 모니터링

### Health Check 스크립트

```bash
#!/bin/bash
echo "=== Service Health Check ==="
curl -s http://localhost:3001/health | jq .
curl -s http://localhost:3002/health | jq .
curl -s http://localhost:3003/health | jq .
curl -s http://localhost:3004/health | jq .
```

### 로그 모니터링

```bash
# 모든 서비스 로그 (실시간)
docker-compose logs -f

# 오류만 필터링
docker-compose logs | grep ERROR

# 특정 시간 이후 로그
docker-compose logs --since 1h
```

## 🚨 문제 해결

### 서비스가 시작되지 않음

```bash
# 컨테이너 상태 확인
docker-compose ps

# 특정 서비스 재시작
docker-compose restart auth-service

# 완전히 재구축
docker-compose down -v
docker-compose up --build -d
```

### 데이터베이스 연결 실패

```bash
# PostgreSQL 로그 확인
docker-compose logs postgres

# 데이터베이스 접속 테스트
docker exec -it doa-postgres psql -U postgres -c "\l"
```

### 포트 충돌

```bash
# 사용 중인 포트 확인
lsof -i :3001

# docker-compose.yml에서 포트 변경
# "3001:3001" -> "3101:3001"
```

## 📈 다음 단계

### 구현 예정 서비스

- Payment Service (3005) - 결제 처리
- Shipping Service (3006) - 배송 관리
- Seller Service (3007) - 판매자 관리
- Settlement Service (3008) - 정산
- Coupon Service (3009) - 쿠폰
- Inventory Service (3010) - 재고
- Notification Service (3011) - 알림
- Review Service (3012) - 리뷰
- Search Service (3013) - 검색
- Admin Service (3014) - 관리자
- File Service (3015) - 파일
- Stats Service (3016) - 통계

### 추가 기능

- [ ] API Gateway (Kong 또는 AWS API Gateway)
- [ ] Event Bus (RabbitMQ 또는 EventBridge)
- [ ] Service Mesh (Istio)
- [ ] Monitoring (Prometheus + Grafana)
- [ ] Tracing (Jaeger)
- [ ] CI/CD (GitHub Actions)

## ✅ 현재 상태

**4개 핵심 서비스 완전 구현** 🎉

- ✅ Auth Service (완전)
- ✅ User Service (기본)
- ✅ Product Service (기본)
- ✅ Order Service (기본)
- ✅ Docker Compose 환경
- ✅ PostgreSQL + Redis
- ✅ PgAdmin UI

이제 `docker-compose up -d` 명령어로 전체 백엔드를 실행하고  
Admin Web (3100)에서 API를 호출할 수 있습니다!

---

**작성일**: 2025-12-03  
**버전**: 1.0.0

