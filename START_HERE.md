# 🚀 DOA Market - 바로 시작하기

## 1️⃣ Docker Desktop 실행 (필수!)

### macOS에서 실행:

**방법 1: 터미널에서**
```bash
open -a Docker
```

**방법 2: Finder에서**
- Applications 폴더 열기
- Docker 아이콘 더블클릭

**✅ 확인 방법:**
- 상단 메뉴바에 Docker 고래 아이콘이 보이면 OK!
- Docker Desktop 창이 열리면 "Engine running" 확인

⏳ **20-30초 기다려주세요** (Docker가 완전히 시작될 때까지)

---

## 2️⃣ PostgreSQL & Redis 실행

### 터미널 1번 창:

```bash
# 프로젝트 디렉토리로 이동
cd /Users/krystal/workspace/doa-market

# Docker 상태 확인
docker ps

# PostgreSQL & Redis 실행
docker-compose up -d postgres redis pgadmin

# 10초 대기 (데이터베이스 초기화)
echo "⏳ 데이터베이스 초기화 중..."
sleep 10

# 실행 확인
docker-compose ps
```

**✅ 성공 확인:**
```
NAME                STATUS
doa-postgres        Up
doa-redis           Up
doa-pgadmin         Up
```

---

## 3️⃣ Auth Service 실행

### 터미널 2번 창 (새 터미널):

```bash
# Auth Service로 이동
cd /Users/krystal/workspace/doa-market/backend/auth-service

# 패키지 설치 (최초 1회만)
npm install

# 서비스 실행
npm run dev
```

**✅ 성공 확인:**

터미널에 이런 메시지가 나오면 성공!
```
Auth Service running on port 3001
API available at http://localhost:3001/api/v1
```

---

## 4️⃣ 브라우저로 접속

### 다음 URL들을 브라우저에서 열어보세요:

#### Health Check (서비스 정상 동작 확인)
```
http://localhost:3001/health
```

**예상 결과:**
```json
{
  "status": "ok",
  "service": "auth-service",
  "timestamp": "2025-12-04T..."
}
```

#### Swagger API 문서 (메인!)
```
http://localhost:3001/api-docs
```

**보여야 할 화면:**
- Swagger UI 인터페이스
- "DOA Market - Auth Service API" 제목
- API 엔드포인트 목록

---

## 5️⃣ API 테스트 (Swagger에서)

### 회원가입 테스트:

1. **`POST /api/v1/auth/register`** 클릭
2. **"Try it out"** 버튼 클릭
3. Request body 입력:
```json
{
  "email": "test@test.com",
  "password": "password123",
  "name": "홍길동"
}
```
4. **"Execute"** 버튼 클릭
5. Response 확인! ✅

### 로그인 테스트:

1. **`POST /api/v1/auth/login`** 클릭
2. **"Try it out"** 클릭
3. Request body 입력:
```json
{
  "email": "test@test.com",
  "password": "password123"
}
```
4. **"Execute"** 클릭
5. Response에서 **`accessToken`** 복사

### 인증 설정:

1. 페이지 상단 **"Authorize" 🔓** 버튼 클릭
2. Value에 입력: `Bearer <복사한토큰>`
3. **"Authorize"** 클릭
4. **"Close"** 클릭

### 사용자 정보 조회:

1. **`GET /api/v1/auth/me`** 클릭
2. **"Try it out"** 클릭
3. **"Execute"** 클릭
4. 사용자 정보 확인! ✅

---

## 🔍 문제 해결

### 브라우저가 안 열린다면?

1. **터미널에서 확인:**
```bash
curl http://localhost:3001/health
```

2. **에러가 나온다면:**
   - Auth Service가 실행 중인지 확인
   - 터미널 2번 창에서 `npm run dev` 실행 확인
   - 에러 메시지 확인

3. **포트 충돌 확인:**
```bash
lsof -i :3001
```

### Docker 관련 문제:

```bash
# Docker 상태 확인
docker ps

# Docker 재시작
docker-compose restart postgres redis

# 전체 재시작
docker-compose down
docker-compose up -d postgres redis
```

### Auth Service 재시작:

터미널 2번 창에서:
1. `Ctrl + C` (중지)
2. `npm run dev` (재실행)

---

## 📱 추가 서비스 실행 (선택)

### User Service:

**터미널 3번 창:**
```bash
cd /Users/krystal/workspace/doa-market/backend/user-service
npm install
npm run dev
```

접속: http://localhost:3002/api-docs

### Product Service:

**터미널 4번 창:**
```bash
cd /Users/krystal/workspace/doa-market/backend/product-service
npm install
npm run dev
```

접속: http://localhost:3003/api-docs

---

## ✅ 체크리스트

- [ ] Docker Desktop 실행 확인
- [ ] PostgreSQL & Redis 실행 (`docker-compose ps`)
- [ ] Auth Service 실행 (`npm run dev`)
- [ ] Health Check 확인 (http://localhost:3001/health)
- [ ] Swagger 접속 (http://localhost:3001/api-docs)
- [ ] 회원가입 테스트
- [ ] 로그인 테스트
- [ ] 사용자 정보 조회 테스트

---

## 🆘 여전히 안 된다면?

터미널에서 다음 명령어를 실행하고 결과를 보여주세요:

```bash
# Docker 확인
docker ps

# Auth Service 로그 확인
cd /Users/krystal/workspace/doa-market/backend/auth-service
npm run dev

# 네트워크 확인
curl http://localhost:3001/health
```

---

**도움이 필요하면 언제든 물어보세요!** 🙋‍♂️

