#!/bin/bash

# DOA Market - Service Startup Script
# 로컬 개발 환경에서 서비스를 쉽게 실행하기 위한 스크립트

echo "🚀 DOA Market - Starting Services..."
echo ""

# 현재 디렉토리 확인
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# PostgreSQL & Redis 실행
echo "📦 Starting PostgreSQL & Redis..."
docker-compose up -d postgres redis pgadmin

# 초기화 대기
echo "⏳ Waiting for databases to initialize (15 seconds)..."
sleep 15

# Health Check
echo ""
echo "🔍 Checking database status..."
docker-compose ps postgres redis

echo ""
echo "✅ Infrastructure is ready!"
echo ""
echo "📖 Now you can start services:"
echo ""
echo "   🔐 Auth Service:"
echo "      cd backend/auth-service && npm install && npm run dev"
echo "      → http://localhost:3001/api-docs"
echo ""
echo "   👤 User Service:"
echo "      cd backend/user-service && npm install && npm run dev"
echo "      → http://localhost:3002/api-docs"
echo ""
echo "   📦 Product Service:"
echo "      cd backend/product-service && npm install && npm run dev"
echo "      → http://localhost:3003/api-docs"
echo ""
echo "   🛒 Order Service:"
echo "      cd backend/order-service && npm install && npm run dev"
echo "      → http://localhost:3004/api-docs"
echo ""
echo "   💳 Payment Service:"
echo "      cd backend/payment-service && npm install && npm run dev"
echo "      → http://localhost:3005/api-docs"
echo ""
echo "   🚚 Shipping Service:"
echo "      cd backend/shipping-service && npm install && npm run dev"
echo "      → http://localhost:3006/api-docs"
echo ""
echo "🔧 PgAdmin: http://localhost:5050"
echo "   Email: admin@doamarket.com"
echo "   Password: admin"
echo ""
echo "📚 Quick Start Guide: ./QUICK_START.md"
echo "📖 API Testing Guide: ./API_TESTING_GUIDE.md"
echo ""

