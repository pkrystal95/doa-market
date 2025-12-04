#!/bin/bash

# DOA Market - cURL로 API 테스트
# Postman Collection에 포함된 API들을 cURL로 테스트

BASE_URL="http://localhost:3003"
AUTH_URL="http://localhost:3001"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "════════════════════════════════════════════════════"
echo "DOA Market API - cURL 테스트"
echo "════════════════════════════════════════════════════"
echo ""

# 1. Health Check
echo -e "${BLUE}1. Health Check${NC}"
echo "   GET $BASE_URL/api/v1/health"
echo ""
curl -s "$BASE_URL/api/v1/health" | jq .
echo ""
echo ""

# 2. Get All Products
echo -e "${BLUE}2. Get All Products${NC}"
echo "   GET $BASE_URL/api/v1/products?page=1&limit=20"
echo ""
curl -s "$BASE_URL/api/v1/products?page=1&limit=20" | jq .
echo ""
echo ""

# 3. Search Products (if implemented)
echo -e "${BLUE}3. Search Products${NC}"
echo "   GET $BASE_URL/api/v1/products/search?q=headphones"
echo ""
curl -s "$BASE_URL/api/v1/products/search?q=headphones" | jq . 2>/dev/null || echo "   ⚠️  Not implemented yet"
echo ""
echo ""

# 4. Get Categories (if implemented)
echo -e "${BLUE}4. Get Categories${NC}"
echo "   GET $BASE_URL/api/v1/categories"
echo ""
curl -s "$BASE_URL/api/v1/categories" | jq . 2>/dev/null || echo "   ⚠️  Not implemented yet"
echo ""
echo ""

echo "════════════════════════════════════════════════════"
echo "인증이 필요한 API 테스트 (Auth Service 필요)"
echo "════════════════════════════════════════════════════"
echo ""

# 5. Login (if auth service is running)
echo -e "${BLUE}5. Login (Auth Service: $AUTH_URL)${NC}"
echo "   POST $AUTH_URL/api/v1/auth/login"
echo ""
LOGIN_DATA='{
  "email": "test@example.com",
  "password": "Password123!"
}'

LOGIN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$AUTH_URL/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "$LOGIN_DATA" 2>/dev/null)

HTTP_CODE=$(echo "$LOGIN_RESPONSE" | tail -n 1)
BODY=$(echo "$LOGIN_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "$BODY" | jq .
    ACCESS_TOKEN=$(echo "$BODY" | jq -r '.data.accessToken // .accessToken // empty')
    echo ""
    echo -e "${GREEN}✓ 로그인 성공${NC}"
    echo ""

    # 6. Create Product (with auth)
    echo -e "${BLUE}6. Create Product (인증 필요)${NC}"
    echo "   POST $BASE_URL/api/v1/products"
    echo ""

    PRODUCT_DATA='{
      "name": "Test Product - Wireless Headphones",
      "description": "High-quality wireless headphones",
      "price": 99.99,
      "categoryId": 1,
      "sellerId": 1,
      "stock": 100,
      "brand": "TestBrand",
      "specifications": {
        "color": "Black",
        "weight": "250g"
      },
      "tags": ["electronics", "audio", "test"]
    }'

    curl -s -X POST "$BASE_URL/api/v1/products" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -d "$PRODUCT_DATA" | jq . 2>/dev/null || echo "   ⚠️  Not implemented yet"
else
    echo -e "${YELLOW}⚠️  Auth Service가 실행되지 않았거나 로그인 실패${NC}"
    echo "   Auth Service를 시작하려면:"
    echo "   cd backend/services/auth-service && npm run dev"
fi

echo ""
echo ""
echo "════════════════════════════════════════════════════"
echo "테스트 완료!"
echo "════════════════════════════════════════════════════"
echo ""
echo "💡 팁:"
echo "   - Postman 사용: POSTMAN-GUIDE.md 참고"
echo "   - API 문서: docs/04-api-design.md 참고"
echo "   - 현재 API: CURRENT-API.md 참고"
echo ""
