# 8. Node.js 마이크로서비스 샘플 코드

## 개요

이 문서는 DOA Market의 Product Service를 중심으로 한 Node.js 마이크로서비스의 완전한 구현 예시를 제공합니다.

## 기술 스택

```yaml
언어 및 런타임:
  - Node.js: 20 LTS
  - TypeScript: 5.3+

웹 프레임워크:
  - Express.js: 4.18+

ORM/데이터베이스:
  - TypeORM: 0.3+ (PostgreSQL)
  - ioredis: 5.3+ (Redis)
  - @opensearch-project/opensearch: 2.5+ (OpenSearch)

AWS SDK:
  - @aws-sdk/client-eventbridge: EventBridge 이벤트 발행
  - @aws-sdk/client-s3: S3 파일 저장
  - @aws-sdk/client-secrets-manager: 시크릿 관리
  - aws-xray-sdk: 분산 트레이싱

보안 및 검증:
  - helmet: HTTP 헤더 보안
  - cors: CORS 설정
  - joi: 데이터 검증
  - jsonwebtoken: JWT 인증

모니터링:
  - winston: 로깅
  - winston-cloudwatch: CloudWatch Logs 통합

기타:
  - compression: 응답 압축
  - express-rate-limit: Rate limiting
  - uuid: UUID 생성
```

## 프로젝트 구조

```
backend/services/product-service/
├── src/
│   ├── config/              # 설정 파일
│   │   ├── database.ts      # TypeORM 설정
│   │   ├── redis.ts         # Redis 설정 및 서비스
│   │   └── opensearch.ts    # OpenSearch 설정 및 서비스
│   ├── controllers/         # HTTP 컨트롤러
│   │   └── ProductController.ts
│   ├── services/            # 비즈니스 로직
│   │   └── ProductService.ts
│   ├── repositories/        # 데이터 액세스 계층
│   │   └── ProductRepository.ts
│   ├── models/              # TypeORM 엔티티
│   │   ├── Product.ts
│   │   ├── Category.ts
│   │   ├── ProductVariant.ts
│   │   └── ProductImage.ts
│   ├── dto/                 # Data Transfer Objects
│   │   └── product.dto.ts
│   ├── middlewares/         # Express 미들웨어
│   │   ├── auth.middleware.ts
│   │   ├── validation.middleware.ts
│   │   └── error.middleware.ts
│   ├── routes/              # API 라우트
│   │   ├── index.ts
│   │   └── product.routes.ts
│   ├── events/              # 이벤트 처리
│   │   ├── publishers/
│   │   │   └── EventPublisher.ts
│   │   └── consumers/
│   │       └── OrderEventConsumer.ts
│   ├── utils/               # 유틸리티
│   │   ├── logger.ts
│   │   └── errors.ts
│   ├── types/               # TypeScript 타입 정의
│   │   └── index.ts
│   ├── app.ts               # Express 앱 설정
│   └── server.ts            # 서버 엔트리 포인트
├── tests/                   # 테스트 파일
├── Dockerfile               # Docker 이미지 빌드
├── .dockerignore
├── .env.example
├── package.json
└── tsconfig.json
```

## 주요 구현 파일

### 1. 서버 엔트리 포인트 (server.ts)

```typescript
// src/server.ts
import { config } from 'dotenv';
config();

import app from './app';
import { initializeDatabase, closeDatabase } from '@config/database';
import { initializeOpenSearch } from '@config/opensearch';
import { redisClient } from '@config/redis';
import { logger } from '@utils/logger';

const PORT = process.env.PORT || 3003;

async function startServer() {
  try {
    await initializeDatabase();
    await initializeOpenSearch();
    await redisClient.ping();

    server = app.listen(PORT, () => {
      logger.info(`product-service is running on port ${PORT}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

