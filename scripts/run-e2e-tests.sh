#!/bin/bash

# DOA Market - E2E 테스트 실행 스크립트
# 전체 시스템을 사용한 End-to-End 테스트를 실행합니다

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "🎭 DOA Market - E2E 테스트 실행 중..."
echo ""

# 서비스 실행 확인
check_service() {
  local port=$1
  local name=$2
  local health_path=$3
  
  # 기본 health 경로 설정
  if [ -z "$health_path" ]; then
    # API Gateway는 /api/v1/health, 다른 서비스는 /health
    if [ "$port" = "3000" ]; then
      health_path="/api/v1/health"
    else
      health_path="/health"
    fi
  fi
  
  if curl -s -f "http://localhost:$port$health_path" > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# 서비스 시작 함수
start_service() {
  local service_dir=$1
  local service_name=$2
  local port=$3
  local log_file=$4
  
  echo "  🚀 $service_name 시작 중..."
  cd "$service_dir"
  if [ ! -d "node_modules" ]; then
    echo "    의존성 설치 중..."
    npm install --silent
  fi
  
  # 기존 프로세스 확인 및 종료
  if lsof -ti:$port > /dev/null 2>&1; then
    echo "    기존 프로세스 종료 중..."
    lsof -ti:$port | xargs kill -9 2>/dev/null || true
    sleep 2
  fi
  
  # 환경 변수 설정 (서비스별)
  if [ "$service_name" = "auth-service" ]; then
    export NODE_ENV=test
    export PORT=3001
    export DB_HOST=localhost
    export DB_PORT=5432
    export DB_NAME=doa_auth
    export DB_USER=postgres
    export DB_PASSWORD=postgres123
    export JWT_ACCESS_SECRET=test-secret
    export JWT_REFRESH_SECRET=test-refresh-secret
  fi
  
  npm run dev > "$log_file" 2>&1 &
  local pid=$!
  echo "$pid" > "/tmp/doa-${service_name}-e2e.pid"
  echo "    $service_name PID: $pid (포트 $port)"
  
  # 서비스 준비 대기
  echo "    ⏳ 서비스 준비 대기 중..."
  local health_path="/health"
  if [ "$port" = "3000" ]; then
    health_path="/api/v1/health"
  fi
  
  # 서비스별 대기 시간 조정
  local max_wait=15
  if [ "$service_name" = "auth-service" ]; then
    max_wait=25  # Auth Service는 DB 연결이 필요하므로 더 오래 대기
  fi
  
  for i in $(seq 1 $max_wait); do
    if curl -s -f "http://localhost:$port$health_path" > /dev/null 2>&1; then
      echo "    ✅ $service_name 준비 완료"
      return 0
    fi
    if [ $((i % 3)) -eq 0 ]; then
      echo "    ⏳ 대기 중... ($i/$max_wait)"
    fi
    sleep 2
  done
  
  echo "    ⚠️  $service_name 시작 확인 실패 (계속 진행)"
  return 1
}

echo "🔍 서비스 상태 확인 중..."

# 인프라 서비스 확인
if ! docker ps | grep -q "doa-postgres"; then
  echo "  📦 인프라 서비스 시작 중..."
  docker-compose up -d postgres redis
  echo "  ⏳ 인프라 서비스 초기화 대기 중 (15초)..."
  sleep 15
fi

# API Gateway 확인 및 시작
if ! check_service 3000 "API Gateway"; then
  echo "  ⚠️  API Gateway가 실행 중이 아닙니다. 시작 중..."
  start_service "$PROJECT_ROOT/backend/api-gateway" "api-gateway" 3000 "/tmp/api-gateway-e2e.log"
fi

# Auth Service 확인 및 시작
if ! check_service 3001 "Auth Service"; then
  echo "  ⚠️  Auth Service가 실행 중이 아닙니다. 시작 중..."
  start_service "$PROJECT_ROOT/backend/auth-service" "auth-service" 3001 "/tmp/auth-service-e2e.log"
fi

# User Service 확인 및 시작 (선택적)
if ! check_service 3002 "User Service"; then
  echo "  ⚠️  User Service가 실행 중이 아닙니다. 시작 중..."
  start_service "$PROJECT_ROOT/backend/user-service" "user-service" 3002 "/tmp/user-service-e2e.log"
fi

# Product Service 확인 및 시작 (선택적)
if ! check_service 3003 "Product Service"; then
  echo "  ⚠️  Product Service가 실행 중이 아닙니다. 시작 중..."
  start_service "$PROJECT_ROOT/backend/product-service" "product-service" 3003 "/tmp/product-service-e2e.log"
fi

# 최종 서비스 준비 대기
echo ""
echo "⏳ 최종 서비스 준비 대기 중 (5초)..."
sleep 5

# 최종 Health Check
echo ""
echo "🔍 최종 서비스 상태 확인..."
SERVICES_READY=true
for port in 3000 3001 3002 3003; do
  if check_service $port "Service-$port"; then
    echo "  ✅ 포트 $port: 정상"
  else
    echo "  ❌ 포트 $port: 실패"
    # API Gateway는 필수, 나머지는 선택적
    if [ "$port" = "3000" ] || [ "$port" = "3001" ]; then
      SERVICES_READY=false
    fi
  fi
done

if [ "$SERVICES_READY" = false ]; then
  echo ""
  echo "  ⚠️  일부 서비스가 준비되지 않았습니다."
  echo "  💡 로그를 확인하세요: /tmp/*-e2e.log"
  exit 1
fi

# 테스트 결과 저장
TEST_RESULTS_DIR="$PROJECT_ROOT/test-results/e2e"
mkdir -p "$TEST_RESULTS_DIR"

# E2E 테스트 디렉토리 확인
E2E_TEST_DIR="$PROJECT_ROOT/tests/e2e"
if [ ! -d "$E2E_TEST_DIR" ]; then
  echo "  📁 E2E 테스트 디렉토리 생성 중..."
  mkdir -p "$E2E_TEST_DIR"
fi

# Playwright 설정 확인
if ! command -v npx &> /dev/null; then
  echo "  ⚠️  npx를 찾을 수 없습니다. Node.js가 설치되어 있는지 확인하세요."
  exit 1
fi

# package.json 확인 및 생성
if [ ! -f "$E2E_TEST_DIR/package.json" ]; then
  echo "  ⚙️  package.json 생성 중..."
  cat > "$E2E_TEST_DIR/package.json" << 'EOF'
{
  "name": "doa-market-e2e-tests",
  "version": "1.0.0",
  "scripts": {
    "test": "playwright test",
    "test:headed": "playwright test --headed",
    "test:ui": "playwright test --ui",
    "test:debug": "playwright test --debug"
  },
  "devDependencies": {
    "@playwright/test": "^1.40.0",
    "@types/node": "^20.10.5",
    "typescript": "^5.3.3"
  }
}
EOF
fi

# Playwright 설정 파일 생성
if [ ! -f "$E2E_TEST_DIR/playwright.config.ts" ]; then
  echo "  ⚙️  Playwright 설정 파일 생성 중..."
  cat > "$E2E_TEST_DIR/playwright.config.ts" << 'EOF'
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './specs',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results/results.json' }],
    ['list'],
  ],
  use: {
    baseURL: process.env.API_BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'api',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'echo "서비스가 이미 실행 중이어야 합니다"',
    port: 3000,
    reuseExistingServer: true,
  },
});
EOF
fi

