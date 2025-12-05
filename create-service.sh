#!/bin/bash

# DOA Market - 서비스 생성 스크립트
# Usage: ./create-service.sh <service-name> <port> <db-name>

SERVICE_NAME=$1
PORT=$2
DB_NAME=$3
SERVICE_DIR="backend/services/$SERVICE_NAME"

if [ -z "$SERVICE_NAME" ] || [ -z "$PORT" ] || [ -z "$DB_NAME" ]; then
    echo "Usage: ./create-service.sh <service-name> <port> <db-name>"
    exit 1
fi

echo "Creating $SERVICE_NAME on port $PORT with database $DB_NAME..."

# Create directory structure
mkdir -p "$SERVICE_DIR/src"/{config,controllers,middlewares,models,routes,services,utils,types}

# Create package.json
cat > "$SERVICE_DIR/package.json" <<EOF
{
  "name": "@doa-market/$SERVICE_NAME",
  "version": "1.0.0",
  "description": "DOA Market $SERVICE_NAME",
  "main": "dist/server.js",
  "scripts": {
    "dev": "nodemon --exec ts-node -r tsconfig-paths/register src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js"
  },
  "keywords": ["microservice"],
  "author": "DOA Market Team",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "typeorm": "^0.3.17",
    "pg": "^8.11.3",
    "redis": "^4.6.8",
    "ioredis": "^5.3.2",
    "dotenv": "^16.3.1",
    "joi": "^17.10.1",
    "uuid": "^9.0.1",
    "winston": "^3.10.0",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "compression": "^1.7.4"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/node": "^20.5.9",
    "@types/uuid": "^9.0.4",
    "@types/cors": "^2.8.14",
    "@types/compression": "^1.7.3",
    "typescript": "^5.2.2",
    "ts-node": "^10.9.1",
    "tsconfig-paths": "^4.2.0",
    "nodemon": "^3.0.1"
  }
}
EOF

# Create tsconfig.json
cat > "$SERVICE_DIR/tsconfig.json" <<EOF
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "strictPropertyInitialization": false,
    "baseUrl": "./src",
    "paths": {
      "@/*": ["*"],
      "@config/*": ["config/*"],
      "@controllers/*": ["controllers/*"],
      "@services/*": ["services/*"],
      "@models/*": ["models/*"],
      "@middlewares/*": ["middlewares/*"],
      "@routes/*": ["routes/*"],
      "@utils/*": ["utils/*"],
      "@types/*": ["types/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

# Create .env
cat > "$SERVICE_DIR/.env" <<EOF
NODE_ENV=development
PORT=$PORT
SERVICE_NAME=$SERVICE_NAME
LOG_LEVEL=debug

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=$DB_NAME
DB_USER=postgres
DB_PASSWORD=postgres
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
CACHE_ENABLED=false

# API
API_VERSION=v1
API_PREFIX=/api/v1
CORS_ORIGINS=http://localhost:3000

# Monitoring
XRAY_ENABLED=false
CLOUDWATCH_ENABLED=false
METRICS_ENABLED=false
EOF

# Create basic server.ts
cat > "$SERVICE_DIR/src/server.ts" <<'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGINS?.split(',') || '*' }));
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/api/v1/health', (req, res) => {
  res.json({
    success: true,
    data: {
      service: process.env.SERVICE_NAME,
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    },
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    service: process.env.SERVICE_NAME,
    version: '1.0.0',
    status: 'running',
  });
});

// Start server
app.listen(PORT, () => {
  console.log(\`\${process.env.SERVICE_NAME} running on port \${PORT}\`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  process.exit(0);
});
EOF

# Create basic logger
cat > "$SERVICE_DIR/src/utils/logger.ts" <<'EOF'
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      ),
    }),
  ],
});

export default logger;
EOF

# Create README
cat > "$SERVICE_DIR/README.md" <<EOF
# $SERVICE_NAME

## Description
DOA Market - $SERVICE_NAME

## Port
$PORT

## Database
$DB_NAME

## Getting Started

\`\`\`bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Build
npm run build

# Run in production
npm start
\`\`\`

## API Endpoints

### Health Check
\`\`\`
GET /api/v1/health
\`\`\`

## Environment Variables
See \`.env\` file for configuration options.
EOF

echo "✅ $SERVICE_NAME created successfully!"
echo "📁 Location: $SERVICE_DIR"
echo "🚀 To start: cd $SERVICE_DIR && npm install && npm run dev"
