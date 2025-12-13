# DOA Market - Testing Guide

## Prerequisites

1. Docker & Docker Compose installed
2. All backend services built
3. Flutter SDK installed (for mobile app testing)

## Running Services

### 1. Start Infrastructure Services

```bash
docker-compose up -d postgres redis rabbitmq localstack opensearch
```

### 2. Start Backend Services

```bash
# Start API Gateway
cd backend/api-gateway && npm run dev

# Start Order Service
cd backend/order-service && npm run dev

# Start Payment Service
cd backend/payment-service && npm run dev

# Start Inventory Service
cd backend/inventory-service && npm run dev
```

Or use docker-compose:

```bash
docker-compose up -d api-gateway order-service payment-service inventory-service
```

### 3. Verify Services are Running

```bash
# Check API Gateway
curl http://localhost:3000/api/v1/health

# Check RabbitMQ Management UI
open http://localhost:15672
# Login: rabbitmq / rabbitmq123
```

## Event-Driven Flow Testing

### Test 1: Order Creation → Payment → Inventory

#### Step 1: Create an Order

```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-token>" \
  -d '{
    "userId": "user-123",
    "items": [
      {
        "productId": "prod-1",
        "sellerId": "seller-1",
        "quantity": 2,
        "price": 10000
      }
    ],
    "totalAmount": 20000,
    "shippingAddress": {
      "name": "홍길동",
      "phone": "010-1234-5678",
      "address": "서울시 강남구",
      "city": "Seoul",
      "postalCode": "06000"
    }
  }'
```

#### Step 2: Check Event Flow

Watch the logs:

```bash
# Order Service should log:
# [EventBus] Published event: order.created

# Payment Service should log:
# [EventBus] Received event: order.created
# Payment record created: <payment-id>
# [EventBus] Published event: payment.completed

# Inventory Service should log:
# [EventBus] Received event: order.created
# Reserving 2 units of product prod-1
# [EventBus] Published event: inventory.reserved
# [EventBus] Received event: payment.completed
```

#### Step 3: Verify in RabbitMQ

1. Go to http://localhost:15672
2. Navigate to "Queues" tab
3. You should see queues:
   - `order-service.order.created`
   - `payment-service.order.created`
   - `inventory-service.order.created`
   - `inventory-service.payment.completed`

### Test 2: Authentication via API Gateway

#### Register a new user

```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

#### Login

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

Response:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "userId": "uuid",
      "email": "test@example.com",
      "role": "customer"
    }
  }
}
```

#### Access Protected Resource

```bash
TOKEN="<access-token-from-above>"

curl http://localhost:3000/api/v1/users/me \
  -H "Authorization: Bearer $TOKEN"
```

### Test 3: Rate Limiting

```bash
# Try to login 6 times rapidly (limit is 5 per 15 min)
for i in {1..6}; do
  curl -X POST http://localhost:3000/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"wrong"}' \
    -w "\nStatus: %{http_code}\n\n"
done
```

Expected: 6th request should return 429 Too Many Requests

## Flutter App Testing

### 1. Start Flutter App

```bash
cd user-app
flutter pub get
flutter run
```

### 2. Test User Flow

1. **Launch App** → Should show Splash Screen → Login Screen
2. **Register** → Create new account
3. **Login** → Use credentials
4. **Browse Products** → View product list
5. **Add to Cart** → Add items
6. **Checkout** → Create order
7. **View Orders** → Check order history

### 3. Monitor Network Requests

All requests should go through:
- **API Gateway**: `http://localhost:3000/api/v1`
- **NOT** direct service calls to ports 3001-3016

## Troubleshooting

### RabbitMQ Not Connecting

```bash
# Check RabbitMQ is running
docker ps | grep rabbitmq

# Check logs
docker logs doa-rabbitmq

# Restart RabbitMQ
docker-compose restart rabbitmq
```

### Service Can't Connect to Database

```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Connect to PostgreSQL
docker exec -it doa-postgres psql -U postgres

# List databases
\l
```

### Events Not Being Delivered

1. Check RabbitMQ exchanges: http://localhost:15672/#/exchanges
2. Verify exchange `doa-market-events` exists
3. Check queue bindings
4. Review service logs for connection errors

## Performance Testing

### Load Test API Gateway

```bash
# Install Apache Bench
brew install ab  # macOS

# Test 1000 requests, 10 concurrent
ab -n 1000 -c 10 http://localhost:3000/api/v1/health
```

### Monitor RabbitMQ Metrics

```bash
# Check message rate
docker exec doa-rabbitmq rabbitmqctl list_queues name messages messages_ready messages_unacknowledged
```

## Cleanup

```bash
# Stop all services
docker-compose down

# Remove volumes (CAREFUL: deletes all data)
docker-compose down -v

# Clean build artifacts
cd backend/api-gateway && rm -rf node_modules dist
cd backend/order-service && rm -rf node_modules dist
cd backend/payment-service && rm -rf node_modules dist
cd backend/inventory-service && rm -rf node_modules dist
```

## Next Steps

1. Add integration tests with Jest/Supertest
2. Add E2E tests with Cypress
3. Set up CI/CD pipeline
4. Deploy to staging environment
