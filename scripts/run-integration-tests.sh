#!/bin/bash

# DOA Market - 통합 테스트 실행 스크립트
# 실제 서비스와 데이터베이스를 사용한 통합 테스트를 실행합니다

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "🔗 DOA Market - 통합 테스트 실행 중..."
echo ""

# 인프라 서비스 확인
echo "📦 인프라 서비스 확인 중..."
if ! docker ps | grep -q "doa-postgres"; then
  echo "  ⚠️  PostgreSQL이 실행 중이 아닙니다. 시작 중..."
  docker-compose up -d postgres redis
  echo "  ⏳ 데이터베이스 초기화 대기 중 (15초)..."
  sleep 15
fi

if ! docker ps | grep -q "doa-redis"; then
  echo "  ⚠️  Redis가 실행 중이 아닙니다. 시작 중..."
  docker-compose up -d redis
  sleep 5
fi

# Auth Service 확인 및 시작
if ! curl -s -f "http://localhost:3001/health" > /dev/null 2>&1; then
  echo "  ⚠️  Auth Service가 실행 중이 아닙니다. 시작 중..."
  cd "$PROJECT_ROOT/backend/auth-service"
  if [ ! -d "node_modules" ]; then
    echo "    의존성 설치 중..."
    npm install --silent
  fi
  # 기존 프로세스 확인 및 종료
  if lsof -ti:3001 > /dev/null 2>&1; then
    echo "    기존 프로세스 종료 중..."
    lsof -ti:3001 | xargs kill -9 2>/dev/null || true
    sleep 2
  fi
  
  # 환경 변수 설정
  export NODE_ENV=test
  export PORT=3001
  export DB_HOST=localhost
  export DB_PORT=5432
  export DB_NAME=doa_auth
  export DB_USER=postgres
  export DB_PASSWORD=postgres123
  export JWT_ACCESS_SECRET=test-secret
  export JWT_REFRESH_SECRET=test-refresh-secret
  
  npm run dev > /tmp/auth-service-integration.log 2>&1 &
  AUTH_PID=$!
  echo "$AUTH_PID" > /tmp/doa-auth-service-integration.pid
  echo "    Auth Service PID: $AUTH_PID"
  echo "  ⏳ Auth Service 준비 대기 중 (20초)..."
  sleep 20
  
  # Health check 재시도
  SERVICE_READY=false
  for i in {1..10}; do
    if curl -s -f "http://localhost:3001/health" > /dev/null 2>&1; then
      echo "    ✅ Auth Service 준비 완료"
      SERVICE_READY=true
      break
    fi
    echo "    ⏳ 대기 중... ($i/10)"
    sleep 3
  done
  
  if [ "$SERVICE_READY" = false ]; then
    echo "    ❌ Auth Service 시작 실패"
    echo "    📄 로그 확인: tail -f /tmp/auth-service-integration.log"
    if [ -f /tmp/auth-service-integration.log ]; then
      echo "    최근 로그:"
      tail -n 10 /tmp/auth-service-integration.log
    fi
  fi
fi

# 테스트 결과 저장
TEST_RESULTS_DIR="$PROJECT_ROOT/test-results/integration"
mkdir -p "$TEST_RESULTS_DIR"

# 통합 테스트 디렉토리 확인
INTEGRATION_TEST_DIR="$PROJECT_ROOT/tests/integration"
if [ ! -d "$INTEGRATION_TEST_DIR" ]; then
  echo "  📁 통합 테스트 디렉토리 생성 중..."
  mkdir -p "$INTEGRATION_TEST_DIR"
fi

