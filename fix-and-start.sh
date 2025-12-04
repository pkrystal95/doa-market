#!/bin/bash

echo "======================================"
echo "DOA Market - 문제 해결 및 서버 시작"
echo "======================================"
echo ""

cd /Users/krystal/workspace/doa-market/backend/services/product-service

echo "1. Import 경로 문제 수정 중..."
# @/types로 통일
find src -name "*.ts" -type f -exec sed -i '' 's|from "@types/index"|from "@/types"|g' {} \;
find src -name "*.ts" -type f -exec sed -i '' "s|from '../types'|from '@/types'|g" {} \;
find src -name "*.ts" -type f -exec sed -i '' 's|from "../../types"|from "@/types"|g' {} \;

echo "2. .env 파일 업데이트 중..."
cat > .env << 'ENVFILE'
NODE_ENV=development
PORT=3003
SERVICE_NAME=product-service
LOG_LEVEL=debug

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=doa_products
DB_USER=postgres
DB_PASSWORD=
DB_SSL=false
DB_POOL_MIN=2
DB_POOL_MAX=10
DB_SYNCHRONIZE=true
DB_LOGGING=true

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0
REDIS_TTL=3600
CACHE_ENABLED=false

# OpenSearch
OPENSEARCH_NODE=http://localhost:9200
OPENSEARCH_INDEX_PREFIX=doa-market-dev
OPENSEARCH_ENABLED=false

# AWS
AWS_REGION=ap-northeast-2
AWS_ACCOUNT_ID=000000000000
AWS_ENDPOINT=http://localhost:4566
EVENTBRIDGE_BUS_NAME=doa-market-dev-event-bus
S3_BUCKET=doa-market-dev-products

# JWT
JWT_SECRET=dev-jwt-secret-change-in-production
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# API
API_VERSION=v1
API_PREFIX=/api/v1
INTERNAL_API_KEY=dev-internal-api-key
CORS_ORIGINS=http://localhost:3000,http://localhost:3001

# Monitoring
XRAY_ENABLED=false
CLOUDWATCH_ENABLED=false
METRICS_ENABLED=false

# Rate Limiting
RATE_LIMIT_ENABLED=false

# Pagination
DEFAULT_PAGE_SIZE=20
MAX_PAGE_SIZE=100
ENVFILE

echo "3. 데이터베이스 확인 중..."
docker exec doa-postgres psql -U postgres -c "SELECT 1" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✓ PostgreSQL 연결 확인"
    
    # 데이터베이스 생성
    docker exec doa-postgres psql -U postgres -c "CREATE DATABASE doa_products" 2>/dev/null || echo "   ✓ 데이터베이스 이미 존재"
else
    echo "   ✗ PostgreSQL 연결 실패"
    exit 1
fi

echo "4. Redis 확인 중..."
docker exec doa-redis redis-cli ping > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✓ Redis 연결 확인"
else
    echo "   ✗ Redis 연결 실패"
fi

echo ""
echo "5. 서버 시작 중..."
echo "   포트: http://localhost:3003"
echo "   로그 레벨: debug"
echo ""
echo "Ctrl+C로 종료할 수 있습니다."
echo ""

npm run dev
