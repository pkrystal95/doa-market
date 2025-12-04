# 현재 실행 중인 Product Service API

## 서버 정보
- **URL**: http://localhost:3003
- **버전**: 1.0.0
- **상태**: ✅ 실행 중
- **데이터베이스**: PostgreSQL (doa_products)

## 사용 가능한 엔드포인트

### 1. Root Endpoint
서비스 정보 및 사용 가능한 엔드포인트 목록 확인

**요청**
```bash
curl http://localhost:3003/
```

**응답**
```json
{
  "service": "DOA Market - Product Service",
  "version": "1.0.0",
  "endpoints": {
    "health": "/api/v1/health",
    "products": "/api/v1/products"
  }
}
```

---

### 2. Health Check
서비스 및 데이터베이스 연결 상태 확인

**요청**
```bash
curl http://localhost:3003/api/v1/health
```

**응답**
```json
{
  "status": "ok",
  "timestamp": "2025-12-04T09:39:00.422Z",
  "service": "product-service",
  "database": "connected"
}
```

**응답 필드**
- `status`: 서비스 상태 (ok/error)
- `timestamp`: 응답 시각 (ISO 8601)
- `service`: 서비스 이름
- `database`: 데이터베이스 연결 상태 (connected/disconnected)

---

### 3. Products - Database Connection Test
PostgreSQL 데이터베이스 연결 및 쿼리 테스트

**요청**
```bash
curl http://localhost:3003/api/v1/products
```

**응답**
```json
{
  "success": true,
  "message": "Database connection successful!",
  "data": [
    {
      "current_database": "doa_products",
      "current_user": "postgres",
      "version": "PostgreSQL 15.15 on aarch64-unknown-linux-musl, compiled by gcc (Alpine 14.2.0) 14.2.0, 64-bit"
    }
  ],
  "timestamp": "2025-12-04T09:39:01.111Z"
}
```

**응답 필드**
- `success`: 요청 성공 여부
- `message`: 메시지
- `data`: 데이터베이스 정보 배열
  - `current_database`: 현재 연결된 데이터베이스명
  - `current_user`: 현재 사용자
  - `version`: PostgreSQL 버전 정보
- `timestamp`: 응답 시각

---

## 에러 응답 형식

### 500 Internal Server Error
데이터베이스 연결 실패 등의 서버 오류

```json
{
  "success": false,
  "error": "에러 메시지"
}
```

---

## 빠른 테스트 명령어

### 모든 엔드포인트 테스트
```bash
# 1. Root
curl http://localhost:3003/

# 2. Health Check
curl http://localhost:3003/api/v1/health

# 3. Products
curl http://localhost:3003/api/v1/products
```

### 상세 응답 확인 (with jq)
```bash
# JSON 예쁘게 출력
curl http://localhost:3003/api/v1/health | jq .

# 특정 필드만 추출
curl http://localhost:3003/api/v1/health | jq .status

# 데이터베이스 버전 확인
curl http://localhost:3003/api/v1/products | jq '.data[0].version'
```

### HTTP 상태 코드 확인
```bash
curl -i http://localhost:3003/api/v1/health
```

### 응답 시간 측정
```bash
curl -w "\nTime: %{time_total}s\n" http://localhost:3003/api/v1/health
```

---

## 다음 단계: 전체 TypeScript 서비스

현재는 간단한 테스트 서버가 실행 중입니다. 전체 기능을 사용하려면:

1. **Import 경로 문제 수정**
   ```bash
   cd /Users/krystal/workspace/doa-market
   ./fix-and-start.sh
   ```

2. **TypeScript 서비스 시작**
   ```bash
   cd backend/services/product-service
   npm run dev
   ```

3. **전체 API 테스트**
   ```bash
   # 자동 테스트 스크립트 실행
   /Users/krystal/workspace/doa-market/test-api.sh
   ```

---

## 전체 API 문서

더 자세한 API 설계는 다음 문서를 참고하세요:
- **API 설계 문서**: `docs/04-api-design.md`
- **Postman Collection**: `docs/api/postman-collection.json`

### Postman 사용 방법
1. Postman 실행
2. Import → File 선택
3. `docs/api/postman-collection.json` 파일 선택
4. Collection에서 요청 실행

---

## 인프라 정보

### PostgreSQL
- Host: localhost
- Port: 5432
- Database: doa_products
- User: postgres
- Password: postgres

### Redis (선택적)
- Host: localhost
- Port: 6379
- 현재 비활성화 (CACHE_ENABLED=false)

### Docker Containers
```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs postgres
docker-compose logs redis
```

---

## 문제 해결

### 서버에 연결할 수 없는 경우
1. **서버 실행 확인**
   ```bash
   lsof -i :3003
   ```

2. **Docker 서비스 확인**
   ```bash
   docker-compose ps
   ```

3. **서버 재시작**
   ```bash
   cd /Users/krystal/workspace/doa-market/backend/services/product-service
   node test-server.js
   ```

### 데이터베이스 연결 오류
1. **PostgreSQL 상태 확인**
   ```bash
   docker exec doa-postgres psql -U postgres -c "SELECT 1"
   ```

2. **데이터베이스 존재 확인**
   ```bash
   docker exec doa-postgres psql -U postgres -l | grep doa_products
   ```

---

**마지막 업데이트**: 2025-12-04
**테스트 완료**: ✅ 모든 엔드포인트 정상 작동
