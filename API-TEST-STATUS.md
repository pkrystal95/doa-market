# DOA Market API - 테스트 상태

## 서버 상태

✅ **Product Service 실행 중**
- URL: http://localhost:3003
- 포트: 3003
- 데이터베이스: PostgreSQL (doa_products)
- 상태: 정상 동작

## 사용 가능한 엔드포인트

### 1. Health Check
```
GET http://localhost:3003/api/v1/health
```
**상태**: ✅ 작동
**응답 예시**:
```json
{
  "success": true,
  "data": {
    "service": "product-service",
    "status": "healthy",
    "timestamp": "2025-12-04T10:01:11.409Z",
    "uptime": 33.346257041
  }
}
```

### 2. Get All Products (페이지네이션)
```
GET http://localhost:3003/api/v1/products?page=1&limit=10
```
**상태**: ✅ 작동
**쿼리 파라미터**:
- `page`: 페이지 번호 (기본값: 1)
- `limit`: 페이지당 항목 수 (기본값: 20, 최대: 100)
- `sort`: 정렬 (예: `createdAt:DESC`, `price:ASC`)

**응답 예시**:
```json
{
  "success": true,
  "data": [],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 0,
    "totalPages": 0
  },
  "timestamp": "2025-12-04T10:01:11.880Z"
}
```

### 3. Search Products
```
GET http://localhost:3003/api/v1/products/search?q=검색어&page=1&limit=10
```
**상태**: ✅ 작동 (검증 있음)
**쿼리 파라미터**:
- `q`: 검색어 (필수)
- `page`: 페이지 번호
- `limit`: 페이지당 항목 수

### 4. Get Products by Category
```
GET http://localhost:3003/api/v1/products/category/:categoryId
```
**상태**: ⚠️ 구현됨 (카테고리 데이터 필요)

### 5. Get Products by Seller
```
GET http://localhost:3003/api/v1/products/seller/:sellerId
```
**상태**: ⚠️ 구현됨 (판매자 데이터 필요)

### 6. Get Product by ID
```
GET http://localhost:3003/api/v1/products/:id
```
**상태**: ✅ 구현됨

### 7. Get Product by Slug
```
GET http://localhost:3003/api/v1/products/slug/:slug
```
**상태**: ✅ 구현됨

## 인증이 필요한 엔드포인트

다음 엔드포인트들은 JWT 인증 토큰이 필요합니다:

### 8. Create Product
```
POST http://localhost:3003/api/v1/products
Authorization: Bearer {access_token}
Content-Type: application/json
```
**권한**: admin, seller
**상태**: ✅ 구현됨

### 9. Update Product
```
PUT http://localhost:3003/api/v1/products/:id
Authorization: Bearer {access_token}
Content-Type: application/json
```
**권한**: admin, seller (소유자만)
**상태**: ✅ 구현됨

### 10. Update Product Status
```
PATCH http://localhost:3003/api/v1/products/:id/status
Authorization: Bearer {access_token}
Content-Type: application/json
```
**권한**: admin, seller (소유자만)
**상태**: ✅ 구현됨

### 11. Delete Product
```
DELETE http://localhost:3003/api/v1/products/:id
Authorization: Bearer {access_token}
```
**권한**: admin, seller (소유자만)
**상태**: ✅ 구현됨

## Postman으로 테스트하기

### 방법 1: Postman Collection 가져오기

1. **Postman 앱 실행**

2. **Collection Import**
   ```
   파일 위치: /Users/krystal/workspace/doa-market/docs/api/postman-collection.json
   ```

3. **Import 단계**:
   - Postman에서 "Import" 버튼 클릭
   - "Choose Files" 선택
   - `postman-collection.json` 파일 선택
   - "Import" 클릭

4. **환경 변수 확인**:
   - Collection 우클릭 → "Edit"
   - "Variables" 탭 선택
   - `base_url`: `http://localhost:3003` (이미 설정됨)
   - `auth_url`: `http://localhost:3001` (Auth Service용)

### 방법 2: 직접 요청 만들기

#### 기본 테스트 순서:

1. **Health Check 테스트**
   ```
   GET http://localhost:3003/api/v1/health
   ```
   → 서버 연결 확인

2. **Get All Products 테스트**
   ```
   GET http://localhost:3003/api/v1/products?page=1&limit=10
   ```
   → 빈 배열 반환 확인 (아직 상품 없음)

3. **Search Products 테스트**
   ```
   GET http://localhost:3003/api/v1/products/search?q=test&page=1&limit=10
   ```
   → 검색 기능 확인

## 현재 제한사항

❌ **Auth Service 미실행**
- 로그인/회원가입 불가
- 인증이 필요한 엔드포인트 테스트 불가 (Create, Update, Delete)
- 해결: Auth Service 시작 필요
  ```bash
  cd backend/services/auth-service
  npm run dev
  ```

❌ **Categories API 미구현**
- `/api/v1/categories` 엔드포인트 없음
- 카테고리 CRUD 기능 없음

⚠️ **테스트 데이터 없음**
- 상품 데이터베이스 비어있음
- Auth Service 없어서 상품 생성 불가

## 다음 단계

### 즉시 테스트 가능:
1. ✅ Postman으로 Health Check 테스트
2. ✅ Postman으로 Get All Products 테스트
3. ✅ Postman으로 Search 테스트

### Auth Service 시작 후 가능:
1. 사용자 등록 및 로그인
2. JWT 토큰 획득
3. 상품 생성 (Create Product)
4. 상품 수정/삭제 테스트

### 추가 구현 필요:
1. Categories API 구현
2. Auth Service 구현 및 시작

## Postman 테스트 가이드

자세한 Postman 사용 방법은 다음 파일을 참고하세요:
- `POSTMAN-GUIDE.md`: 완전한 Postman 사용 가이드
- `test-with-curl.sh`: cURL 기반 빠른 테스트 스크립트

## 빠른 테스트 명령어

```bash
# Health Check
curl http://localhost:3003/api/v1/health | jq .

# Get All Products
curl "http://localhost:3003/api/v1/products?page=1&limit=10" | jq .

# Search Products
curl "http://localhost:3003/api/v1/products/search?q=test" | jq .

# 전체 테스트 스크립트 실행
bash test-with-curl.sh
```

---

**마지막 업데이트**: 2025-12-04
**서버 상태**: ✅ 정상 실행 중
**테스트 가능**: Postman, cURL, 브라우저
