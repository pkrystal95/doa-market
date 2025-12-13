#!/bin/bash

# DOA Market - 전체 시스템 중지 스크립트

set -e

echo "🛑 DOA Market - 전체 시스템 중지 중..."
echo ""

# 백엔드 서비스 중지
if [ -f /tmp/doa-api-gateway.pid ]; then
  PID=$(cat /tmp/doa-api-gateway.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID 2>/dev/null || true
    echo "  ✅ API Gateway 중지됨 (PID: $PID)"
  fi
  rm -f /tmp/doa-api-gateway.pid
fi

if [ -f /tmp/doa-auth-service.pid ]; then
  PID=$(cat /tmp/doa-auth-service.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID 2>/dev/null || true
    echo "  ✅ Auth Service 중지됨 (PID: $PID)"
  fi
  rm -f /tmp/doa-auth-service.pid
fi

if [ -f /tmp/doa-user-service.pid ]; then
  PID=$(cat /tmp/doa-user-service.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID 2>/dev/null || true
    echo "  ✅ User Service 중지됨 (PID: $PID)"
  fi
  rm -f /tmp/doa-user-service.pid
fi

if [ -f /tmp/doa-product-service.pid ]; then
  PID=$(cat /tmp/doa-product-service.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID 2>/dev/null || true
    echo "  ✅ Product Service 중지됨 (PID: $PID)"
  fi
  rm -f /tmp/doa-product-service.pid
fi

if [ -f /tmp/doa-order-service.pid ]; then
  PID=$(cat /tmp/doa-order-service.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID 2>/dev/null || true
    echo "  ✅ Order Service 중지됨 (PID: $PID)"
  fi
  rm -f /tmp/doa-order-service.pid
fi

if [ -f /tmp/doa-payment-service.pid ]; then
  PID=$(cat /tmp/doa-payment-service.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID 2>/dev/null || true
    echo "  ✅ Payment Service 중지됨 (PID: $PID)"
  fi
  rm -f /tmp/doa-payment-service.pid
fi

# 인프라 서비스 중지 (선택적)
read -p "인프라 서비스도 중지하시겠습니까? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "  📦 인프라 서비스 중지 중..."
  docker-compose down
  echo "  ✅ 인프라 서비스 중지됨"
fi

echo ""
echo "✅ 전체 시스템 중지 완료!"

