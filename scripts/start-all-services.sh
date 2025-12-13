#!/bin/bash

# DOA Market - 전체 시스템 실행 스크립트
# 모든 인프라 및 백엔드 서비스를 실행합니다

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "🚀 DOA Market - 전체 시스템 시작 중..."
echo ""

# 1. 인프라 서비스 시작
echo "📦 인프라 서비스 시작 중 (PostgreSQL, Redis, RabbitMQ, OpenSearch, LocalStack)..."
docker-compose up -d postgres redis rabbitmq opensearch localstack pgadmin

# 2. 인프라 서비스 준비 대기
echo "⏳ 인프라 서비스 초기화 대기 중 (30초)..."
sleep 30

# 3. Health Check
echo ""
echo "🔍 인프라 서비스 상태 확인 중..."
docker-compose ps postgres redis rabbitmq opensearch localstack

# 4. 백엔드 서비스 시작
echo ""
echo "🔧 백엔드 서비스 시작 중..."
echo ""

# API Gateway
echo "  → API Gateway 시작 중..."
cd "$PROJECT_ROOT/backend/api-gateway"

# 기존 프로세스 확인 및 종료
if lsof -ti:3000 > /dev/null 2>&1; then
  echo "    기존 프로세스 종료 중..."
  lsof -ti:3000 | xargs kill -9 2>/dev/null || true
  sleep 2
fi

if [ ! -d "node_modules" ]; then
  echo "    의존성 설치 중..."
  npm install
fi
npm run dev > /tmp/api-gateway.log 2>&1 &
API_GATEWAY_PID=$!
echo "    API Gateway PID: $API_GATEWAY_PID (포트 3000)"
sleep 5

# Auth Service
echo "  → Auth Service 시작 중..."
cd "$PROJECT_ROOT/backend/auth-service"

# 기존 프로세스 확인 및 종료
if lsof -ti:3001 > /dev/null 2>&1; then
  echo "    기존 프로세스 종료 중..."
  lsof -ti:3001 | xargs kill -9 2>/dev/null || true
  sleep 2
fi

if [ ! -d "node_modules" ]; then
  echo "    의존성 설치 중..."
  npm install
fi

# 환경 변수 설정
export NODE_ENV=development
export PORT=3001
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=doa_auth
export DB_USER=postgres
export DB_PASSWORD=postgres123
export JWT_ACCESS_SECRET=test-secret
export JWT_REFRESH_SECRET=test-refresh-secret

npm run dev > /tmp/auth-service.log 2>&1 &
AUTH_SERVICE_PID=$!
echo "    Auth Service PID: $AUTH_SERVICE_PID (포트 3001)"
sleep 5

# User Service
echo "  → User Service 시작 중..."
cd "$PROJECT_ROOT/backend/user-service"

# 기존 프로세스 확인 및 종료
if lsof -ti:3002 > /dev/null 2>&1; then
  echo "    기존 프로세스 종료 중..."
  lsof -ti:3002 | xargs kill -9 2>/dev/null || true
  sleep 2
fi

if [ ! -d "node_modules" ]; then
  echo "    의존성 설치 중..."
  npm install
fi

# 환경 변수 설정
export NODE_ENV=development
export PORT=3002
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=doa_users  # 기본값과 일치하도록 수정
export DB_USER=postgres
export DB_PASSWORD=postgres123

npm run dev > /tmp/user-service.log 2>&1 &
USER_SERVICE_PID=$!
echo "    User Service PID: $USER_SERVICE_PID (포트 3002)"
sleep 5

# Product Service
echo "  → Product Service 시작 중..."
cd "$PROJECT_ROOT/backend/product-service"

# 기존 프로세스 확인 및 종료
if lsof -ti:3003 > /dev/null 2>&1; then
  echo "    기존 프로세스 종료 중..."
  lsof -ti:3003 | xargs kill -9 2>/dev/null || true
  sleep 2
fi

if [ ! -d "node_modules" ]; then
  echo "    의존성 설치 중..."
  npm install
fi

# 환경 변수 설정
export NODE_ENV=development
export PORT=3003
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=doa_products
export DB_USER=postgres
export DB_PASSWORD=postgres123

