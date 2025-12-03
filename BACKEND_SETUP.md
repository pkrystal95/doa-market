# 백엔드 개발 환경 설정 및 테스트 가이드

## 🎉 완료된 작업

### ✅ Auth Service 구현 완료
- JWT 기반 인증/인가
- 회원가입, 로그인, 토큰 갱신, 로그아웃
- PostgreSQL + Sequelize ORM
- 단위 테스트 (Jest)
- Docker 지원

### ✅ 테스트 환경 구축
- Jest + Supertest 설정
- 단위 테스트 작성
- 커버리지 리포트

### ✅ Docker Compose 환경
- PostgreSQL 데이터베이스
- Redis 캐시
- PgAdmin (DB 관리 UI)
- Auth Service

## 🚀 실행 방법

### 방법 1: Docker Compose로 전체 환경 실행 (권장)

```bash
# 1. 루트 디렉토리에서
cd /Users/krystal/workspace/doa-market

# 2. Docker Compose 실행
docker-compose up -d

# 3. 서비스 상태 확인
docker-compose ps

# 4. 로그 확인
docker-compose logs -f auth-service

# 5. Auth Service 접속 테스트
curl http://localhost:3001/health
```

**실행 후 접속 URL:**
- Auth Service: http://localhost:3001
- PostgreSQL: localhost:5432
- Redis: localhost:6379
- PgAdmin: http://localhost:5050

### 방법 2: 로컬에서 직접 실행

```bash
# 1. PostgreSQL & Redis 실행 (Docker Compose 사용)
docker-compose up -d postgres redis

# 2. Auth Service 실행
cd backend/auth-service

# 3. 의존성 설치
npm install

# 4. 환경변수 설정
cp .env.example .env

# 5. 개발 서버 실행
npm run dev

# 6. 다른 터미널에서 테스트 실행
npm test
```

## 🧪 테스트 실행

### Auth Service 단위 테스트

```bash
cd backend/auth-service

# 전체 테스트
npm test

# Watch 모드 (개발 중 유용)
npm run test:watch

# 커버리지 리포트
npm run test:coverage
```

**예상 결과:**
```
PASS  src/__tests__/auth.service.test.ts
PASS  src/__tests__/auth.controller.test.ts

Test Suites: 2 passed, 2 total
Tests:       8 passed, 8 total
Snapshots:   0 total
Time:        2.5s
```

## 📡 API 테스트

### 1. Health Check

```bash
curl http://localhost:3001/health
```

**예상 응답:**
```json
{
  "status": "ok",
  "service": "auth-service",
  "timestamp": "2025-12-03T..."
}
```

### 2. 회원가입

```bash
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@doamarket.com",
    "password": "admin123!",
    "name": "Admin User",
    "role": "admin"
  }'
```

**예상 응답:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "admin@doamarket.com",
      "name": "Admin User",
      "role": "admin"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "timestamp": "2025-12-03T..."
}
```

### 3. 로그인

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@doamarket.com",
    "password": "admin123!"
  }'
```

### 4. 현재 사용자 정보 조회

```bash
# 먼저 로그인해서 accessToken을 받으세요
ACCESS_TOKEN="your-access-token-here"

curl -X GET http://localhost:3001/api/v1/auth/me \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### 5. 토큰 갱신

```bash
curl -X POST http://localhost:3001/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "your-refresh-token"
  }'
```

### 6. 로그아웃

```bash
curl -X POST http://localhost:3001/api/v1/auth/logout \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "your-refresh-token"
  }'
```

## 🔗 프론트엔드 연동

### Admin Web에서 Auth Service 연동

```bash
# Admin Web이 실행 중이어야 합니다
# http://localhost:3100

# 1. 로그인 페이지에서 회원가입한 계정으로 로그인
# 2. Auth Service가 응답하면 대시보드로 이동
```

**Admin Web 환경변수 확인:**
```env
# frontend/admin-web/.env.local
NEXT_PUBLIC_API_URL=http://localhost:3001
```

## 🗄️ 데이터베이스 확인

### PgAdmin으로 접속

1. 브라우저에서 http://localhost:5050 접속
2. 로그인:
   - Email: admin@doamarket.com
   - Password: admin
3. 서버 추가:
   - Host: postgres
   - Port: 5432
   - Username: postgres
   - Password: postgres
4. `doa_auth` 데이터베이스 확인

### psql로 직접 접속

```bash
# Docker 컨테이너 접속
docker exec -it doa-postgres psql -U postgres -d doa_auth

# 테이블 확인
\dt

# Users 테이블 조회
SELECT id, email, name, role, status, created_at FROM users;

# Refresh Tokens 테이블 조회
SELECT id, user_id, expires_at FROM refresh_tokens;
```

## 📊 성능 테스트 (선택사항)

### Apache Bench로 부하 테스트

```bash
# 100개의 요청을 동시에 10개씩
ab -n 100 -c 10 \
  -H "Content-Type: application/json" \
  -p login-data.json \
  http://localhost:3001/api/v1/auth/login
```

### Artillery로 부하 테스트

```bash
npm install -g artillery

artillery quick --count 10 --num 20 \
  http://localhost:3001/health
```

## 🛠️ 문제 해결

### 서비스가 시작되지 않음

```bash
# 로그 확인
docker-compose logs auth-service

# 컨테이너 재시작
docker-compose restart auth-service

# 완전히 재구축
docker-compose down
docker-compose up --build -d
```

### 데이터베이스 연결 실패

```bash
# PostgreSQL 상태 확인
docker-compose ps postgres

# PostgreSQL 로그 확인
docker-compose logs postgres

# 데이터베이스 재시작
docker-compose restart postgres
```

### 포트 충돌

```bash
# 사용 중인 포트 확인
lsof -i :3001

# docker-compose.yml에서 포트 변경
# 예: "3001:3001" -> "3101:3001"
```

## ✅ 체크리스트

프론트엔드와 백엔드가 정상적으로 연동되었는지 확인:

- [ ] Docker Compose가 실행 중
- [ ] Auth Service Health Check 성공
- [ ] 회원가입 API 테스트 성공
- [ ] 로그인 API 테스트 성공
- [ ] JWT 토큰 발급 확인
- [ ] 단위 테스트 모두 통과
- [ ] Admin Web 로그인 페이지 접속
- [ ] Admin Web에서 회원가입/로그인 성공
- [ ] PostgreSQL 데이터 저장 확인

## 📚 다음 단계

1. **User Service 구현** - 사용자 프로필, 주소 관리
2. **Product Service 구현** - 상품 CRUD, 카테고리
3. **Order Service 구현** - 주문 생성, 상태 관리
4. **Event Bus 연동** - EventBridge 또는 RabbitMQ
5. **API Gateway 추가** - Kong 또는 AWS API Gateway
6. **CI/CD 파이프라인** - GitHub Actions

## 🎯 성공!

모든 체크리스트를 완료했다면, 백엔드 개발 환경이 성공적으로 구축되었습니다! 🎉

이제 Admin Web (http://localhost:3100)에서 로그인하면 Auth Service (http://localhost:3001)와 통신하여 인증이 처리됩니다.

---

**작성일**: 2025-12-03
**버전**: 1.0.0

