# Postman Collection 사용 가이드

## Collection 정보

- **이름**: DOA Market API Collection
- **파일**: `/Users/krystal/workspace/doa-market/docs/api/postman-collection.json`
- **포함된 API**: 16개 엔드포인트

## API 그룹

### 1. Authentication (4개)
- Register User
- Login
- Refresh Token
- Logout

### 2. Products (9개)
- Health Check
- Get All Products
- Get Product by ID
- Create Product
- Update Product
- Delete Product
- Search Products
- Get Products by Category
- Get Products by Seller

### 3. Categories (3개)
- Get All Categories
- Get Category by ID
- Create Category

---

## 방법 1: Postman 앱 사용

### 설치
```bash
# macOS
brew install --cask postman

# 또는 다운로드
open https://www.postman.com/downloads/
```

### Import 단계

1. **Postman 실행**

2. **Import**
   - 좌측 상단 "Import" 버튼 클릭
   - "Choose Files" 선택
   - 파일 선택: `/Users/krystal/workspace/doa-market/docs/api/postman-collection.json`
   - "Import" 클릭

3. **Collection 확인**
   - 좌측 사이드바에 "DOA Market API Collection" 표시됨
   - 클릭하여 폴더 확장

4. **환경 변수 설정**
   - Collection 우클릭 → "Edit"
   - "Variables" 탭 선택
   - 변수 확인/수정:
     - `base_url`: `http://localhost:3003`
     - `auth_url`: `http://localhost:3001`

5. **첫 번째 요청 실행**
   - "Products" → "Health Check" 선택
   - "Send" 버튼 클릭
   - 하단에 응답 확인

### 인증 흐름

**Step 1: 사용자 등록** (선택적)
```
Authentication → Register User → Send
```

**Step 2: 로그인**
```
Authentication → Login → Send
```
- 자동으로 `access_token`이 환경 변수에 저장됨

**Step 3: 인증이 필요한 API 호출**
```
Products → Create Product → Send
```
- Authorization 헤더가 자동으로 추가됨

---

## 방법 2: Newman (CLI)

### 설치
```bash
npm install -g newman
```

### 전체 Collection 실행
```bash
newman run /Users/krystal/workspace/doa-market/docs/api/postman-collection.json \
  --env-var "base_url=http://localhost:3003" \
  --env-var "auth_url=http://localhost:3001"
```

### 특정 폴더만 실행
```bash
# Products 폴더만 실행
newman run docs/api/postman-collection.json \
  --folder "Products" \
  --env-var "base_url=http://localhost:3003"
```

### 리포트 생성
```bash
newman run docs/api/postman-collection.json \
  --env-var "base_url=http://localhost:3003" \
  --reporters cli,json \
  --reporter-json-export report.json
```

---

## 방법 3: VS Code Extension

### Thunder Client 설치
```
1. VS Code 열기
2. Extensions (Cmd+Shift+X)
3. "Thunder Client" 검색 및 설치
4. Import → Postman Collection 선택
5. 파일 선택: docs/api/postman-collection.json
```

### REST Client 사용
VS Code에서 `.http` 파일 생성:

```http
### Health Check
GET http://localhost:3003/api/v1/health

### Get Products
GET http://localhost:3003/api/v1/products

### Login
POST http://localhost:3001/api/v1/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "Password123!"
}
```

---

## 환경 변수 설정

Collection에 정의된 변수들:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `base_url` | `http://localhost:3003` | Product Service URL |
| `auth_url` | `http://localhost:3001` | Auth Service URL |
| `access_token` | (비어있음) | 로그인 후 자동 설정 |
| `refresh_token` | (비어있음) | 로그인 후 자동 설정 |

### Postman에서 변수 수정

**방법 1: Collection 레벨**
```
Collection 우클릭 → Edit → Variables 탭
```

**방법 2: Environment 생성** (추천)
```
1. 좌측 "Environments" 클릭
2. "+" 버튼으로 새 Environment 생성
3. 이름: "Local Development"
4. 변수 추가:
   - base_url: http://localhost:3003
   - auth_url: http://localhost:3001
5. 우측 상단에서 Environment 선택
```

---

## 자동 토큰 관리