startServer();
```

**핵심 기능:**
- 데이터베이스, Redis, OpenSearch 초기화
- Graceful shutdown 처리 (SIGTERM, SIGINT)
- 에러 핸들링

### 2. Express 앱 설정 (app.ts)

```typescript
// src/app.ts
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import AWSXRay from 'aws-xray-sdk';

const app = express();

// 보안 미들웨어
app.use(helmet());
app.use(cors());

// Body parsing
app.use(express.json({ limit: '10mb' }));

// Compression
app.use(compression());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15분
  max: 100, // 최대 100 요청
});
app.use('/api/', limiter);

// X-Ray 트레이싱
if (process.env.XRAY_ENABLED === 'true') {
  app.use(AWSXRay.express.openSegment('product-service'));
}

// 라우트
app.use('/api/v1', routes);

// 에러 핸들링
app.use(errorHandler);
```

**핵심 기능:**
- 보안 헤더 (Helmet)
- Rate limiting
- AWS X-Ray 분산 트레이싱
- 에러 핸들링

### 3. 데이터베이스 설정 (config/database.ts)

```typescript
// src/config/database.ts
import { DataSource } from 'typeorm';

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  entities: ['src/models/**/*.ts'],
  migrations: ['src/database/migrations/**/*.ts'],
  synchronize: process.env.NODE_ENV === 'development',
  ssl: process.env.DB_SSL === 'true',
  extra: {
    max: 10,  // 최대 연결 수
    min: 2,   // 최소 연결 수
  },
});
```

**핵심 기능:**
- PostgreSQL 연결 풀 관리
- 자동 마이그레이션 (프로덕션)
- SSL 지원

### 4. Redis 설정 (config/redis.ts)

```typescript
// src/config/redis.ts
import Redis from 'ioredis';

export const redisClient = new Redis({
  host: process.env.REDIS_HOST,
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD,
  retryStrategy: (times) => Math.min(times * 50, 2000),
});

export class RedisService {
  async get<T>(key: string): Promise<T | null> {
    const value = await redisClient.get(key);
    return value ? JSON.parse(value) : null;
  }

  async set(key: string, value: any, ttl: number = 3600): Promise<boolean> {
    await redisClient.setex(key, ttl, JSON.stringify(value));
    return true;
  }

  async del(key: string): Promise<boolean> {
    await redisClient.del(key);
    return true;
  }
}
```

**핵심 기능:**
- 자동 재연결
- TTL 기반 캐싱
- 타입 안전 get/set

### 5. OpenSearch 설정 (config/opensearch.ts)

```typescript
// src/config/opensearch.ts
import { Client } from '@opensearch-project/opensearch';

export const opensearchClient = new Client({
  node: process.env.OPENSEARCH_NODE,
  auth: {
    username: process.env.OPENSEARCH_USERNAME,
    password: process.env.OPENSEARCH_PASSWORD,
  },
});

export const INDICES = {
  PRODUCTS: 'doa-market-products',
};

// 인덱스 생성
await opensearchClient.indices.create({
  index: INDICES.PRODUCTS,
  body: {
    mappings: {
      properties: {
        name: { type: 'text', analyzer: 'korean_analyzer' },
        price: { type: 'double' },
        categoryId: { type: 'keyword' },
        // ...
      },
    },
  },
});
```

**핵심 기능:**
- 한국어 형태소 분석 (Nori analyzer)
- 자동 인덱스 생성
- 검색 쿼리 최적화

### 6. TypeORM 엔티티 (models/Product.ts)

```typescript
// src/models/Product.ts
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany } from 'typeorm';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'seller_id', type: 'uuid' })
  sellerId: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'varchar', length: 255, unique: true })
  slug: string;

  @Column({ type: 'decimal', precision: 15, scale: 2 })
  price: number;

  @Column({ type: 'varchar', length: 20, default: 'draft' })
  status: string;

  @ManyToOne(() => Category)
  category: Category;

  @OneToMany(() => ProductVariant, variant => variant.product)
  variants: ProductVariant[];
}
```

**핵심 기능:**
- UUID 기본 키
- 관계 매핑 (ManyToOne, OneToMany)
- 인덱스 자동 생성

### 7. DTO 및 검증 (dto/product.dto.ts)

```typescript
// src/dto/product.dto.ts
import Joi from 'joi';

