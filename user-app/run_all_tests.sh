#!/bin/bash

# DOA Market - 전체 E2E 테스트 실행 스크립트

echo "========================================="
echo "  DOA Market E2E Test Suite"
echo "========================================="
echo ""

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 결과 변수
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 테스트 결과 저장 디렉토리
TEST_RESULTS_DIR="test_results"
mkdir -p $TEST_RESULTS_DIR

echo -e "${BLUE}📱 Flutter 의존성 확인...${NC}"
flutter pub get
echo ""

echo -e "${BLUE}🧪 테스트 시작${NC}"
echo "----------------------------------------"
echo ""

# 1. 기본 앱 플로우 테스트
echo -e "${YELLOW}[1/4] 기본 앱 플로우 테스트...${NC}"
flutter test integration_test/app_flow_test.dart > $TEST_RESULTS_DIR/app_flow.log 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASSED_TESTS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))
echo ""

# 2. 전체 구매 플로우 테스트
echo -e "${YELLOW}[2/4] 전체 구매 플로우 테스트...${NC}"
flutter test integration_test/purchase_flow_test.dart > $TEST_RESULTS_DIR/purchase_flow.log 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASSED_TESTS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))
echo ""

# 3. 마이페이지 플로우 테스트
echo -e "${YELLOW}[3/4] 마이페이지 플로우 테스트...${NC}"
flutter test integration_test/mypage_flow_test.dart > $TEST_RESULTS_DIR/mypage_flow.log 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASSED_TESTS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))
echo ""

# 4. 상품 탐색 플로우 테스트
echo -e "${YELLOW}[4/4] 상품 탐색 플로우 테스트...${NC}"
flutter test integration_test/product_exploration_test.dart > $TEST_RESULTS_DIR/product_exploration.log 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASSED_TESTS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))
echo ""

# 결과 요약
echo "========================================="
echo "  테스트 결과 요약"
echo "========================================="
echo -e "총 테스트: $TOTAL_TESTS"
echo -e "${GREEN}통과: $PASSED_TESTS${NC}"
echo -e "${RED}실패: $FAILED_TESTS${NC}"
echo ""

# 성공률 계산
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "성공률: ${SUCCESS_RATE}%"
fi
echo ""

# 상세 로그 위치 안내
echo "상세 로그: $TEST_RESULTS_DIR/"
echo ""

# 종료 코드
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ 모든 테스트 통과!${NC}"
    exit 0
else
    echo -e "${RED}❌ 일부 테스트 실패${NC}"
    echo "실패한 테스트 로그를 확인하세요."
    exit 1
fi
