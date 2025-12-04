# DOA Market - Quickstart Guide

This guide will help you quickly set up and run the DOA Market backend services for local development and testing.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Running Individual Services](#running-individual-services)
- [Testing APIs](#testing-apis)
- [Accessing Admin Tools](#accessing-admin-tools)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** 20.x or higher ([Download](https://nodejs.org/))
- **Docker** and **Docker Compose** ([Download](https://www.docker.com/))
- **Git** ([Download](https://git-scm.com/))
- **curl** or **Postman** for API testing

### Verify Installation

```bash
node --version    # Should be v20.x or higher
npm --version     # Should be 10.x or higher
docker --version  # Should be 20.x or higher
docker-compose --version
```

## Quick Start

### Option 1: Run All Services with Docker Compose (Recommended for Quick Testing)

This is the fastest way to get everything running:

```bash
# 1. Clone the repository (if not already done)
git clone <repository-url>
cd doa-market

# 2. Start all infrastructure and services
docker-compose up -d

# 3. Wait for services to be healthy (may take 2-3 minutes)
docker-compose ps

# 4. Check service logs
docker-compose logs -f product-service
```

**Services will be available at:**
- Product Service: http://localhost:3003
- Auth Service: http://localhost:3001
- User Service: http://localhost:3002
- Order Service: http://localhost:3004
- Payment Service: http://localhost:3005
- (See docker-compose.yml for all service ports)

**Admin Tools:**
- pgAdmin (PostgreSQL UI): http://localhost:5050
- Redis Commander: http://localhost:8081
- Mailhog (Email Testing): http://localhost:8025
- OpenSearch: http://localhost:9200

### Option 2: Run Services Locally (Recommended for Development)

This approach gives you more control and faster hot-reload during development:

#### Step 1: Start Infrastructure Only

```bash
# Start only PostgreSQL, Redis, LocalStack, and OpenSearch
docker-compose up -d postgres redis localstack opensearch mailhog
```

#### Step 2: Setup Product Service (Example)

```bash
# Navigate to product service
cd backend/services/product-service

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# The .env file is already configured for local development
# You can edit it if needed

# Run database migrations
npm run migration:run

# Start the service in development mode (with hot-reload)
npm run dev
```

The service will start on http://localhost:3003

#### Step 3: Verify Service is Running

```bash
# Health check
curl http://localhost:3003/api/v1/health

# Expected response:
# {"status":"ok","timestamp":"2024-12-04T...","service":"product-service"}
```

## Running Individual Services

### Product Service

```bash
cd backend/services/product-service

# Install dependencies
npm install

# Copy .env file
cp .env.example .env

# Run migrations
npm run migration:run

# Development mode (hot-reload)
npm run dev

# Production mode
npm run build
npm start

# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

### Auth Service

```bash
cd backend/services/auth-service

npm install
cp .env.example .env
npm run migration:run
npm run dev
```

### Other Services

Follow the same pattern for other services:
- user-service (Port 3002)
- order-service (Port 3004)
- payment-service (Port 3005)
- inventory-service (Port 3010)
- shipping-service (Port 3006)
- seller-service (Port 3007)
- settlement-service (Port 3008)
- coupon-service (Port 3009)
- notification-service (Port 3011)
- review-service (Port 3012)
- search-service (Port 3013)
- admin-service (Port 3014)
- file-service (Port 3015)
- stats-service (Port 3016)

## Testing APIs

### Using curl

#### 1. Health Check

```bash
curl http://localhost:3003/api/v1/health
```

#### 2. Get All Products

```bash
curl http://localhost:3003/api/v1/products
```

#### 3. Get Product by ID

```bash
curl http://localhost:3003/api/v1/products/1
```

#### 4. Create a Product (Requires Authentication)

First, register and login to get a JWT token:

```bash
# Register a new user
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!",
    "name": "Test User"
  }'

# Login to get access token
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!"
  }'

# Response will include: {"accessToken": "eyJ...", "refreshToken": "..."}
```

Then create a product:

```bash
# Replace YOUR_ACCESS_TOKEN with the token from login
curl -X POST http://localhost:3003/api/v1/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "name": "Test Product",
    "description": "This is a test product",
    "price": 29.99,
    "categoryId": 1,
    "sellerId": 1,
    "stock": 100
  }'
```

#### 5. Update a Product

```bash
curl -X PUT http://localhost:3003/api/v1/products/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "name": "Updated Product Name",
    "price": 39.99
  }'
```

#### 6. Delete a Product

```bash
curl -X DELETE http://localhost:3003/api/v1/products/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Using Postman

1. Import the Postman collection from `docs/api/postman-collection.json`
2. Set the environment variables:
   - `base_url`: http://localhost:3003
   - `auth_url`: http://localhost:3001
3. Run the authentication requests first to get tokens
4. Use the collection to test all endpoints

## Accessing Admin Tools

### pgAdmin (PostgreSQL Database Management)

1. Open http://localhost:5050
2. Login with:
   - Email: `admin@doa-market.com`
   - Password: `admin123`
3. Add Server:
   - Host: `postgres` (or `host.docker.internal` if running pgAdmin outside Docker)
   - Port: `5432`
   - Username: `postgres`
   - Password: `postgres123`

### Redis Commander

1. Open http://localhost:8081
2. No authentication required for local development
3. Browse keys, view data, and execute Redis commands

### Mailhog (Email Testing)

1. Open http://localhost:8025
2. All emails sent by the application will appear here
3. Useful for testing notification emails, password resets, etc.

### OpenSearch

1. Open http://localhost:9200
2. View cluster health:
   ```bash
   curl http://localhost:9200/_cluster/health?pretty
   ```
3. List indices:
   ```bash
   curl http://localhost:9200/_cat/indices?v
   ```

### LocalStack (AWS Emulator)

LocalStack emulates AWS services locally. Access it at http://localhost:4566

```bash
# Install AWS CLI local wrapper
pip install awscli-local

# List S3 buckets
awslocal s3 ls

# List SQS queues
awslocal sqs list-queues

# List DynamoDB tables
awslocal dynamodb list-tables
```

## Database Management

### Running Migrations

```bash
cd backend/services/product-service

# Run all pending migrations
npm run migration:run

# Revert last migration
npm run migration:revert

# Generate a new migration
npm run migration:generate -- -n CreateProductsTable

# Create an empty migration
npm run migration:create -- -n AddIndexToProducts
```

### Accessing PostgreSQL Database

```bash
# Using psql
docker exec -it doa-postgres psql -U postgres -d doa_products

# List all databases
\l

# Connect to a specific database
\c doa_products

# List tables
\dt

# Describe a table
\d products

# Run a query
SELECT * FROM products LIMIT 10;

# Exit
\q
```

### Seeding Test Data

```bash
cd backend/services/product-service

# Run seed data
npm run seed

# This will create sample products, categories, and sellers
```

## Monitoring and Debugging

### View Service Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f product-service

# Last 100 lines
docker-compose logs --tail=100 product-service
```

### Monitor Service Health

```bash
# Check all container status
docker-compose ps

# Check specific service health
curl http://localhost:3003/api/v1/health

# Check PostgreSQL connection
docker exec -it doa-postgres pg_isready -U postgres

# Check Redis connection
docker exec -it doa-redis redis-cli -a redis123 ping
```

### Performance Monitoring

```bash
# View container resource usage
docker stats

# View specific service stats
docker stats doa-product-service
```

## Troubleshooting

### Common Issues

#### 1. Port Already in Use

**Error:** `Bind for 0.0.0.0:5432 failed: port is already allocated`

**Solution:**
```bash
# Check what's using the port
lsof -i :5432  # On macOS/Linux
netstat -ano | findstr :5432  # On Windows

# Stop the conflicting service or change the port in docker-compose.yml
```

#### 2. Database Connection Error

**Error:** `ECONNREFUSED` or `Connection refused`

**Solution:**
```bash
# Ensure PostgreSQL is running
docker-compose ps postgres

# Check logs
docker-compose logs postgres

# Restart the database
docker-compose restart postgres

# Wait for it to be healthy
docker-compose ps postgres
```

#### 3. Migration Errors

**Error:** `relation "products" does not exist`

**Solution:**
```bash
# Ensure you're connected to the correct database
cd backend/services/product-service

# Run migrations
npm run migration:run

# If migrations are out of sync, you may need to reset
npm run migration:revert
npm run migration:run
```

#### 4. Redis Connection Error

**Error:** `NOAUTH Authentication required`

**Solution:**
Update your `.env` file with the correct Redis password:
```
REDIS_PASSWORD=redis123
```

#### 5. Out of Memory

**Error:** Docker containers crashing or `Cannot allocate memory`

**Solution:**
```bash
# Increase Docker memory limit in Docker Desktop settings
# Recommended: At least 4GB RAM for all services

# Or run fewer services
docker-compose up -d postgres redis product-service
```

#### 6. Permission Denied on Scripts

**Error:** `permission denied: ./scripts/init.sh`

**Solution:**
```bash
chmod +x scripts/*.sh
```

### Clean Start

If you encounter persistent issues, try a clean restart:

```bash
# Stop all containers
docker-compose down

# Remove all volumes (WARNING: This deletes all data!)
docker-compose down -v

# Remove all containers and images
docker-compose down --rmi all

# Start fresh
docker-compose up -d

# Wait for services to initialize
sleep 30

# Check status
docker-compose ps
```

### Getting Help

If you continue to experience issues:

1. Check the service logs: `docker-compose logs <service-name>`
2. Verify environment variables in `.env` files
3. Ensure all prerequisites are installed correctly
4. Check Docker daemon is running: `docker info`
5. Verify you have enough disk space: `df -h`

## Next Steps

- **API Documentation**: See `docs/03-api-design.md` for complete API specifications
- **Architecture**: Review `docs/01-architecture-design.md` for system architecture
- **Database Schemas**: Check `docs/02-database-schema.md` for database structure
- **Frontend Setup**: See `frontend/admin-web/README.md` for frontend quickstart
- **Deployment**: Review `docs/10-deployment-strategy.md` for production deployment

## Useful Commands Cheat Sheet

```bash
# Infrastructure
docker-compose up -d                    # Start all services
docker-compose down                     # Stop all services
docker-compose ps                       # View service status
docker-compose logs -f <service>        # View logs

# Development
npm install                             # Install dependencies
npm run dev                             # Start in development mode
npm run build                           # Build for production
npm start                               # Start in production mode
npm test                                # Run tests

# Database
npm run migration:run                   # Run migrations
npm run migration:revert                # Revert migration
npm run seed                            # Seed test data

# Docker
docker ps                               # List running containers
docker stats                            # View resource usage
docker exec -it <container> sh          # Access container shell
docker logs -f <container>              # View container logs

# PostgreSQL
docker exec -it doa-postgres psql -U postgres -d doa_products
\l                                      # List databases
\c <database>                           # Connect to database
\dt                                     # List tables
\d <table>                              # Describe table

# Redis
docker exec -it doa-redis redis-cli -a redis123
KEYS *                                  # List all keys
GET <key>                               # Get value
FLUSHALL                                # Clear all data
```

Happy coding! 🚀