export interface CreateProductDto {
  sellerId: string;
  categoryId: string;
  name: string;
  slug: string;
  price: number;
}

export const createProductSchema = Joi.object({
  sellerId: Joi.string().uuid().required(),
  categoryId: Joi.string().uuid().required(),
  name: Joi.string().min(1).max(255).required(),
  slug: Joi.string().pattern(/^[a-z0-9-]+$/).required(),
  price: Joi.number().min(0).required(),
});
```

**핵심 기능:**
- 타입 안전 DTO
- Joi 검증 스키마
- 자동 검증 및 sanitization

### 8. Repository 패턴 (repositories/ProductRepository.ts)

```typescript
// src/repositories/ProductRepository.ts
import { AppDataSource } from '@config/database';
import { Product } from '@models/Product';

export class ProductRepository {
  private repository = AppDataSource.getRepository(Product);

  async findById(id: string): Promise<Product | null> {
    return await this.repository.findOne({
      where: { id },
      relations: ['category', 'images', 'variants'],
    });
  }

  async findAll(filter: any, pagination: any): Promise<{ products: Product[]; total: number }> {
    const [products, total] = await this.repository.findAndCount({
      where: filter,
      relations: ['category', 'images'],
      order: { [pagination.sortBy]: pagination.sortOrder },
      skip: (pagination.page - 1) * pagination.limit,
      take: pagination.limit,
    });
    return { products, total };
  }

  async create(data: Partial<Product>): Promise<Product> {
    const product = this.repository.create(data);
    return await this.repository.save(product);
  }

  async update(id: string, data: Partial<Product>): Promise<Product | null> {
    await this.repository.update(id, data);
    return await this.findById(id);
  }
}
```

**핵심 기능:**
- 데이터 액세스 계층 분리
- 관계 로딩 최적화
- 페이지네이션 지원

### 9. Service 계층 (services/ProductService.ts)

```typescript
// src/services/ProductService.ts
import { productRepository } from '@repositories/ProductRepository';
import { redisService } from '@config/redis';
import { opensearchService } from '@config/opensearch';
import { eventPublisher } from '@events/publishers/EventPublisher';

export class ProductService {
  async getProductById(id: string): Promise<ProductResponseDto> {
    // 1. 캐시 확인
    const cacheKey = `product:${id}`;
    const cached = await redisService.get(cacheKey);
    if (cached) return cached;

    // 2. DB 조회
    const product = await productRepository.findById(id);
    if (!product) {
      throw new AppError('PRODUCT_NOT_FOUND', 'Product not found', 404);
    }

    // 3. 캐시 저장
    const dto = this.transformToDto(product);
    await redisService.set(cacheKey, dto, 3600);

    // 4. 조회수 증가 (비동기)
    productRepository.incrementViewCount(id).catch(err => {
      logger.error('Failed to increment view count', { id, error: err });
    });

    return dto;
  }

  async createProduct(data: CreateProductDto, userId: string): Promise<ProductResponseDto> {
    // 1. Slug 중복 확인
    const slugExists = await productRepository.checkSlugExists(data.slug);
    if (slugExists) {
      throw new AppError('SLUG_ALREADY_EXISTS', 'Product slug already exists', 400);
    }

    // 2. 상품 생성
    const product = await productRepository.create(data);

    // 3. OpenSearch 인덱싱 (비동기)
    opensearchService.indexProduct(product.id, product).catch(err => {
      logger.error('Failed to index product', { productId: product.id, error: err });
    });

    // 4. 이벤트 발행
    await eventPublisher.publishProductCreated({
      productId: product.id,
      sellerId: product.sellerId,
      name: product.name,
      userId,
    });

    return this.transformToDto(product);
  }