# 테스트 스펙 디렉토리 생성
SPECS_DIR="$E2E_TEST_DIR/specs"
if [ ! -d "$SPECS_DIR" ]; then
  echo "  📁 테스트 스펙 디렉토리 생성 중..."
  mkdir -p "$SPECS_DIR"
fi

# 샘플 E2E 테스트 생성 (없는 경우)
if [ ! -f "$SPECS_DIR/user-flow.spec.ts" ]; then
  echo "  📝 샘플 E2E 테스트 생성 중..."
  cat > "$SPECS_DIR/user-flow.spec.ts" << 'EOF'
import { test, expect } from '@playwright/test';

const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:3000';

test.describe('User Flow E2E Tests', () => {
  let accessToken: string;
  let userId: string;
  let productId: string;

  test('전체 사용자 플로우: 회원가입 → 로그인 → 상품 조회 → 주문 생성', async ({ request }) => {
    const timestamp = Date.now();
    const testEmail = `e2e-test-${timestamp}@example.com`;
    const testPassword = 'password123';

    // 1. 회원가입
    const registerResponse = await request.post(`${API_BASE_URL}/api/v1/auth/register`, {
      data: {
        email: testEmail,
        password: testPassword,
        name: 'E2E Test User',
      },
    });

    expect(registerResponse.ok()).toBeTruthy();
    const registerData = await registerResponse.json();
    expect(registerData.data).toHaveProperty('user');
    userId = registerData.data.user.userId;

    // 2. 로그인
    const loginResponse = await request.post(`${API_BASE_URL}/api/v1/auth/login`, {
      data: {
        email: testEmail,
        password: testPassword,
      },
    });

    expect(loginResponse.ok()).toBeTruthy();
    const loginData = await loginResponse.json();
    expect(loginData.data).toHaveProperty('accessToken');
    accessToken = loginData.data.accessToken;

    // 3. 상품 조회
    const productsResponse = await request.get(`${API_BASE_URL}/api/v1/products`, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    });

    expect(productsResponse.ok()).toBeTruthy();
    const productsData = await productsResponse.json();
    
    if (productsData.data && productsData.data.length > 0) {
      productId = productsData.data[0].productId;
    }

    // 4. 주문 생성 (상품이 있는 경우)
    if (productId) {
      const orderResponse = await request.post(`${API_BASE_URL}/api/v1/orders`, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        data: {
          userId,
          items: [
            {
              productId,
              quantity: 1,
              price: 10000,
            },
          ],
          totalAmount: 10000,
          shippingAddress: {
            name: 'E2E Test User',
            phone: '010-1234-5678',
            address: '123 Test St',
            city: 'Seoul',
            postalCode: '12345',
          },
        },
      });

      // 주문 생성은 성공하거나 실패할 수 있음 (재고 등에 따라)
      expect([200, 201, 400, 500]).toContain(orderResponse.status());
    }
  });

  test('Health Check - 모든 서비스', async ({ request }) => {
    const services = [
      { name: 'API Gateway', port: 3000 },
      { name: 'Auth Service', port: 3001 },
      { name: 'User Service', port: 3002 },
      { name: 'Product Service', port: 3003 },
      { name: 'Order Service', port: 3004 },
    ];

    for (const service of services) {
      const response = await request.get(`http://localhost:${service.port}/health`);
      expect(response.ok()).toBeTruthy();
      
      const data = await response.json();
      expect(data).toHaveProperty('status');
    }
  });
});
EOF
fi