# 통합 테스트 설정 파일 생성
if [ ! -f "$INTEGRATION_TEST_DIR/jest.config.js" ]; then
  echo "  ⚙️  통합 테스트 설정 파일 생성 중..."
  cat > "$INTEGRATION_TEST_DIR/jest.config.js" << 'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>'],
  testMatch: ['**/*.test.ts', '**/*.spec.ts'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  testTimeout: 30000,
  collectCoverageFrom: [
    '**/*.ts',
    '!**/*.d.ts',
    '!**/node_modules/**',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  moduleFileExtensions: ['ts', 'js', 'json'],
  verbose: true,
  setupFilesAfterEnv: ['<rootDir>/setup.ts'],
};
EOF
fi

# 테스트 설정 파일 생성
if [ ! -f "$INTEGRATION_TEST_DIR/setup.ts" ]; then
  echo "  ⚙️  테스트 설정 파일 생성 중..."
  cat > "$INTEGRATION_TEST_DIR/setup.ts" << 'EOF'
// 통합 테스트 전역 설정
import { execSync } from 'child_process';

// 테스트 전 데이터베이스 초기화
beforeAll(async () => {
  // 필요시 데이터베이스 초기화 로직
  console.log('통합 테스트 환경 준비 중...');
});

afterAll(async () => {
  // 테스트 후 정리 로직
  console.log('통합 테스트 환경 정리 중...');
});
EOF
fi

# package.json 확인 및 생성
if [ ! -f "$INTEGRATION_TEST_DIR/package.json" ]; then
  echo "  ⚙️  package.json 생성 중..."
  cat > "$INTEGRATION_TEST_DIR/package.json" << 'EOF'
{
  "name": "doa-market-integration-tests",
  "version": "1.0.0",
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "devDependencies": {
    "@types/jest": "^29.5.11",
    "@types/node": "^20.10.5",
    "@types/supertest": "^6.0.2",
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "ts-jest": "^29.1.1",
    "typescript": "^5.3.3"
  }
}
EOF
fi

# 의존성 설치
cd "$INTEGRATION_TEST_DIR"
if [ ! -d "node_modules" ]; then
  echo "  📦 의존성 설치 중..."
  npm install --silent
fi

# 샘플 통합 테스트 생성 (없는 경우)
if [ ! -f "$INTEGRATION_TEST_DIR/auth.integration.test.ts" ]; then
  echo "  📝 샘플 통합 테스트 생성 중..."
  cat > "$INTEGRATION_TEST_DIR/auth.integration.test.ts" << 'EOF'
import request from 'supertest';

const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:3001';

describe('Auth Service Integration Tests', () => {
  describe('POST /api/v1/auth/register', () => {
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
      expect(response.body.data).toHaveProperty('user');
    });

    it('should reject duplicate email', async () => {
      const email = `test-${Date.now()}@example.com`;
      
      // 첫 번째 등록
      await request(API_BASE_URL)
        .post('/api/v1/auth/register')
        .send({
          email,
          password: 'password123',
          name: 'Test User',
        });

      // 중복 등록 시도
      const response = await request(API_BASE_URL)
        .post('/api/v1/auth/register')
        .send({
          email,
          password: 'password123',
          name: 'Test User',
        });

      expect(response.status).toBe(400);
    });
  });

  describe('POST /api/v1/auth/login', () => {
    let testEmail: string;
    let testPassword: string;

    beforeAll(async () => {
      testEmail = `test-${Date.now()}@example.com`;
      testPassword = 'password123';

      // 테스트 사용자 생성
      await request(API_BASE_URL)
        .post('/api/v1/auth/register')
        .send({
          email: testEmail,
          password: testPassword,
          name: 'Test User',
        });
    });

    it('should login with valid credentials', async () => {
      const response = await request(API_BASE_URL)
        .post('/api/v1/auth/login')
        .send({
          email: testEmail,
          password: testPassword,
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('data');
      expect(response.body.data).toHaveProperty('accessToken');
      expect(response.body.data).toHaveProperty('refreshToken');
    });

    it('should reject invalid credentials', async () => {
      const response = await request(API_BASE_URL)
        .post('/api/v1/auth/login')
        .send({
          email: testEmail,
          password: 'wrongpassword',
        });

      expect(response.status).toBe(401);
    });
  });
});
EOF
fi

# 통합 테스트 실행
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔗 통합 테스트 실행 중..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$INTEGRATION_TEST_DIR"

# 환경 변수 설정
export API_BASE_URL="http://localhost:3001"
export DB_HOST="localhost"
export DB_PORT="5432"
export DB_USER="postgres"
export DB_PASSWORD="postgres123"

# Auth Service 환경 변수 설정 (서비스 시작 시)
export NODE_ENV=test
export PORT=3001
export DB_NAME=doa_auth
export JWT_ACCESS_SECRET=test-secret
export JWT_REFRESH_SECRET=test-refresh-secret

if npm test > "$TEST_RESULTS_DIR/integration.log" 2>&1; then
  echo "  ✅ 통합 테스트 통과"
  echo ""
  echo "  📁 테스트 결과: $TEST_RESULTS_DIR"
  
  # 시작한 서비스 정리
  if [ -f /tmp/doa-auth-service-integration.pid ]; then
    PID=$(cat /tmp/doa-auth-service-integration.pid)
    if ps -p $PID > /dev/null 2>&1; then
      kill $PID 2>/dev/null || true
      rm -f /tmp/doa-auth-service-integration.pid
    fi
  fi
  
  exit 0
else
  echo "  ❌ 통합 테스트 실패"
  echo "  📄 로그: $TEST_RESULTS_DIR/integration.log"
  echo ""
  echo "  최근 에러:"
  tail -n 30 "$TEST_RESULTS_DIR/integration.log"
  
  # 시작한 서비스 정리
  if [ -f /tmp/doa-auth-service-integration.pid ]; then
    PID=$(cat /tmp/doa-auth-service-integration.pid)
    if ps -p $PID > /dev/null 2>&1; then
      kill $PID 2>/dev/null || true
      rm -f /tmp/doa-auth-service-integration.pid
    fi
  fi
  
  exit 1
fi