  async searchProducts(searchTerm: string, filter: any, pagination: any) {
    // OpenSearch 쿼리 실행
    const query = {
      query: {
        bool: {
          must: [{
            multi_match: {
              query: searchTerm,
              fields: ['name^3', 'description', 'categoryName'],
              type: 'best_fields',
              fuzziness: 'AUTO',
            },
          }],
          filter: [
            { term: { status: 'active' } },
            // 추가 필터...
          ],
        },
      },
    };

    const result = await opensearchService.searchProducts(query);
    return result;
  }
}
```

**핵심 기능:**
- 3계층 캐싱 전략 (Redis → DB → OpenSearch)
- 비동기 작업 처리 (조회수, 인덱싱)
- 이벤트 기반 아키텍처
- 에러 핸들링

### 10. Controller 계층 (controllers/ProductController.ts)

```typescript
// src/controllers/ProductController.ts
import { Response, NextFunction } from 'express';
import { productService } from '@services/ProductService';
import { AuthRequest } from '@types/index';

export class ProductController {
  async getProducts(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const query = req.query;
      const result = await productService.getProducts(query);

      res.json({
        success: true,
        data: result.data,
        meta: result.meta,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  }

  async createProduct(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const data = req.body;
      const userId = req.user!.userId;

      const product = await productService.createProduct(data, userId);

      res.status(201).json({
        success: true,
        data: product,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  }
}
```

**핵심 기능:**
- HTTP 요청/응답 처리
- 인증 사용자 정보 활용
- 표준화된 응답 형식

### 11. 미들웨어 (middlewares/)

#### 인증 미들웨어 (auth.middleware.ts)

```typescript
// src/middlewares/auth.middleware.ts
import jwt from 'jsonwebtoken';

export const authenticate = async (req: AuthRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    throw new UnauthorizedError('No token provided');
  }

  const token = authHeader.substring(7);
  const decoded = jwt.verify(token, JWT_SECRET) as AuthUser;
  req.user = decoded;
  next();
};

export const authorize = (...roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }
    next();
  };
};
```

#### 검증 미들웨어 (validation.middleware.ts)

```typescript
// src/middlewares/validation.middleware.ts
import Joi from 'joi';

export const validate = (schema: Joi.ObjectSchema, property: 'body' | 'query' | 'params' = 'body') => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error, value } = schema.validate(req[property], {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const details = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message,
      }));
      return next(new ValidationError('Validation failed', details));
    }

    req[property] = value;
    next();
  };
};
```

### 12. 이벤트 발행 (events/publishers/EventPublisher.ts)

```typescript
// src/events/publishers/EventPublisher.ts
import { EventBridgeClient, PutEventsCommand } from '@aws-sdk/client-eventbridge';

export class EventPublisher {
  private async publishEvent(eventType: string, data: any, userId?: string) {
    const event = {
      eventId: uuidv4(),
      eventType,
      eventVersion: 'v1',
      timestamp: new Date().toISOString(),
      source: 'product-service',
      correlationId: uuidv4(),
      userId,
      metadata: {
        traceId: uuidv4(),
        environment: process.env.NODE_ENV,
      },
      data,
    };

    const command = new PutEventsCommand({
      Entries: [{
        EventBusName: 'doa-market-event-bus',
        Source: 'product-service',
        DetailType: eventType,
        Detail: JSON.stringify(event),
      }],
    });

    await eventBridgeClient.send(command);
  }

