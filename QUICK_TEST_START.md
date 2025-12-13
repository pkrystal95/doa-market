# 🚀 빠른 테스트 시작 가이드

DOA Market 프로젝트의 전체 테스트 시스템을 빠르게 시작하는 방법입니다.

## ⚡ 빠른 시작 (3단계)

### 1️⃣ 전체 시스템 실행

```bash
npm run start:all
```

또는

```bash
./scripts/start-all-services.sh
```

이 명령어는 다음을 자동으로 수행합니다:
- ✅ 인프라 서비스 시작 (PostgreSQL, Redis, RabbitMQ, OpenSearch, LocalStack)
- ✅ 백엔드 서비스 시작 (API Gateway, Auth, User, Product, Order, Payment)
- ✅ 서비스 Health Check

### 2️⃣ 전체 테스트 실행

```bash
npm test
```

또는

```bash
./scripts/run-all-tests.sh
```

이 명령어는 다음을 순차적으로 실행합니다:
1. 🧪 **단위 테스트** - 모든 서비스의 개별 기능 테스트
2. 🔗 **통합 테스트** - API 엔드포인트 통합 테스트
3. 🎭 **E2E 테스트** - 전체 시스템 End-to-End 테스트

### 3️⃣ 결과 확인

테스트 결과는 다음 디렉토리에서 확인할 수 있습니다:
- `test-results/unit/` - 단위 테스트 결과
- `test-results/integration/` - 통합 테스트 결과
- `test-results/e2e/` - E2E 테스트 결과

---

## 📋 개별 테스트 실행

### 단위 테스트만 실행

```bash
npm run test:unit
```

### 통합 테스트만 실행

```bash
npm run test:integration
```

### E2E 테스트만 실행

```bash
npm run test:e2e
```

---

## 🛑 서비스 중지

```bash
npm run stop:all
```

또는

```bash
./scripts/stop-all-services.sh
```

---

## 📚 상세 가이드

더 자세한 내용은 [TESTING_GUIDE.md](./TESTING_GUIDE.md)를 참조하세요.

---

## ⚠️ 문제 해결

### 서비스가 시작되지 않음

```bash
# 포트 확인
lsof -i :3000
lsof -i :3001

# Docker 확인
docker ps
docker-compose ps
```

### 테스트 실패

```bash
# 로그 확인
cat test-results/unit/<service-name>.log
cat test-results/integration/integration.log
cat test-results/e2e/e2e.log
```

---

**Happy Testing! 🎉**

