# DOA Market - API 테스트 가이드

## 🚀 빠른 시작

### 1. Docker 실행 확인

먼저 Docker Desktop이 실행 중인지 확인하세요.

```bash
# Docker 상태 확인
docker --version
docker ps
```

### 2. 서비스 실행

```bash
cd /Users/krystal/workspace/doa-market

# PostgreSQL과 Redis만 먼저 실행
docker-compose up -d postgres redis

# 잠시 대기 (데이터베이스 초기화)
sleep 10

# Auth Service 실행
docker-compose up -d auth-service

# User, Product, Order Service 실행
docker-compose up -d user-service product-service order-service

# 모든 서비스 상태 확인
docker-compose ps
```

### 3. 로컬에서 Auth Service 실행 (권장)

Docker보다 로컬 실행이 더 빠르고 디버깅이 편합니다.

```bash
# Terminal 1: PostgreSQL & Redis
cd /Users/krystal/workspace/doa-market
docker-compose up -d postgres redis

# Terminal 2: Auth Service
cd backend/auth-service
npm install
npm run dev
```

---

## 📚 Swagger API 문서

### Auth Service (포트: 3001)

```
http://localhost:3001/api-docs
```

**주요 API:**
- `POST /api/v1/auth/register` - 회원가입
- `POST /api/v1/auth/login` - 로그인
- `POST /api/v1/auth/refresh` - 토큰 갱신
- `POST /api/v1/auth/logout` - 로그아웃 (인증 필요)
- `GET /api/v1/auth/me` - 현재 사용자 (인증 필요)

### User Service (포트: 3002)

```
http://localhost:3002/api-docs
```

### Product Service (포트: 3003)

```
http://localhost:3003/api-docs
```

### Order Service (포트: 3004)

```
http://localhost:3004/api-docs
```

---

## 🧪 API 테스트 시나리오

### 시나리오 1: 회원가입 → 로그인 → 사용자 정보 조회

#### Step 1: 회원가입

```bash
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "password123",
    "name": "홍길동",
    "role": "user"
  }'
```

**예상 응답:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "test@test.com",
      "name": "홍길동",
      "role": "user"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

#### Step 2: 로그인

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "password123"
  }' | jq
```

**토큰 저장:**
```bash
# macOS/Linux
TOKEN=$(curl -s -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}' \
  | jq -r '.data.accessToken')

echo $TOKEN
```

#### Step 3: 현재 사용자 정보 조회

```bash
curl -X GET http://localhost:3001/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

### 시나리오 2: 상품 등록 → 주문 생성

#### Step 1: 판매자 회원가입

```bash
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seller@test.com",
    "password": "password123",
    "name": "판매자",
    "role": "seller"
  }' | jq
```

#### Step 2: 상품 등록

```bash
curl -X POST http://localhost:3003/api/v1/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "맥북 프로 M3",
    "description": "최신 맥북 프로",
    "price": 2500000,
    "stock": 10,
    "category": "전자기기",
    "sellerId": "seller-uuid"
  }' | jq
```

#### Step 3: 주문 생성

```bash
curl -X POST http://localhost:3004/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "userId": "user-uuid",
    "sellerId": "seller-uuid",
    "items": [
      {
        "productId": "product-uuid",
        "quantity": 1,
        "price": 2500000
      }
    ],
    "totalAmount": 2500000,
    "shippingAddress": "서울시 강남구"
  }' | jq
```

---

## 🔍 Health Check (모든 서비스)

```bash
#!/bin/bash
echo "=== Service Health Check ==="
for port in 3001 3002 3003 3004 3005 3006 3007 3008 3009 3010 3011 3012 3013 3014 3015 3016; do
  echo -n "Port $port: "
  STATUS=$(curl -s http://localhost:$port/health 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "$STATUS" | jq -r '.service + " - " + .status'
  else
    echo "❌ DOWN"
  fi
done
```

**저장 및 실행:**
```bash
# 스크립트 저장
cat > health-check.sh << 'EOF'
#!/bin/bash
echo "=== Service Health Check ==="
for port in 3001 3002 3003 3004 3005 3006 3007 3008 3009 3010 3011 3012 3013 3014 3015 3016; do
  echo -n "Port $port: "
  STATUS=$(curl -s http://localhost:$port/health 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "$STATUS" | jq -r '.service + " - " + .status'
  else
    echo "❌ DOWN"
  fi
done
EOF

# 실행 권한 부여
chmod +x health-check.sh

# 실행
./health-check.sh
```

---

## 🐛 디버깅

### 로그 확인

