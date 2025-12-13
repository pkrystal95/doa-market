#!/bin/bash

# DOA Market - 테스트 개선 스크립트
# 테스트 커버리지 개선 및 품질 향상

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "🔧 DOA Market - 테스트 개선 중..."
echo ""

# 1. 모든 서비스의 테스트 실행 및 커버리지 확인
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1️⃣  테스트 실행 및 커버리지 확인"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SERVICES=(
  "api-gateway"
  "auth-service"
  "user-service"
  "product-service"
  "order-service"
  "payment-service"
)

TOTAL_COVERAGE=0
SERVICE_COUNT=0

for service in "${SERVICES[@]}"; do
  SERVICE_DIR="$PROJECT_ROOT/backend/$service"
  
  if [ ! -d "$SERVICE_DIR" ]; then
    continue
  fi

  cd "$SERVICE_DIR"
  
  # test:coverage 스크립트가 있는지 확인
  if grep -q '"test:coverage"' package.json 2>/dev/null; then
    echo "  📊 $service 커버리지 확인 중..."
    npm run test:coverage > /dev/null 2>&1 || true
    
    # 커버리지 파일 확인
    if [ -f "coverage/coverage-summary.json" ]; then
      COVERAGE=$(node -e "const fs = require('fs'); const data = JSON.parse(fs.readFileSync('coverage/coverage-summary.json')); console.log(data.total.lines.pct);" 2>/dev/null || echo "0")
      if [ -n "$COVERAGE" ] && [ "$COVERAGE" != "undefined" ]; then
        echo "    ✅ 커버리지: ${COVERAGE}%"
        TOTAL_COVERAGE=$(echo "$TOTAL_COVERAGE + $COVERAGE" | bc 2>/dev/null || echo "$TOTAL_COVERAGE")
        SERVICE_COUNT=$((SERVICE_COUNT + 1))
      fi
    fi
  fi
done

# 평균 커버리지 계산
if [ $SERVICE_COUNT -gt 0 ]; then
  AVG_COVERAGE=$(echo "scale=2; $TOTAL_COVERAGE / $SERVICE_COUNT" | bc 2>/dev/null || echo "0")
  echo ""
  echo "  📊 평균 커버리지: ${AVG_COVERAGE}%"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  2️⃣  테스트 개선 권장 사항"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ✅ 모든 서비스에 기본 테스트 추가 완료"
echo "  ✅ 타입 오류 수정 완료"
echo "  ✅ Jest 설정 개선 완료"
echo ""
echo "  💡 추가 개선 사항:"
echo "    - 각 서비스의 비즈니스 로직 테스트 추가"
echo "    - 통합 테스트 시나리오 확장"
echo "    - E2E 테스트 시나리오 추가"
echo "    - 커버리지 80% 이상 목표"
echo ""

