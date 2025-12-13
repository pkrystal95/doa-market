#!/bin/bash

# DOA Market - 전체 테스트 실행 스크립트
# 단위 테스트, 통합 테스트, E2E 테스트를 순차적으로 실행합니다

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "🧪 DOA Market - 전체 테스트 실행"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 테스트 결과 디렉토리
TEST_RESULTS_DIR="$PROJECT_ROOT/test-results"
mkdir -p "$TEST_RESULTS_DIR"

# 테스트 시작 시간
START_TIME=$(date +%s)

# 1. 단위 테스트
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1️⃣  단위 테스트 실행"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if ./scripts/run-unit-tests.sh; then
  echo "  ✅ 단위 테스트 완료"
  UNIT_TEST_RESULT=0
else
  echo "  ❌ 단위 테스트 실패"
  UNIT_TEST_RESULT=1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 2. 통합 테스트
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  2️⃣  통합 테스트 실행"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 인프라 서비스 확인 및 시작
if ! docker ps | grep -q "doa-postgres"; then
  echo "  📦 인프라 서비스 시작 중..."
  docker-compose up -d postgres redis rabbitmq
  echo "  ⏳ 인프라 서비스 초기화 대기 중 (20초)..."
  sleep 20
fi

if ./scripts/run-integration-tests.sh; then
  echo "  ✅ 통합 테스트 완료"
  INTEGRATION_TEST_RESULT=0
else
  echo "  ❌ 통합 테스트 실패"
  INTEGRATION_TEST_RESULT=1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 3. E2E 테스트
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  3️⃣  E2E 테스트 실행"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 서비스 실행 확인
SERVICES_RUNNING=true
for port in 3000 3001 3002 3003 3004; do
  if ! curl -s -f "http://localhost:$port/health" > /dev/null 2>&1; then
    SERVICES_RUNNING=false
    break
  fi
done

if [ "$SERVICES_RUNNING" = false ]; then
  echo "  ⚠️  일부 서비스가 실행 중이 아닙니다."
  echo "  💡 서비스를 시작하시겠습니까? (y/N)"
  read -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "  🚀 서비스 시작 중..."
    ./scripts/start-all-services.sh
    echo "  ⏳ 서비스 준비 대기 중 (15초)..."
    sleep 15
  else
    echo "  ⏭️  E2E 테스트 건너뜀"
    E2E_TEST_RESULT=0
  fi
fi

if [ "$SERVICES_RUNNING" = true ] || [ "$E2E_TEST_RESULT" != "0" ]; then
  if ./scripts/run-e2e-tests.sh; then
    echo "  ✅ E2E 테스트 완료"
    E2E_TEST_RESULT=0
  else
    echo "  ❌ E2E 테스트 실패"
    E2E_TEST_RESULT=1
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 테스트 종료 시간
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# 결과 요약
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 전체 테스트 결과 요약"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ⏱️  실행 시간: ${MINUTES}분 ${SECONDS}초"
echo ""
echo "  테스트 결과:"
echo "    단위 테스트:     $([ $UNIT_TEST_RESULT -eq 0 ] && echo '✅ 통과' || echo '❌ 실패')"
echo "    통합 테스트:     $([ $INTEGRATION_TEST_RESULT -eq 0 ] && echo '✅ 통과' || echo '❌ 실패')"
echo "    E2E 테스트:      $([ $E2E_TEST_RESULT -eq 0 ] && echo '✅ 통과' || echo '❌ 실패')"
echo ""
echo "  📁 테스트 결과 디렉토리:"
echo "    - 단위 테스트:   $TEST_RESULTS_DIR/unit"
echo "    - 통합 테스트:   $TEST_RESULTS_DIR/integration"
echo "    - E2E 테스트:    $TEST_RESULTS_DIR/e2e"
echo ""

# 전체 결과
TOTAL_FAILED=$((UNIT_TEST_RESULT + INTEGRATION_TEST_RESULT + E2E_TEST_RESULT))

if [ $TOTAL_FAILED -eq 0 ]; then
  echo "  🎉 모든 테스트 통과!"
  echo ""
  exit 0
else
  echo "  ⚠️  일부 테스트가 실패했습니다."
  echo "  📄 상세 로그는 위의 디렉토리를 확인하세요."
  echo ""
  exit 1
fi

