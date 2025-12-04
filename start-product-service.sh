#!/bin/bash

echo "======================================"
echo "DOA Market - Product Service 시작"
echo "======================================"
echo ""

# 현재 디렉토리 확인
cd /Users/krystal/workspace/doa-market/backend/services/product-service

# PostgreSQL & Redis 상태 확인
echo "1. Docker 서비스 상태 확인..."
docker-compose ps

echo ""
echo "2. 환경 변수 설정..."
export NODE_ENV=development
export PORT=3003
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=doa_products
export DB_USER=postgres
export DB_PASSWORD=
export REDIS_HOST=localhost
export REDIS_PORT=6379
export REDIS_PASSWORD=
export OPENSEARCH_ENABLED=false
export LOG_LEVEL=info

echo ""
echo "3. Product Service 시작 중..."
echo "포트: http://localhost:3003"
echo ""

npm run dev