```bash
# 전체 서비스 로그
docker-compose logs -f

# Auth Service 로그만
docker-compose logs -f auth-service

# 에러만 필터
docker-compose logs | grep ERROR

# 최근 100줄
docker-compose logs --tail=100
```

### 데이터베이스 확인

```bash
# PostgreSQL 접속
docker exec -it doa-postgres psql -U postgres

# 데이터베이스 목록
\l

# doa_auth 데이터베이스 접속
\c doa_auth

# 테이블 목록
\dt

# users 테이블 조회
SELECT * FROM users;

# 종료
\q
```

### PgAdmin으로 확인

```
URL: http://localhost:5050
Email: admin@doamarket.com
Password: admin
```

**서버 추가:**
1. Add New Server
2. General > Name: DOA Market
3. Connection:
   - Host: postgres (Docker 네트워크) 또는 localhost
   - Port: 5432
   - Username: postgres
   - Password: postgres

---

## 🔧 문제 해결

### 1. Docker daemon 에러

```bash
# Docker Desktop이 실행되지 않음
# → Docker Desktop 앱을 실행하세요
```

### 2. 포트 충돌

```bash
# 포트가 이미 사용 중
lsof -i :3001

# 프로세스 종료
kill -9 <PID>
```

### 3. 데이터베이스 연결 실패

```bash
# PostgreSQL 상태 확인
docker-compose ps postgres

# 재시작
docker-compose restart postgres

# 로그 확인
docker-compose logs postgres
```

### 4. 서비스 재시작

```bash
# 전체 중지
docker-compose down

# 전체 재시작 (빌드 포함)
docker-compose up --build -d

# 특정 서비스만 재시작
docker-compose restart auth-service
```

---

## 📱 Postman Collection

### 1. 회원가입 & 로그인

**Collection 생성:**
1. Postman 실행
2. New Collection 생성: "DOA Market"
3. Add Request

**환경 변수 설정:**
```json
{
  "baseUrl": "http://localhost:3001",
  "accessToken": ""
}
```

**Request 1: 회원가입**
```
POST {{baseUrl}}/api/v1/auth/register
Body (JSON):
{
  "email": "test@test.com",
  "password": "password123",
  "name": "Test User"
}
```

**Request 2: 로그인**
```
POST {{baseUrl}}/api/v1/auth/login
Body (JSON):
{
  "email": "test@test.com",
  "password": "password123"
}

Tests (자동으로 토큰 저장):
pm.environment.set("accessToken", pm.response.json().data.accessToken);
```

**Request 3: 사용자 정보 조회**
```
GET {{baseUrl}}/api/v1/auth/me
Headers:
  Authorization: Bearer {{accessToken}}
```

---

## 🎯 권장 테스트 순서

### Phase 1: 기본 기능 테스트
1. ✅ Docker 실행 확인
2. ✅ PostgreSQL & Redis 실행
3. ✅ Auth Service 실행
4. ✅ Health Check
5. ✅ 회원가입
6. ✅ 로그인
7. ✅ 사용자 정보 조회

### Phase 2: Swagger 테스트
1. ✅ http://localhost:3001/api-docs 접속
2. ✅ Try it out으로 API 테스트
3. ✅ Bearer Token 인증 테스트

### Phase 3: 다른 서비스 테스트
1. ✅ User Service 실행 및 테스트
2. ✅ Product Service 실행 및 테스트
3. ✅ Order Service 실행 및 테스트

---

## 📊 테스트 체크리스트

### Auth Service ✅
- [ ] 회원가입 성공
- [ ] 중복 이메일 에러
- [ ] 로그인 성공
- [ ] 잘못된 비밀번호 에러
- [ ] JWT 토큰 발급
- [ ] 토큰으로 사용자 정보 조회
- [ ] 토큰 갱신
- [ ] 로그아웃

### User Service
- [ ] 사용자 목록 조회
- [ ] 사용자 상세 조회
- [ ] 사용자 정보 수정
- [ ] 사용자 삭제

### Product Service
- [ ] 상품 목록 조회
- [ ] 상품 등록
- [ ] 상품 수정
- [ ] 상품 삭제

### Order Service
- [ ] 주문 생성
- [ ] 주문 목록 조회
- [ ] 주문 상태 변경

---

## 🚀 다음 단계

1. **EventBridge 구축** - 서비스 간 이벤트 통신
2. **API Gateway** - 통합 엔드포인트
3. **모니터링** - Prometheus + Grafana
4. **부하 테스트** - Artillery, k6
5. **E2E 테스트** - Playwright

---

**작성일**: 2025-12-04  
**버전**: 1.0.0

