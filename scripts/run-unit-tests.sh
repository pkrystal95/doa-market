#!/bin/bash

# DOA Market - 단위 테스트 실행 스크립트
# 모든 서비스의 단위 테스트를 실행합니다

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "🧪 DOA Market - 단위 테스트 실행 중..."
echo ""

# 테스트 결과 저장
TEST_RESULTS_DIR="$PROJECT_ROOT/test-results/unit"
mkdir -p "$TEST_RESULTS_DIR"

# 테스트 통계
TOTAL_SERVICES=0
PASSED_SERVICES=0
FAILED_SERVICES=0

# 서비스 목록
SERVICES=(
  "api-gateway"
  "auth-service"
  "user-service"
  "product-service"
  "order-service"
  "payment-service"
)

# 각 서비스 테스트 실행
for service in "${SERVICES[@]}"; do
  SERVICE_DIR="$PROJECT_ROOT/backend/$service"
  
  if [ ! -d "$SERVICE_DIR" ]; then
    echo "  ⚠️  $service: 디렉토리를 찾을 수 없습니다"
    continue
  fi

  TOTAL_SERVICES=$((TOTAL_SERVICES + 1))
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  🧪 $service 테스트 실행 중..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  cd "$SERVICE_DIR"
  
  # package.json에 test 스크립트가 있는지 확인
  if ! grep -q '"test"' package.json 2>/dev/null; then
    echo "  ⚠️  $service: 테스트 스크립트가 없습니다"
    continue
  fi
  
  # node_modules 확인
  if [ ! -d "node_modules" ]; then
    echo "  📦 의존성 설치 중..."
    npm install --silent
  fi
  
  # 테스트 실행
  if npm test > "$TEST_RESULTS_DIR/$service.log" 2>&1; then
    echo "  ✅ $service: 테스트 통과"
    PASSED_SERVICES=$((PASSED_SERVICES + 1))
  else
    echo "  ❌ $service: 테스트 실패"
    FAILED_SERVICES=$((FAILED_SERVICES + 1))
    echo "  📄 로그: $TEST_RESULTS_DIR/$service.log"
  fi
  
  echo ""
done

# 커버리지 리포트 생성 (가능한 경우)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 커버리지 리포트 생성 중..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for service in "${SERVICES[@]}"; do
  SERVICE_DIR="$PROJECT_ROOT/backend/$service"
  
  if [ ! -d "$SERVICE_DIR" ]; then
    continue
  fi
  
  cd "$SERVICE_DIR"
  
  # test:coverage 스크립트가 있는지 확인
  if grep -q '"test:coverage"' package.json 2>/dev/null; then
    echo "  📊 $service 커버리지 생성 중..."
    npm run test:coverage > "$TEST_RESULTS_DIR/$service-coverage.log" 2>&1 || true
  fi
done

# 결과 요약
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 테스트 결과 요약"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  총 서비스: $TOTAL_SERVICES"
echo "  ✅ 통과: $PASSED_SERVICES"
echo "  ❌ 실패: $FAILED_SERVICES"
echo ""
echo "  📁 테스트 결과: $TEST_RESULTS_DIR"
echo ""

if [ $FAILED_SERVICES -eq 0 ]; then
  echo "  🎉 모든 단위 테스트 통과!"
  exit 0
else
  echo "  ⚠️  일부 테스트가 실패했습니다. 로그를 확인하세요."
  exit 1
fi

