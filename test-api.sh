#!/bin/bash

# DOA Market API Test Script
# This script tests the Product Service API endpoints

set -e

BASE_URL="http://localhost:3003/api/v1"
AUTH_URL="http://localhost:3001/api/v1"

echo "======================================"
echo "DOA Market API Test Script"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

# Function to make HTTP requests and check response
test_endpoint() {
    local method=$1
    local url=$2
    local description=$3
    local data=$4
    local token=$5

    echo ""
    echo -e "${YELLOW}Testing: $description${NC}"
    echo "Method: $method"
    echo "URL: $url"
    
    if [ -n "$data" ]; then
        echo "Data: $data"
    fi

    if [ -n "$token" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$url" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            ${data:+-d "$data"})
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$url" \
            -H "Content-Type: application/json" \
            ${data:+-d "$data"})
    fi
    
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | sed '$d')
    
    echo "Response Code: $http_code"
    echo "Response Body: $body" | jq . 2>/dev/null || echo "$body"
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        print_result 0 "$description"
        echo "$body"
        return 0
    else
        print_result 1 "$description (HTTP $http_code)"
        return 1
    fi
}

echo "1. Testing Health Check..."
echo "======================================"
test_endpoint "GET" "$BASE_URL/health" "Health Check"

echo ""
echo ""
echo "2. Testing Authentication..."
echo "======================================"

# Register a test user
echo ""
echo "2.1. Registering test user..."
register_data='{
  "email": "testuser@example.com",
  "password": "Password123!",
  "name": "Test User",
  "phoneNumber": "+821012345678"
}'

register_response=$(test_endpoint "POST" "$AUTH_URL/auth/register" "Register User" "$register_data") || true

# Login to get token
echo ""
echo "2.2. Logging in..."
login_data='{
  "email": "testuser@example.com",
  "password": "Password123!"
}'

login_response=$(test_endpoint "POST" "$AUTH_URL/auth/login" "Login" "$login_data")

# Extract access token
if command -v jq &> /dev/null; then
    ACCESS_TOKEN=$(echo "$login_response" | jq -r '.data.accessToken // .accessToken // empty')
    if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" = "null" ]; then
        echo -e "${RED}Warning: Could not extract access token. Protected endpoints will fail.${NC}"
        ACCESS_TOKEN=""
    else
        echo -e "${GREEN}Access token obtained successfully${NC}"
    fi
else
    echo -e "${YELLOW}Warning: jq not installed. Cannot extract token automatically.${NC}"
    echo "Please install jq: brew install jq (macOS) or apt-get install jq (Linux)"
    ACCESS_TOKEN=""
fi

echo ""
echo ""
echo "3. Testing Product Endpoints..."
echo "======================================"

# Get all products
echo ""
echo "3.1. Getting all products..."
test_endpoint "GET" "$BASE_URL/products?page=1&limit=10" "Get All Products"

# Get product by ID
echo ""
echo "3.2. Getting product by ID..."
test_endpoint "GET" "$BASE_URL/products/1" "Get Product by ID" "" || echo "Product might not exist yet"

# Create a product (requires auth)
if [ -n "$ACCESS_TOKEN" ]; then
    echo ""
    echo "3.3. Creating a new product..."
    product_data='{
      "name": "Test Product - Wireless Headphones",
      "description": "High-quality wireless headphones for testing",
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
    
    create_response=$(test_endpoint "POST" "$BASE_URL/products" "Create Product" "$product_data" "$ACCESS_TOKEN") || true
    
    # Extract product ID if jq is available
    if command -v jq &> /dev/null && [ -n "$create_response" ]; then
        PRODUCT_ID=$(echo "$create_response" | jq -r '.data.id // .id // empty')
        echo "Created Product ID: $PRODUCT_ID"
        
        # Update the product
        if [ -n "$PRODUCT_ID" ] && [ "$PRODUCT_ID" != "null" ]; then
            echo ""
            echo "3.4. Updating product..."
            update_data='{
              "name": "Test Product - Updated",
              "price": 89.99
            }'
            test_endpoint "PUT" "$BASE_URL/products/$PRODUCT_ID" "Update Product" "$update_data" "$ACCESS_TOKEN" || true
            
            # Get the updated product
            echo ""
            echo "3.5. Getting updated product..."
            test_endpoint "GET" "$BASE_URL/products/$PRODUCT_ID" "Get Updated Product" "" || true
        fi
    fi
else
    echo -e "${YELLOW}Skipping authenticated endpoints (no access token)${NC}"
fi

# Search products
echo ""
echo "3.6. Searching products..."
test_endpoint "GET" "$BASE_URL/products/search?q=headphones" "Search Products"

# Get categories
echo ""
echo ""
echo "4. Testing Category Endpoints..."
echo "======================================"

echo ""
echo "4.1. Getting all categories..."
test_endpoint "GET" "$BASE_URL/categories" "Get All Categories"

echo ""
echo ""
echo "======================================"
echo "API Testing Complete!"
echo "======================================"
echo ""
echo "Summary:"
echo "- Base URL: $BASE_URL"
echo "- Authentication URL: $AUTH_URL"
if [ -n "$ACCESS_TOKEN" ]; then
    echo -e "- Authentication: ${GREEN}Success${NC}"
else
    echo -e "- Authentication: ${YELLOW}Skipped or Failed${NC}"
fi
echo ""
echo "For more detailed testing, use:"
echo "  - Postman collection: docs/api/postman-collection.json"
echo "  - API documentation: docs/03-api-design.md"
echo ""