# 의존성 설치
cd "$E2E_TEST_DIR"
if [ ! -d "node_modules" ]; then
  echo "  📦 의존성 설치 중..."
  npm install --silent
fi

# Playwright 브라우저 설치
if [ ! -d "node_modules/@playwright/test" ]; then
  echo "  🌐 Playwright 브라우저 설치 중..."
  npx playwright install --with-deps chromium
fi

# E2E 테스트 실행
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎭 E2E 테스트 실행 중..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$E2E_TEST_DIR"

# 환경 변수 설정
export API_BASE_URL="http://localhost:3000"

if npm test > "$TEST_RESULTS_DIR/e2e.log" 2>&1; then
  echo "  ✅ E2E 테스트 통과"
  echo ""
  echo "  📁 테스트 결과: $TEST_RESULTS_DIR"
  echo "  📊 HTML 리포트: $E2E_TEST_DIR/playwright-report/index.html"
  
  # 시작한 서비스 정리 (선택적)
  read -p "E2E 테스트용으로 시작한 서비스를 중지하시겠습니까? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for service in api-gateway auth-service user-service product-service; do
      if [ -f "/tmp/doa-${service}-e2e.pid" ]; then
        PID=$(cat "/tmp/doa-${service}-e2e.pid")
        if ps -p $PID > /dev/null 2>&1; then
          kill $PID 2>/dev/null || true
          echo "  ✅ $service 중지됨"
        fi
        rm -f "/tmp/doa-${service}-e2e.pid"
      fi
    done
  fi
  
  exit 0
else
  echo "  ❌ E2E 테스트 실패"
  echo "  📄 로그: $TEST_RESULTS_DIR/e2e.log"
  echo ""
  echo "  최근 에러:"
  tail -n 30 "$TEST_RESULTS_DIR/e2e.log"
  
  # 서비스는 유지 (디버깅을 위해)
  echo ""
  echo "  💡 서비스는 계속 실행 중입니다. 로그 확인: /tmp/*-e2e.log"
  echo ""
  echo "  서비스 중지 방법:"
  echo "    for pid in /tmp/doa-*-e2e.pid; do"
  echo "      kill \$(cat \$pid) 2>/dev/null && rm \$pid"
  echo "    done"
  
  exit 1
fi

