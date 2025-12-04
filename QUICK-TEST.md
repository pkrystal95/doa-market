# 빠른 테스트 가이드

현재 Product Service가 거의 완성되었습니다! 몇 가지 설정 문제만 해결하면 바로 테스트할 수 있습니다.

## 현재 상태

✅ 의존성 설치 완료  
✅ TypeScript 컴파일 에러 해결  
✅ PostgreSQL & Redis 실행 중  
⚠️ 데이터베이스 연결 설정 조정 필요

## 빠른 시작 (3단계)

### 1단계: 데이터베이스 확인

```bash
# PostgreSQL이 실행 중인지 확인
docker-compose ps

# 데이터베이스 생성 확인
docker exec doa-postgres psql -U postgres -l | grep doa_products
```

### 2단계: 서버 시작

```bash
cd /Users/krystal/workspace/doa-market/backend/services/product-service

# 간단한 방법: 시작 스크립트 사용
../../start-product-service.sh

# 또는 수동으로:
npm run dev
```

### 3단계: API 테스트

서버가 시작되면 (약 3-5초 소요):

```bash
# Health Check
curl http://localhost:3003/api/v1/health

# 예상 응답:
# {"status":"ok","timestamp":"2024-12-04T...","service":"product-service"}
```

## 주요 해결해야 할 문제

현재 다음 설정들이 서로 맞지 않습니다:

1. **PostgreSQL 패스워드**: Docker는 패스워드 없음, 코드는 패스워드 요구
2. **Redis 패스워드**: Docker는 패스워드 없음, 코드는 패스워드 요구  
3. **TypeORM 설정**: 데이터베이스 연결 설정 필요

## 해결 방법

### 방법 1: .env 파일 수정 (권장)

```bash
cd backend/services/product-service

# .env 파일에서 다음 값들을 비워두기:
DB_PASSWORD=
REDIS_PASSWORD=
```

### 방법 2: Docker 재시작 with 패스워드

```bash
# docker-compose.yml에서 패스워드 설정이 있는지 확인하고
# 컨테이너 재시작
docker-compose down
docker-compose up -d postgres redis
```

## 다음 단계

서버가 성공적으로 시작되면:

```bash
# 전체 API 테스트 실행
./test-api.sh

# 또는 수동으로 테스트
curl http://localhost:3003/api/v1/products
curl http://localhost:3003/api/v1/categories
```

## 문제 해결

### 서버가 시작되지 않는 경우:

1. **로그 확인**:
   ```bash
   # Docker 로그
   docker-compose logs postgres
   docker-compose logs redis
   
   # 애플리케이션 로그는 터미널에 표시됩니다
   ```

2. **포트 충돌**:
   ```bash
   # 3003 포트가 사용 중인지 확인
   lsof -i :3003
   
   # 사용 중이면 프로세스 종료
   kill -9 <PID>
   ```

3. **노드 모듈 재설치**:
   ```bash
   rm -rf node_modules
   npm install
   ```

## 완전히 새로 시작

모든 것을 리셋하고 처음부터:

```bash
# 1. Docker 컨테이너 중지 및 삭제
docker-compose down -v

# 2. Docker 컨테이너 재시작
docker-compose up -d postgres redis

# 3. 데이터베이스 생성 대기 (10초)
sleep 10

# 4. 서비스 시작
cd backend/services/product-service
npm run dev
```

## 도움말

더 자세한 정보는 `QUICKSTART.md` 파일을 참고하세요!
