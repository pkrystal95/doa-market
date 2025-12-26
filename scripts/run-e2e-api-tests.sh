#!/bin/bash

# DOA Market E2E API Tests Runner
# This script runs all API tests and generates reports

set -e

echo "========================================="
echo "DOA Market E2E API Tests"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if services are running
echo "Checking services..."
SERVICES=(
  "http://localhost:3001:Auth Service"
  "http://localhost:3002:User Service"
  "http://localhost:3003:Product Service"
  "http://localhost:3004:Order Service"
  "http://localhost:3007:Seller Service"
  "http://localhost:3009:Coupon Service"
  "http://localhost:3014:Admin Service"
)

SERVICES_DOWN=0

for service in "${SERVICES[@]}"; do
  IFS=':' read -r url name <<< "$service"
  if curl -s "${url}/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $name is running"
  else
    echo -e "${RED}✗${NC} $name is NOT running at $url"
    SERVICES_DOWN=$((SERVICES_DOWN + 1))
  fi
done

echo ""

if [ $SERVICES_DOWN -gt 0 ]; then
  echo -e "${YELLOW}Warning:${NC} $SERVICES_DOWN service(s) are not running"
  echo "Some tests may fail. Start services with: docker-compose up -d"
  echo ""
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

# Run tests
echo "Running API tests..."
echo ""

SKIP_WEB_SERVER=true npx playwright test tests/e2e/api --reporter=list,html

TEST_EXIT_CODE=$?

echo ""
echo "========================================="

if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed!${NC}"
else
  echo -e "${RED}✗ Some tests failed${NC}"
  echo ""
  echo "View detailed report: npx playwright show-report"
fi

echo "========================================="

exit $TEST_EXIT_CODE