npm run dev > /tmp/product-service.log 2>&1 &
PRODUCT_SERVICE_PID=$!
echo "    Product Service PID: $PRODUCT_SERVICE_PID (포트 3003)"
sleep 5

# Order Service
echo "  → Order Service 시작 중..."
cd "$PROJECT_ROOT/backend/order-service"

# 기존 프로세스 확인 및 종료
if lsof -ti:3004 > /dev/null 2>&1; then
  echo "    기존 프로세스 종료 중..."
  lsof -ti:3004 | xargs kill -9 2>/dev/null || true
  sleep 2
fi

if [ ! -d "node_modules" ]; then
  echo "    의존성 설치 중..."
  npm install
fi

# 환경 변수 설정
export NODE_ENV=development
export PORT=3004
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=doa_orders
export DB_USER=postgres
export DB_PASSWORD=postgres123

npm run dev > /tmp/order-service.log 2>&1 &
ORDER_SERVICE_PID=$!
echo "    Order Service PID: $ORDER_SERVICE_PID (포트 3004)"
sleep 5

# Payment Service
echo "  → Payment Service 시작 중..."
cd "$PROJECT_ROOT/backend/payment-service"

# 기존 프로세스 확인 및 종료
if lsof -ti:3005 > /dev/null 2>&1; then
  echo "    기존 프로세스 종료 중..."
  lsof -ti:3005 | xargs kill -9 2>/dev/null || true
  sleep 2
fi

if [ ! -d "node_modules" ]; then
  echo "    의존성 설치 중..."
  npm install
fi

# 환경 변수 설정
export NODE_ENV=development
export PORT=3005
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=doa_payments  # 기본값과 일치
export DB_USER=postgres
export DB_PASSWORD=postgres123

npm run dev > /tmp/payment-service.log 2>&1 &
PAYMENT_SERVICE_PID=$!
echo "    Payment Service PID: $PAYMENT_SERVICE_PID (포트 3005)"
sleep 5

# PID 저장
echo "$API_GATEWAY_PID" > /tmp/doa-api-gateway.pid
echo "$AUTH_SERVICE_PID" > /tmp/doa-auth-service.pid
echo "$USER_SERVICE_PID" > /tmp/doa-user-service.pid
echo "$PRODUCT_SERVICE_PID" > /tmp/doa-product-service.pid
echo "$ORDER_SERVICE_PID" > /tmp/doa-order-service.pid
echo "$PAYMENT_SERVICE_PID" > /tmp/doa-payment-service.pid

# 5. 서비스 상태 확인
echo ""
echo "⏳ 서비스 준비 대기 중 (15초)..."
sleep 15

echo ""
echo "🔍 서비스 Health Check..."
echo ""

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
    echo "  ✅ $name (포트 $port) - 정상"
    return 0
  else
    echo "  ❌ $name (포트 $port) - 실패"
    return 1
  fi
}

check_service 3000 "API Gateway"
check_service 3001 "Auth Service"
check_service 3002 "User Service"
check_service 3003 "Product Service"
check_service 3004 "Order Service"
check_service 3005 "Payment Service"

echo ""
echo "✅ 전체 시스템 시작 완료!"
echo ""
echo "📊 서비스 URL:"
echo "  - API Gateway: http://localhost:3000/api/v1/health"
echo "  - Auth Service: http://localhost:3001/api-docs"
echo "  - User Service: http://localhost:3002/api-docs"
echo "  - Product Service: http://localhost:3003/api-docs"
echo "  - Order Service: http://localhost:3004/api-docs"
echo "  - Payment Service: http://localhost:3005/api-docs"
echo ""
echo "📝 로그 확인:"
echo "  - API Gateway: tail -f /tmp/api-gateway.log"
echo "  - Auth Service: tail -f /tmp/auth-service.log"
echo "  - User Service: tail -f /tmp/user-service.log"
echo "  - Product Service: tail -f /tmp/product-service.log"
echo "  - Order Service: tail -f /tmp/order-service.log"
echo "  - Payment Service: tail -f /tmp/payment-service.log"
echo ""
echo "🛑 서비스 중지: ./scripts/stop-all-services.sh"
echo ""