  async publishProductCreated(data: any) {
    await this.publishEvent('product.created', data, data.userId);
  }
}
```

**핵심 기능:**
- EventBridge 통합
- 표준화된 이벤트 구조
- Correlation ID를 통한 추적

### 13. 이벤트 소비 (events/consumers/OrderEventConsumer.ts)

```typescript
// src/events/consumers/OrderEventConsumer.ts
export class OrderEventConsumer {
  async handleOrderCreated(event: any): Promise<void> {
    const { orderId, items } = event.detail.data;

    for (const item of items) {
      const { productId, quantity } = item;

      // 재고 감소
      await productRepository.updateStock(productId, -quantity);

      // 재고 업데이트 이벤트 발행
      await eventPublisher.publishProductStockUpdated({
        productId,
        oldStock: product.stockQuantity,
        newStock: product.stockQuantity - quantity,
        reason: `Order created: ${orderId}`,
      });

      // 재고 소진 시 상태 변경
      if (product.stockQuantity - quantity <= 0) {
        await productRepository.update(productId, { status: 'out_of_stock' });
      }
    }
  }

  async handleOrderCancelled(event: any): Promise<void> {
    const { orderId, items } = event.detail.data;

    for (const item of items) {
      // 재고 복구
      await productRepository.updateStock(productId, quantity);
    }
  }
}
```

**핵심 기능:**
- SQS 메시지 처리
- Saga 패턴 구현
- 재고 관리 자동화

### 14. 라우트 정의 (routes/product.routes.ts)

```typescript
// src/routes/product.routes.ts
import { Router } from 'express';
import { productController } from '@controllers/ProductController';
import { authenticate, authorize } from '@middlewares/auth.middleware';
import { validate } from '@middlewares/validation.middleware';
import { createProductSchema } from '@dto/product.dto';

const router = Router();

// GET /api/v1/products
router.get('/', productController.getProducts);

// GET /api/v1/products/:id
router.get('/:id', productController.getProductById);

// POST /api/v1/products
router.post(
  '/',
  authenticate,
  authorize('admin', 'seller'),
  validate(createProductSchema, 'body'),
  productController.createProduct
);

// PUT /api/v1/products/:id
router.put(
  '/:id',
  authenticate,
  authorize('admin', 'seller'),
  validate(updateProductSchema, 'body'),
  productController.updateProduct
);

export default router;
```

**핵심 기능:**
- RESTful API 설계
- 인증/인가 미들웨어
- 자동 검증

## Docker 이미지 빌드

### Dockerfile

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY src ./src
RUN npm run build

# Production stage
FROM node:20-alpine
RUN apk add --no-cache dumb-init
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
USER nodejs
EXPOSE 3003
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3003/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]
```

**빌드 및 실행:**

```bash
# 빌드
docker build -t product-service:latest .

# 실행
docker run -p 3003:3003 \
  -e DB_HOST=postgres \
  -e REDIS_HOST=redis \
  -e OPENSEARCH_NODE=https://opensearch:9200 \
  product-service:latest
```

## 환경 변수 설정 (.env.example)

```bash
# Application
NODE_ENV=production
PORT=3003
SERVICE_NAME=product-service

# Database
DB_HOST=products-db.cluster-xxx.ap-northeast-2.rds.amazonaws.com
DB_PORT=5432
DB_NAME=products_db
DB_USER=postgres
DB_PASSWORD=<from_secrets_manager>

# Redis
REDIS_HOST=doa-market-cache.xxx.cache.amazonaws.com
REDIS_PORT=6379

# OpenSearch
OPENSEARCH_NODE=https://search-doa-market.ap-northeast-2.es.amazonaws.com
OPENSEARCH_USERNAME=admin
OPENSEARCH_PASSWORD=<from_secrets_manager>

# AWS
AWS_REGION=ap-northeast-2
EVENTBRIDGE_BUS_NAME=doa-market-event-bus

# JWT
JWT_SECRET=<from_secrets_manager>

# Monitoring
XRAY_ENABLED=true
LOG_LEVEL=info
CLOUDWATCH_LOG_GROUP=/ecs/product-service
```

## 패키지 구조

### package.json

