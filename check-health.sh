#!/bin/bash

# DOA Market - Health Check Script
# 모든 서비스의 상태를 확인하는 스크립트

echo "🏥 DOA Market - Health Check"
echo "============================"
echo ""

# Infrastructure
echo "📦 Infrastructure:"
echo "  PostgreSQL: $(docker-compose ps postgres | grep -q Up && echo '✅ Running' || echo '❌ Down')"
echo "  Redis: $(docker-compose ps redis | grep -q Up && echo '✅ Running' || echo '❌ Down')"
echo "  PgAdmin: $(docker-compose ps pgadmin | grep -q Up && echo '✅ Running' || echo '❌ Down')"
echo ""

# Services
echo "🔧 Services:"
services=(
  "3001:Auth"
  "3002:User"
  "3003:Product"
  "3004:Order"
  "3005:Payment"
  "3006:Shipping"
  "3007:Seller"
  "3008:Settlement"
  "3009:Coupon"
  "3010:Inventory"
  "3011:Notification"
  "3012:Review"
  "3013:Search"
  "3014:Admin"
  "3015:File"
  "3016:Stats"
)

for service in "${services[@]}"; do
  IFS=':' read -r port name <<< "$service"
  echo -n "  $name Service (Port $port): "
  
  response=$(curl -s http://localhost:$port/health 2>/dev/null)
  
  if [ $? -eq 0 ]; then
    status=$(echo "$response" | jq -r '.status' 2>/dev/null)
    if [ "$status" == "ok" ]; then
      echo "✅ Running"
    else
      echo "⚠️  Unknown status"
    fi
  else
    echo "❌ Down"
  fi
done

echo ""
echo "📊 Swagger API Documentation:"
for service in "${services[@]}"; do
  IFS=':' read -r port name <<< "$service"
  if curl -s http://localhost:$port/health > /dev/null 2>&1; then
    echo "  $name: http://localhost:$port/api-docs"
  fi
done

echo ""