Collection에는 자동 토큰 관리 스크립트가 포함되어 있습니다:

### Register/Login 후 자동 토큰 저장
```javascript
// Tests 탭에 포함된 스크립트
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.environment.set('access_token', response.data.accessToken);
    pm.environment.set('refresh_token', response.data.refreshToken);
}
```

### Authorization 헤더 자동 추가
인증이 필요한 요청의 Headers:
```
Authorization: Bearer {{access_token}}
```

---

## 빠른 테스트 시나리오

### 시나리오 1: 기본 연결 확인
```
1. Products → Health Check
2. 예상 응답: 200 OK
```

### 시나리오 2: 상품 조회
```
1. Products → Get All Products
2. 쿼리 파라미터 수정 (선택):
   - page: 1
   - limit: 20
   - sort: createdAt:DESC
```

### 시나리오 3: 인증 및 상품 생성
```
1. Authentication → Login
   - 토큰 자동 저장 확인
2. Products → Create Product
   - Body에서 상품 정보 수정
   - Send
3. Products → Get All Products
   - 생성된 상품 확인
```

### 시나리오 4: 검색
```
1. Products → Search Products
2. Query params:
   - q: 검색어 (예: "headphones")
   - page: 1
   - limit: 20
```

---

## 문제 해결

### 1. "Could not get response"
**원인**: 서버가 실행되지 않음
**해결**:
```bash
# 서버 상태 확인
lsof -i :3003

# 서버 시작
cd /Users/krystal/workspace/doa-market/backend/services/product-service
node test-server.js
```

### 2. "401 Unauthorized"
**원인**: 인증 토큰이 없거나 만료됨
**해결**:
```
1. Authentication → Login 다시 실행
2. access_token 변수 확인
3. 보호된 엔드포인트 재시도
```

### 3. "404 Not Found"
**원인**: 엔드포인트가 구현되지 않음
**해결**:
```
- 현재는 테스트 서버만 실행 중
- 전체 TypeScript 서비스 시작 필요:
  npm run dev
```

### 4. 변수가 적용되지 않음
**확인사항**:
```
1. 우측 상단에서 Environment 선택 확인
2. {{variable}} 형식 사용 확인
3. Collection Variables vs Environment Variables 확인
```

---

## 고급 기능

### Pre-request Scripts
요청 전 실행되는 스크립트:

```javascript
// 타임스탬프 추가
pm.environment.set('timestamp', Date.now());

// 랜덤 이메일 생성
const randomEmail = `user${Math.random().toString(36).substring(7)}@example.com`;
pm.environment.set('test_email', randomEmail);
```

### Tests Scripts
응답 후 검증:

```javascript
// 상태 코드 확인
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// JSON 응답 확인
pm.test("Response has data", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData.data).to.exist;
});

// 응답 시간 확인
pm.test("Response time is less than 200ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(200);
});
```

### Collection Runner
전체 Collection 순차 실행:

```
1. Collection 우클릭 → "Run collection"
2. 실행할 요청 선택
3. Iterations: 1 (반복 횟수)
4. "Run DOA Market API Collection" 클릭
5. 결과 확인
```

---

## 현재 서버 상태

### 실행 중인 서비스
- Product Service: http://localhost:3003 ✅
- Auth Service: http://localhost:3001 ❌ (아직 구현 안됨)

### 사용 가능한 엔드포인트
현재 테스트 서버에서 동작:
- ✅ `GET /`
- ✅ `GET /api/v1/health`
- ✅ `GET /api/v1/products` (DB 테스트)

완전한 구현이 필요한 엔드포인트:
- ⏳ 나머지 Product CRUD APIs
- ⏳ Authentication APIs
- ⏳ Category APIs

---

## 다음 단계

### 전체 서비스 실행
```bash
cd /Users/krystal/workspace/doa-market/backend/services/product-service
npm run dev
```

### 모든 API 테스트
```bash
# Collection Runner 사용
# 또는 Newman CLI
newman run docs/api/postman-collection.json
```

---

**참고 문서**:
- API 설계: `docs/04-api-design.md`
- 현재 API: `CURRENT-API.md`
- 빠른 시작: `QUICK-TEST.md`