```json
{
  "name": "@doa-market/product-service",
  "version": "1.0.0",
  "scripts": {
    "dev": "nodemon --exec ts-node src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest",
    "migration:generate": "typeorm migration:generate",
    "migration:run": "typeorm migration:run"
  },
  "dependencies": {
    "express": "^4.18.2",
    "typeorm": "^0.3.17",
    "pg": "^8.11.3",
    "ioredis": "^5.3.2",
    "@opensearch-project/opensearch": "^2.5.0",
    "@aws-sdk/client-eventbridge": "^3.470.0",
    "aws-xray-sdk": "^3.5.3",
    "joi": "^17.11.0",
    "jsonwebtoken": "^9.0.2",
    "winston": "^3.11.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/node": "^20.10.5",
    "typescript": "^5.3.3",
    "ts-node": "^10.9.2",
    "nodemon": "^3.0.2"
  }
}
```

## 공통 패키지 (backend/packages/common)

모든 서비스에서 공유하는 공통 타입, 유틸리티를 별도 패키지로 관리합니다.

```typescript
// packages/common/src/types/events.ts
export enum EventTypes {
  PRODUCT_CREATED = 'product.created',
  ORDER_CREATED = 'order.created',
  PAYMENT_COMPLETED = 'payment.completed',
  // ...
}

export interface BaseEvent {
  eventId: string;
  eventType: string;
  timestamp: string;
  source: string;
  data: any;
}
```

**사용법:**

```typescript
import { EventTypes, BaseEvent } from '@doa-market/common';
```

## API 엔드포인트 테스트

### cURL 예시

```bash
# 상품 목록 조회
curl -X GET "http://localhost:3003/api/v1/products?page=1&limit=20"

# 상품 상세 조회
curl -X GET "http://localhost:3003/api/v1/products/550e8400-e29b-41d4-a716-446655440000"

# 상품 생성
curl -X POST "http://localhost:3003/api/v1/products" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "sellerId": "550e8400-e29b-41d4-a716-446655440001",
    "categoryId": "550e8400-e29b-41d4-a716-446655440002",
    "name": "삼성 갤럭시 노트북",
    "slug": "samsung-galaxy-notebook",
    "price": 1290000
  }'

# 상품 검색
curl -X GET "http://localhost:3003/api/v1/products/search?search=노트북&page=1&limit=20"
```

## 다른 서비스 구현

동일한 구조로 다음 서비스들을 구현할 수 있습니다:

- **order-service** (포트 3004)
- **payment-service** (포트 3005)
- **auth-service** (포트 3001)
- **inventory-service** (포트 3009)
- ... (총 16개 서비스)

각 서비스는 동일한 폴더 구조와 패턴을 따르며, 도메인별 비즈니스 로직만 다르게 구현됩니다.

## 핵심 설계 원칙

1. **계층 분리 (Layered Architecture)**
   - Controller → Service → Repository → Database
   - 각 계층은 명확한 책임을 가짐

2. **의존성 주입 (Dependency Injection)**
   - 느슨한 결합
   - 테스트 용이성

3. **이벤트 기반 아키텍처**
   - 서비스 간 느슨한 결합
   - 비동기 처리

4. **캐싱 전략**
   - Redis 캐싱으로 DB 부하 감소
   - TTL 기반 자동 만료

5. **에러 핸들링**
   - 중앙 집중식 에러 처리
   - 표준화된 에러 응답

6. **보안**
   - JWT 인증
   - Role 기반 인가
   - Rate limiting

7. **모니터링**
   - 구조화된 로깅 (Winston)
   - 분산 트레이싱 (X-Ray)
   - Health check 엔드포인트

## 다음 단계

다음 문서에서는:
- Next.js 관리자/판매자 페이지 구조 코드
- Flutter 앱 폴더 구조 및 기본 화면 코드
- 이벤트 기반 주문 처리 흐름 구현 예시

를 다룹니다.
