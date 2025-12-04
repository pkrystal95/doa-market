# 🚀 DOA Market - 빠른 시작 가이드

## 1. Docker Desktop 실행 확인

먼저 **Docker Desktop**이 실행 중인지 확인하세요.

```bash
docker --version
```

---

## 2. 서비스 실행 (2가지 방법)

### 방법 A: 로컬 실행 (권장 ⭐)

더 빠르고, 로그 확인이 편하고, 디버깅이 쉽습니다.

#### Terminal 1: PostgreSQL & Redis

```bash
cd /Users/krystal/workspace/doa-market
docker-compose up -d postgres redis pgadmin

# 초기화 대기 (10초)
sleep 10
```

#### Terminal 2: Auth Service

```bash
cd /Users/krystal/workspace/doa-market/backend/auth-service
npm install
npm run dev
```

서비스가 시작되면:
- **Health Check**: http://localhost:3001/health
- **API 문서**: http://localhost:3001/api-docs

#### Terminal 3: User Service (선택)

```bash
cd /Users/krystal/workspace/doa-market/backend/user-service
npm install
npm run dev
```

- **Health Check**: http://localhost:3002/health
- **API 문서**: http://localhost:3002/api-docs

#### Terminal 4: Product Service (선택)

```bash
cd /Users/krystal/workspace/doa-market/backend/product-service
npm install
npm run dev
```

- **Health Check**: http://localhost:3003/health
- **API 문서**: http://localhost:3003/api-docs

#### Terminal 5: Order Service (선택)

```bash
cd /Users/krystal/workspace/doa-market/backend/order-service
npm install
npm run dev
```

- **Health Check**: http://localhost:3004/health
- **API 문서**: http://localhost:3004/api-docs

---

### 방법 B: Docker Compose로 일괄 실행

```bash
cd /Users/krystal/workspace/doa-market

# PostgreSQL & Redis 먼저 실행
docker-compose up -d postgres redis

# 10초 대기 (데이터베이스 초기화)
sleep 10

# 주요 서비스 실행
docker-compose up -d auth-service user-service product-service order-service

# 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f auth-service
```

---

## 3. Swagger API 문서 접속

### Auth Service ⭐

```
http://localhost:3001/api-docs
```

**주요 API:**
- `POST /api/v1/auth/register` - 회원가입
- `POST /api/v1/auth/login` - 로그인
- `GET /api/v1/auth/me` - 사용자 정보 (인증 필요)

### User Service

```
http://localhost:3002/api-docs
```

### Product Service

```
http://localhost:3003/api-docs
```

### Order Service

```
http://localhost:3004/api-docs
```

### Payment Service

```
http://localhost:3005/api-docs
```

### Shipping Service

```
http://localhost:3006/api-docs
```

---

## 4. API 테스트 (Swagger UI 사용)

### Step 1: 회원가입

1. http://localhost:3001/api-docs 접속
2. `POST /api/v1/auth/register` 클릭
3. "Try it out" 버튼 클릭
4. Request Body 입력:

```json
{
  "email": "test@test.com",
  "password": "password123",
  "name": "홍길동"
}
```

5. "Execute" 클릭
6. Response에서 `accessToken` 복사

### Step 2: 인증 설정

1. 페이지 상단 **"Authorize"** 버튼 클릭
2. Value 입력: `Bearer <복사한토큰>`
3. "Authorize" 클릭
4. "Close" 클릭

### Step 3: 사용자 정보 조회

1. `GET /api/v1/auth/me` 클릭
2. "Try it out" 클릭
3. "Execute" 클릭
4. 사용자 정보 확인 ✅

---

## 5. curl로 API 테스트

### 회원가입

```bash
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "password123",
    "name": "홍길동"
  }' | jq
```

### 로그인

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "password123"
  }' | jq
```

### 토큰 저장

```bash
TOKEN=$(curl -s -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}' \
  | jq -r '.data.accessToken')

echo $TOKEN
```

### 사용자 정보 조회

```bash
curl -X GET http://localhost:3001/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq
```

---

## 6. Health Check

### 개별 확인

```bash
curl http://localhost:3001/health | jq
curl http://localhost:3002/health | jq
curl http://localhost:3003/health | jq
curl http://localhost:3004/health | jq
```

### 전체 확인 (스크립트)

```bash
#!/bin/bash
echo "=== Service Health Check ==="
for port in 3001 3002 3003 3004 3005 3006; do
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
cat > check-services.sh << 'EOF'
#!/bin/bash
echo "=== Service Health Check ==="
for port in 3001 3002 3003 3004 3005 3006; do
  echo -n "Port $port: "
  STATUS=$(curl -s http://localhost:$port/health 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "$STATUS" | jq -r '.service + " - " + .status'
  else
    echo "❌ DOWN"
  fi
done
EOF

chmod +x check-services.sh
./check-services.sh
```

---

## 7. PgAdmin으로 데이터베이스 확인

```
URL: http://localhost:5050
Email: admin@doamarket.com
Password: admin
```

**서버 추가:**
1. Add New Server
2. **General** > Name: `DOA Market`
3. **Connection**:
   - Host: `postgres` (Docker 네트워크 사용 시) 또는 `localhost`
   - Port: `5432`
   - Username: `postgres`
   - Password: `postgres`

---

## 8. 로그 확인

### Docker Compose 사용 시

```bash
# 전체 로그
docker-compose logs -f

# 특정 서비스
docker-compose logs -f auth-service

# 에러만
docker-compose logs | grep ERROR

# 최근 100줄
docker-compose logs --tail=100
```

### 로컬 실행 시

각 터미널에서 실시간으로 로그를 확인할 수 있습니다.

---

## 9. 서비스 중지

### 로컬 실행 시

각 터미널에서 `Ctrl + C`

### Docker Compose 사용 시

```bash
# 전체 중지
docker-compose down

# 특정 서비스만 중지
docker-compose stop auth-service

# 볼륨까지 삭제 (데이터베이스 초기화)
docker-compose down -v
```

---

## 10. 문제 해결

### PostgreSQL 연결 오류

```bash
# PostgreSQL 재시작
docker-compose restart postgres

# 로그 확인
docker-compose logs postgres

# 직접 접속 테스트
docker exec -it doa-postgres psql -U postgres -c "\l"
```

### 포트 충돌

```bash
# 사용 중인 프로세스 확인
lsof -i :3001

# 프로세스 종료
kill -9 <PID>
```

### npm install 오류

```bash
# 캐시 삭제 후 재설치
cd backend/auth-service
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

---

## 📚 추가 자료

- **상세 API 테스트 가이드**: `API_TESTING_GUIDE.md`
- **백엔드 README**: `backend/README.md`
- **전체 서비스 가이드**: `SERVICES_GUIDE.md`

---

## 🎯 권장 실행 순서

1. ✅ Docker Desktop 실행
2. ✅ PostgreSQL & Redis 실행 (`docker-compose up -d postgres redis`)
3. ✅ Auth Service 실행 (로컬 또는 Docker)
4. ✅ Swagger 접속 (http://localhost:3001/api-docs)
5. ✅ 회원가입 & 로그인 테스트
6. ✅ 다른 서비스 실행 (필요 시)

---

**최종 업데이트**: 2025-12-04  
**버전**: 1.0.0

🎉 **Happy Coding!**

