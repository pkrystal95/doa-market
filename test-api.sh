#!/bin/bash
# DOA Market Backend API Basic Test

echo "========== DOA Market API Tests =========="
echo ""

PASS=0
FAIL=0

# 1. Health Checks
echo "1. Health Checks"
for service in "auth-service:3001" "product-service:3003" "user-service:3002"; do
    name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    
    status=$(curl -s http://localhost:$port/health)
    if [ $? -eq 0 ]; then
        echo "✓ $name: OK"
        ((PASS++))
    else
        echo "✗ $name: FAIL"
        ((FAIL++))
    fi
done
echo ""

# 2. Register User
echo "2. User Registration Test"
TIMESTAMP=$(date +%s)
TEST_EMAIL="test${TIMESTAMP}@test.com"
REGISTER_DATA='{"email":"'$TEST_EMAIL'","password":"Test1234!","name":"Test User"}'

REGISTER_RESP=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$REGISTER_DATA" \
    http://localhost:3001/api/auth/register)

CODE=$(echo "$REGISTER_RESP" | tail -n1)
BODY=$(echo "$REGISTER_RESP" | sed '$d')

if [ "$CODE" = "200" ] || [ "$CODE" = "201" ]; then
    echo "✓ User registration: OK (HTTP $CODE)"
    echo "  Email: $TEST_EMAIL"
    ((PASS++))
else
    echo "✗ User registration: FAIL (HTTP $CODE)"
    echo "  Response: $BODY"
    ((FAIL++))
fi
echo ""

# 3. Get Products
echo "3. Product List Test"
PRODUCTS_RESP=$(curl -s -w "\n%{http_code}" http://localhost:3003/api/products)
CODE=$(echo "$PRODUCTS_RESP" | tail -n1)

if [ "$CODE" = "200" ]; then
    echo "✓ Get products: OK"
    ((PASS++))
else
    echo "✗ Get products: FAIL (HTTP $CODE)"
    ((FAIL++))
fi
echo ""

# Summary
echo "=========================================="
echo "Results: $PASS passed, $FAIL failed"
echo "=========================================="

if [ $FAIL -eq 0 ]; then
    exit 0
else
    exit 1
fi
