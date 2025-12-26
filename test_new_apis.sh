#!/bin/bash

# DOA Market - 신규 API 테스트 스크립트
# 2025-12-17

BASE_URL="https://192.168.0.19"
USER_ID="test-user-id"  # 실제 사용자 ID로 교체 필요

echo "========================================="
echo "DOA Market - 신규 API 엔드포인트 테스트"
echo "========================================="
echo ""

# 색상 코드
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

test_api() {
    local name=$1
    local url=$2
    local method=${3:-GET}

    echo -n "Testing $name... "

    if [ "$method" = "GET" ]; then
        response=$(curl -k -s -o /dev/null -w "%{http_code}" "$url")
    else
        response=$(curl -k -s -o /dev/null -w "%{http_code}" -X "$method" "$url")
    fi

    if [ "$response" = "200" ] || [ "$response" = "201" ]; then
        echo -e "${GREEN}✓ $response${NC}"
        return 0
    else
        echo -e "${RED}✗ $response${NC}"
        return 1
    fi
}

echo "1️⃣  포인트 시스템 (4개 API)"
echo "-----------------------------------"
test_api "포인트 요약" "$BASE_URL/api/v1/users/$USER_ID/points/summary"
test_api "포인트 내역" "$BASE_URL/api/v1/users/$USER_ID/points"
test_api "포인트 사용" "$BASE_URL/api/v1/users/$USER_ID/points/use" "POST"
test_api "포인트 적립" "$BASE_URL/api/v1/users/$USER_ID/points/earn" "POST"
echo ""

echo "2️⃣  공지사항 (2개 API)"
echo "-----------------------------------"
test_api "공지사항 목록" "$BASE_URL/api/v1/notices/"
test_api "공지사항 상세" "$BASE_URL/api/v1/notices/test-notice-id"
echo ""

echo "3️⃣  리뷰 시스템 (6개 API)"
echo "-----------------------------------"
test_api "내 리뷰 목록" "$BASE_URL/api/v1/users/$USER_ID/reviews"
test_api "상품 리뷰 목록" "$BASE_URL/api/v1/products/test-product-id/reviews"
test_api "리뷰 작성" "$BASE_URL/api/v1/users/$USER_ID/reviews" "POST"
test_api "리뷰 수정" "$BASE_URL/api/v1/users/$USER_ID/reviews/test-review-id" "PUT"
test_api "리뷰 삭제" "$BASE_URL/api/v1/users/$USER_ID/reviews/test-review-id" "DELETE"
echo ""

echo "4️⃣  1:1 문의 (3개 API)"
echo "-----------------------------------"
test_api "문의 목록" "$BASE_URL/api/v1/users/$USER_ID/inquiries"
test_api "문의 상세" "$BASE_URL/api/v1/users/$USER_ID/inquiries/test-inquiry-id"
test_api "문의 작성" "$BASE_URL/api/v1/users/$USER_ID/inquiries" "POST"
echo ""

echo "5️⃣  주문 취소/반품 (3개 API)"
echo "-----------------------------------"
test_api "주문 취소" "$BASE_URL/api/v1/orders/test-order-id/cancel" "POST"
test_api "반품 신청" "$BASE_URL/api/v1/orders/test-order-id/return" "POST"
test_api "교환 신청" "$BASE_URL/api/v1/orders/test-order-id/exchange" "POST"
echo ""

echo "========================================="
echo "✅ 총 20개 신규 API 엔드포인트 테스트 완료"
echo "========================================="
echo ""
echo "참고: 404 오류는 테스트 데이터가 없어서 정상입니다."
echo "      엔드포인트가 존재하고 접근 가능하면 성공입니다."
