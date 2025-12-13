# DOA Market - 전체 테스트 가이드

이 문서는 DOA Market 프로젝트의 전체 테스트 시스템 사용 방법을 설명합니다.

## 📋 목차

1. [전체 시스템 실행](#전체-시스템-실행)
2. [단위 테스트](#단위-테스트)
3. [통합 테스트](#통합-테스트)
4. [E2E 테스트](#e2e-테스트)
5. [전체 테스트 실행](#전체-테스트-실행)
6. [문제 해결](#문제-해결)

---

## 🚀 전체 시스템 실행

### 방법 1: 스크립트 사용 (권장)

```bash
# 전체 시스템 시작
npm run start:all
# 또는
./scripts/start-all-services.sh
```

이 스크립트는 다음을 수행합니다:
- 인프라 서비스 시작 (PostgreSQL, Redis, RabbitMQ, OpenSearch, LocalStack)
- 주요 백엔드 서비스 시작 (API Gateway, Auth, User, Product, Order, Payment)
- 서비스 Health Check

### 방법 2: Docker Compose 사용

```bash
# 인프라만 시작
docker-compose up -d postgres redis rabbitmq opensearch localstack

# 백엔드 서비스는 개별적으로 실행
cd backend/api-gateway && npm run dev
cd backend/auth-service && npm run dev
# ... 기타 서비스
```

### 서비스 중지

```bash
# 모든 서비스 중지
npm run stop:all
# 또는
./scripts/stop-all-services.sh
```

---

## 🧪 단위 테스트

단위 테스트는 각 서비스의 개별 기능을 독립적으로 테스트합니다.

### 실행 방법

```bash
# 모든 서비스의 단위 테스트 실행
npm run test:unit
# 또는
./scripts/run-unit-tests.sh
```

### 테스트 범위

다음 서비스들의 단위 테스트가 실행됩니다:
- API Gateway
- Auth Service
- User Service
- Product Service
- Order Service
- Payment Service

### 결과 확인

테스트 결과는 `test-results/unit/` 디렉토리에 저장됩니다:
- 각 서비스별 로그 파일
- 커버리지 리포트 (가능한 경우)

### 개별 서비스 테스트

```bash
# 특정 서비스만 테스트
cd backend/auth-service
npm test

# Watch 모드
npm run test:watch

# 커버리지 리포트
npm run test:coverage
```

---

## 🔗 통합 테스트

통합 테스트는 실제 데이터베이스와 서비스를 사용하여 API 엔드포인트를 테스트합니다.

### 사전 요구사항

- PostgreSQL 실행 중
- Redis 실행 중 (필요한 경우)
- 서비스 실행 중 (선택적, 테스트가 자동으로 시작할 수 있음)

### 실행 방법

```bash
# 통합 테스트 실행
npm run test:integration
# 또는
./scripts/run-integration-tests.sh
```

### 테스트 구조

통합 테스트는 `tests/integration/` 디렉토리에 있습니다:
- `auth.integration.test.ts` - 인증 서비스 통합 테스트
- 추가 테스트 파일을 이 디렉토리에 추가할 수 있습니다

### 테스트 작성 예시

```typescript
import request from 'supertest';

const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:3001';

describe('Auth Service Integration Tests', () => {
  it('should register a new user', async () => {
    const response = await request(API_BASE_URL)
      .post('/api/v1/auth/register')
      .send({
        email: `test-${Date.now()}@example.com`,
        password: 'password123',
        name: 'Test User',
      });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('data');
  });
});
```

---

## 🎭 E2E 테스트

E2E 테스트는 전체 시스템을 사용하여 실제 사용자 시나리오를 테스트합니다.

### 사전 요구사항

- 모든 서비스가 실행 중이어야 합니다
- 인프라 서비스 (PostgreSQL, Redis 등) 실행 중

### 실행 방법

```bash
# E2E 테스트 실행
npm run test:e2e
# 또는
./scripts/run-e2e-tests.sh
```

### 서비스 자동 시작

E2E 테스트 실행 시 서비스가 실행 중이 아니면 자동으로 시작할 수 있습니다.

### 테스트 구조

E2E 테스트는 `tests/e2e/` 디렉토리에 있습니다:
- `specs/user-flow.spec.ts` - 사용자 플로우 테스트
- Playwright를 사용하여 API 테스트 수행

### 테스트 시나리오

현재 포함된 테스트:
1. 회원가입 → 로그인 → 상품 조회 → 주문 생성
2. 모든 서비스 Health Check

### Playwright 명령어

```bash
cd tests/e2e

# 테스트 실행
npm test

# UI 모드로 실행
npm run test:ui

# 디버그 모드
npm run test:debug

# 헤드 모드 (브라우저 표시)
npm run test:headed
```

---

## 🎯 전체 테스트 실행

모든 테스트를 순차적으로 실행합니다.

### 실행 방법

```bash
# 전체 테스트 실행 (단위 → 통합 → E2E)
npm test
# 또는
./scripts/run-all-tests.sh
```

### 실행 순서

1. **단위 테스트** - 모든 서비스의 단위 테스트 실행
2. **통합 테스트** - API 통합 테스트 실행
3. **E2E 테스트** - 전체 시스템 E2E 테스트 실행

### 결과 요약

테스트 완료 후 다음 정보가 표시됩니다:
- 각 테스트 단계의 통과/실패 여부
- 실행 시간
- 테스트 결과 디렉토리 위치

---

## 📊 테스트 결과

모든 테스트 결과는 `test-results/` 디렉토리에 저장됩니다:

```
test-results/
├── unit/              # 단위 테스트 결과
│   ├── api-gateway.log
│   ├── auth-service.log
│   └── ...
├── integration/       # 통합 테스트 결과
│   └── integration.log
└── e2e/              # E2E 테스트 결과
    ├── e2e.log
    └── playwright-report/  # Playwright HTML 리포트
```

---

## 🔧 문제 해결

### 서비스가 시작되지 않음

```bash
# 포트 충돌 확인
lsof -i :3000
lsof -i :3001

# 프로세스 종료
kill -9 <PID>

# Docker 컨테이너 확인
docker ps
docker-compose ps
```

### 데이터베이스 연결 오류

```bash
# PostgreSQL 상태 확인
docker ps | grep postgres

# PostgreSQL 재시작
docker-compose restart postgres

# 데이터베이스 직접 확인
docker exec -it doa-postgres psql -U postgres -c "\l"
```

### 테스트 실패

1. **로그 확인**
   ```bash
   # 단위 테스트 로그
   cat test-results/unit/<service-name>.log
   
   # 통합 테스트 로그
   cat test-results/integration/integration.log
   
   # E2E 테스트 로그
   cat test-results/e2e/e2e.log
   ```

2. **서비스 상태 확인**
   ```bash
   # Health Check
   curl http://localhost:3000/api/v1/health
   curl http://localhost:3001/health
   ```

3. **의존성 재설치**
   ```bash
   cd backend/<service-name>
   rm -rf node_modules package-lock.json
   npm install
   ```

### E2E 테스트 브라우저 오류

```bash
cd tests/e2e

# Playwright 브라우저 재설치
npx playwright install --with-deps chromium
```

---

## 📝 추가 테스트 작성

### 단위 테스트 추가

각 서비스의 `tests/` 또는 `src/__tests__/` 디렉토리에 테스트 파일을 추가하세요.

```typescript
// backend/auth-service/src/__tests__/auth.service.test.ts
import { AuthService } from '../services/auth.service';

describe('AuthService', () => {
  it('should hash password', async () => {
    // 테스트 코드
  });
});
```

### 통합 테스트 추가

`tests/integration/` 디렉토리에 새로운 테스트 파일을 추가하세요.

```typescript
// tests/integration/product.integration.test.ts
import request from 'supertest';

describe('Product Service Integration Tests', () => {
  // 테스트 코드
});
```

### E2E 테스트 추가

`tests/e2e/specs/` 디렉토리에 새로운 스펙 파일을 추가하세요.

```typescript
// tests/e2e/specs/order-flow.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Order Flow E2E Tests', () => {
  // 테스트 코드
});
```

---

## 🎓 모범 사례

1. **테스트 격리**: 각 테스트는 독립적으로 실행 가능해야 합니다
2. **데이터 정리**: 테스트 후 생성된 데이터는 정리하세요
3. **명확한 이름**: 테스트 이름은 무엇을 테스트하는지 명확히 하세요
4. **빠른 실행**: 단위 테스트는 빠르게 실행되어야 합니다
5. **커버리지**: 최소 80% 이상의 코드 커버리지를 목표로 하세요

---

## 📚 참고 자료

- [Jest 공식 문서](https://jestjs.io/)
- [Supertest 공식 문서](https://github.com/visionmedia/supertest)
- [Playwright 공식 문서](https://playwright.dev/)
- [프로젝트 README](./README.md)
- [API 테스트 가이드](./API_TESTING_GUIDE.md)

---

**최종 업데이트**: 2025-01-XX  
**버전**: 1.0.0

