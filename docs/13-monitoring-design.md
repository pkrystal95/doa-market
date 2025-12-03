# 13. 모니터링 설계 (Monitoring Design)

## 목차
1. [모니터링 아키텍처](#1-모니터링-아키텍처)
2. [CloudWatch Metrics](#2-cloudwatch-metrics)
3. [CloudWatch Dashboards](#3-cloudwatch-dashboards)
4. [CloudWatch Logs](#4-cloudwatch-logs)
5. [X-Ray 분산 추적](#5-x-ray-분산-추적)
6. [OpenSearch 로그 분석](#6-opensearch-로그-분석)
7. [알람 전략](#7-알람-전략)
8. [SLI/SLO/SLA](#8-slislosla)
9. [성능 모니터링](#9-성능-모니터링)
10. [비용 모니터링](#10-비용-모니터링)

---

## 1. 모니터링 아키텍처

### 1.1 전체 모니터링 구조

```
┌─────────────────────────────────────────────────────────────┐
│                      애플리케이션 계층                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Next.js  │  │ Flutter  │  │  ECS     │  │ Lambda   │   │
│  │  (Web)   │  │  (App)   │  │ Services │  │Functions │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │              │          │
│       └─────────────┴──────────────┴──────────────┘          │
│                          ↓                                    │
└──────────────────────────┼──────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                      수집 계층 (Collection)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ CloudWatch   │  │  AWS X-Ray   │  │ CloudWatch   │      │
│  │   Metrics    │  │   Tracing    │  │    Logs      │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          ↓                  ↓                  ↓
┌─────────────────────────────────────────────────────────────┐
│                   저장 및 분석 계층                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ CloudWatch   │  │  X-Ray       │  │ OpenSearch   │      │
│  │ Log Groups   │  │  Service Map │  │  (Logs)      │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          ↓                  ↓                  ↓
┌─────────────────────────────────────────────────────────────┐
│                     시각화 계층                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ CloudWatch   │  │  X-Ray       │  │ OpenSearch   │      │
│  │ Dashboards   │  │  Console     │  │ Dashboards   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────────────────────────┐
│                     알림 계층                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ CloudWatch   │  │  SNS Topic   │  │  EventBridge │      │
│  │   Alarms     │  │  (Alerts)    │  │    Rules     │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         └──────────────────┴──────────────────┘              │
└─────────────────────────────┬───────────────────────────────┘
                              ↓
                    ┌──────────────────┐
                    │  Slack / Email   │
                    │  PagerDuty       │
                    └──────────────────┘
```

### 1.2 로깅 전략

**로그 레벨**
```typescript
enum LogLevel {
  ERROR = 'error',   // 서비스 중단, 즉시 조치 필요
  WARN = 'warn',     // 잠재적 문제, 모니터링 필요
  INFO = 'info',     // 일반적인 정보, 비즈니스 이벤트
  DEBUG = 'debug',   // 디버깅 정보 (개발/스테이징 전용)
  TRACE = 'trace',   // 상세 추적 (개발 전용)
}
```

**환경별 로그 레벨**
```
Production:   INFO, WARN, ERROR
Staging:      DEBUG, INFO, WARN, ERROR
Development:  TRACE, DEBUG, INFO, WARN, ERROR
```

### 1.3 메트릭 수집 주기

```
Infrastructure Metrics:  1분 간격 (기본)
Application Metrics:     1분 간격
Custom Business Metrics: 1분 간격
Detailed Monitoring:     고해상도 (1초 간격, 비용 주의)
```

---

## 2. CloudWatch Metrics

### 2.1 ECS 컨테이너 메트릭

**Container Insights 활성화**

**`infrastructure/cloudwatch/ecs-container-insights.json`**
```json
{
  "clusterName": "doa-market-cluster",
  "clusterSettings": [
    {
      "name": "containerInsights",
      "value": "enabled"
    }
  ]
}
```

**수집되는 메트릭**
```
ECS Cluster 레벨:
- CPUUtilization
- MemoryUtilization
- NetworkRxBytes / NetworkTxBytes
- TaskCount (Running, Pending, Stopped)

ECS Service 레벨:
- CPUUtilization (서비스별)
- MemoryUtilization (서비스별)
- RunningTaskCount
- DesiredTaskCount
- PendingTaskCount

ECS Task 레벨:
- task_cpu_utilized
- task_memory_utilized
- task_network_rx_bytes
- task_network_tx_bytes
```

### 2.2 ALB 메트릭

**주요 메트릭**
```
요청 메트릭:
- RequestCount (총 요청 수)
- HTTPCode_Target_2XX_Count (성공)
- HTTPCode_Target_4XX_Count (클라이언트 에러)
- HTTPCode_Target_5XX_Count (서버 에러)
- HTTPCode_ELB_5XX_Count (ALB 에러)

성능 메트릭:
- TargetResponseTime (평균, p50, p90, p99)
- ActiveConnectionCount
- NewConnectionCount
- ProcessedBytes

헬스체크 메트릭:
- HealthyHostCount
- UnHealthyHostCount
- TargetConnectionErrorCount
```

### 2.3 RDS 메트릭

**주요 메트릭**
```
성능 메트릭:
- CPUUtilization
- FreeableMemory
- SwapUsage
- DatabaseConnections
- ReadLatency / WriteLatency
- ReadThroughput / WriteThroughput
- ReadIOPS / WriteIOPS

용량 메트릭:
- FreeStorageSpace
- BurstBalance (gp2/gp3 볼륨)

복제 메트릭:
- ReplicaLag (Read Replica)
- BinLogDiskUsage
```

### 2.4 DynamoDB 메트릭

**주요 메트릭**
```
용량 메트릭:
- ConsumedReadCapacityUnits
- ConsumedWriteCapacityUnits
- ProvisionedReadCapacityUnits
- ProvisionedWriteCapacityUnits

스로틀링 메트릭:
- UserErrors (400 에러)
- SystemErrors (500 에러)
- ThrottledRequests

성능 메트릭:
- SuccessfulRequestLatency (GetItem, PutItem, Query, Scan)
- ConditionalCheckFailedRequests
```

### 2.5 Lambda 메트릭

**주요 메트릭**
```
호출 메트릭:
- Invocations (총 호출 수)
- Errors (에러 발생 수)
- Throttles (스로틀링 발생)
- DeadLetterErrors (DLQ 전송 실패)

성능 메트릭:
- Duration (평균, p50, p90, p99, Max)
- IteratorAge (스트림 이벤트 소스)
- ConcurrentExecutions (동시 실행 수)

비용 메트릭:
- Invocations × Duration = GB-seconds
```

### 2.6 커스텀 애플리케이션 메트릭

**비즈니스 메트릭**

**`backend/services/order-service/src/monitoring/metrics.ts`**
```typescript
import { CloudWatchClient, PutMetricDataCommand } from '@aws-sdk/client-cloudwatch';

const cloudwatch = new CloudWatchClient({ region: process.env.AWS_REGION });

export class MetricsPublisher {
  private namespace = 'DOAMarket/Application';

  /**
   * 주문 생성 메트릭
   */
  async recordOrderCreated(amount: number, paymentMethod: string): Promise<void> {
    await cloudwatch.send(
      new PutMetricDataCommand({
        Namespace: this.namespace,
        MetricData: [
          {
            MetricName: 'OrderCreated',
            Value: 1,
            Unit: 'Count',
            Timestamp: new Date(),
            Dimensions: [
              { Name: 'PaymentMethod', Value: paymentMethod },
              { Name: 'Environment', Value: process.env.NODE_ENV || 'production' },
            ],
          },
          {
            MetricName: 'OrderAmount',
            Value: amount,
            Unit: 'None',
            Timestamp: new Date(),
            Dimensions: [
              { Name: 'PaymentMethod', Value: paymentMethod },
            ],
          },
        ],
      })
    );
  }

  /**
   * 결제 처리 시간 메트릭
   */
  async recordPaymentDuration(duration: number, success: boolean): Promise<void> {
    await cloudwatch.send(
      new PutMetricDataCommand({
        Namespace: this.namespace,
        MetricData: [
          {
            MetricName: 'PaymentDuration',
            Value: duration,
            Unit: 'Milliseconds',
            Timestamp: new Date(),
            Dimensions: [
              { Name: 'Status', Value: success ? 'Success' : 'Failed' },
            ],
          },
        ],
      })
    );
  }

  /**
   * API 응답 시간 메트릭
   */
  async recordAPILatency(
    endpoint: string,
    method: string,
    statusCode: number,
    duration: number
  ): Promise<void> {
    await cloudwatch.send(
      new PutMetricDataCommand({
        Namespace: this.namespace,
        MetricData: [
          {
            MetricName: 'APILatency',
            Value: duration,
            Unit: 'Milliseconds',
            Timestamp: new Date(),
            Dimensions: [
              { Name: 'Endpoint', Value: endpoint },
              { Name: 'Method', Value: method },
              { Name: 'StatusCode', Value: statusCode.toString() },
            ],
          },
        ],
      })
    );
  }

  /**
   * 재고 부족 메트릭
   */
  async recordInventoryShortage(productId: string, requestedQty: number): Promise<void> {
    await cloudwatch.send(
      new PutMetricDataCommand({
        Namespace: this.namespace,
        MetricData: [
          {
            MetricName: 'InventoryShortage',
            Value: 1,
            Unit: 'Count',
            Timestamp: new Date(),
            Dimensions: [
              { Name: 'ProductId', Value: productId },
            ],
          },
        ],
      })
    );
  }

  /**
   * Saga 보상 트랜잭션 메트릭
   */
  async recordSagaCompensation(sagaType: string, step: string): Promise<void> {
    await cloudwatch.send(
      new PutMetricDataCommand({
        Namespace: this.namespace,
        MetricData: [
          {
            MetricName: 'SagaCompensation',
            Value: 1,
            Unit: 'Count',
            Timestamp: new Date(),
            Dimensions: [
              { Name: 'SagaType', Value: sagaType },
              { Name: 'Step', Value: step },
            ],
          },
        ],
      })
    );
  }
}
```

**Express 미들웨어로 자동 수집**

**`backend/services/product-service/src/middlewares/metrics.middleware.ts`**
```typescript
import { Request, Response, NextFunction } from 'express';
import { MetricsPublisher } from '../monitoring/metrics';

const metricsPublisher = new MetricsPublisher();

export const metricsMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const startTime = Date.now();

  // Response가 완료되면 메트릭 기록
  res.on('finish', async () => {
    const duration = Date.now() - startTime;
    const endpoint = req.route?.path || req.path;
    const method = req.method;
    const statusCode = res.statusCode;

    try {
      await metricsPublisher.recordAPILatency(endpoint, method, statusCode, duration);
    } catch (error) {
      console.error('Failed to record metrics:', error);
    }
  });

  next();
};
```

**사용 예시**
```typescript
// app.ts
import { metricsMiddleware } from './middlewares/metrics.middleware';

app.use(metricsMiddleware);
```

---

## 3. CloudWatch Dashboards

### 3.1 전체 시스템 대시보드

**`infrastructure/cloudwatch/dashboards/system-overview.json`**
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "title": "전체 요청 수 (ALB)",
        "metrics": [
          ["AWS/ApplicationELB", "RequestCount", { "stat": "Sum" }]
        ],
        "period": 300,
        "region": "ap-northeast-2",
        "yAxis": {
          "left": { "min": 0 }
        }
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "4xx/5xx 에러율",
        "metrics": [
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_4XX_Count",
            { "stat": "Sum", "label": "4xx Errors" }
          ],
          [
            ".",
            "HTTPCode_Target_5XX_Count",
            { "stat": "Sum", "label": "5xx Errors" }
          ]
        ],
        "period": 300,
        "region": "ap-northeast-2"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "평균 응답 시간 (p50, p90, p99)",
        "metrics": [
          [
            "AWS/ApplicationELB",
            "TargetResponseTime",
            { "stat": "p50", "label": "p50" }
          ],
          ["...", { "stat": "p90", "label": "p90" }],
          ["...", { "stat": "p99", "label": "p99" }]
        ],
        "period": 300,
        "region": "ap-northeast-2",
        "yAxis": {
          "left": { "min": 0 }
        }
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "ECS CPU 사용률",
        "metrics": [
          [
            "AWS/ECS",
            "CPUUtilization",
            { "stat": "Average" },
            { "dimensions": { "ServiceName": "product-service" } }
          ],
          [
            "...",
            { "dimensions": { "ServiceName": "order-service" } }
          ],
          [
            "...",
            { "dimensions": { "ServiceName": "payment-service" } }
          ]
        ],
        "period": 300,
        "region": "ap-northeast-2"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "RDS CPU 및 연결 수",
        "metrics": [
          [
            "AWS/RDS",
            "CPUUtilization",
            { "stat": "Average" },
            { "dimensions": { "DBClusterIdentifier": "product-db" } }
          ],
          [
            "AWS/RDS",
            "DatabaseConnections",
            { "stat": "Average", "yAxis": "right" },
            { "dimensions": { "DBClusterIdentifier": "product-db" } }
          ]
        ],
        "period": 300,
        "region": "ap-northeast-2"
      }
    },
    {
      "type": "log",
      "properties": {
        "title": "최근 에러 로그",
        "query": "SOURCE '/ecs/product-service'\n| SOURCE '/ecs/order-service'\n| SOURCE '/ecs/payment-service'\n| fields @timestamp, @message, level, service\n| filter level = 'error'\n| sort @timestamp desc\n| limit 20",
        "region": "ap-northeast-2"
      }
    }
  ]
}
```

### 3.2 서비스별 대시보드 (Order Service 예시)

**`infrastructure/cloudwatch/dashboards/order-service.json`**
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "title": "주문 생성 수 (시간당)",
        "metrics": [
          [
            "DOAMarket/Application",
            "OrderCreated",
            { "stat": "Sum" }
          ]
        ],
        "period": 3600,
        "region": "ap-northeast-2"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "결제 수단별 주문 수",
        "metrics": [
          [
            "DOAMarket/Application",
            "OrderCreated",
            { "dimensions": { "PaymentMethod": "credit_card" } }
          ],
          [
            "...",
            { "dimensions": { "PaymentMethod": "bank_transfer" } }
          ],
          [
            "...",
            { "dimensions": { "PaymentMethod": "virtual_account" } }
          ]
        ],
        "period": 3600,
        "region": "ap-northeast-2"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "Saga 보상 트랜잭션 발생 횟수",
        "metrics": [
          [
            "DOAMarket/Application",
            "SagaCompensation",
            { "stat": "Sum" }
          ]
        ],
        "period": 300,
        "region": "ap-northeast-2"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "Order Service API 지연 시간",
        "metrics": [
          [
            "DOAMarket/Application",
            "APILatency",
            { "dimensions": { "Endpoint": "/api/v1/orders" }, "stat": "Average" }
          ],
          [
            "...",
            { "stat": "p90" }
          ],
          [
            "...",
            { "stat": "p99" }
          ]
        ],
        "period": 300,
        "region": "ap-northeast-2"
      }
    }
  ]
}
```

### 3.3 비즈니스 메트릭 대시보드

**`infrastructure/cloudwatch/dashboards/business-metrics.json`**
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "title": "일일 매출 (Order Amount)",
        "metrics": [
          [
            "DOAMarket/Application",
            "OrderAmount",
            { "stat": "Sum" }
          ]
        ],
        "period": 86400,
        "region": "ap-northeast-2"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "시간당 신규 회원가입",
        "metrics": [
          [
            "DOAMarket/Application",
            "UserRegistered",
            { "stat": "Sum" }
          ]
        ],
        "period": 3600,
        "region": "ap-northeast-2"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "재고 부족 발생 횟수",
        "metrics": [
          [
            "DOAMarket/Application",
            "InventoryShortage",
            { "stat": "Sum" }
          ]
        ],
        "period": 3600,
        "region": "ap-northeast-2"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "결제 성공률",
        "metrics": [
          [
            {
              "expression": "(m1 / (m1 + m2)) * 100",
              "label": "Success Rate (%)",
              "id": "e1"
            }
          ],
          [
            "DOAMarket/Application",
            "PaymentDuration",
            { "dimensions": { "Status": "Success" }, "stat": "SampleCount", "id": "m1", "visible": false }
          ],
          [
            "...",
            { "dimensions": { "Status": "Failed" }, "stat": "SampleCount", "id": "m2", "visible": false }
          ]
        ],
        "period": 300,
        "region": "ap-northeast-2"
      }
    }
  ]
}
```

---

## 4. CloudWatch Logs

### 4.1 로그 그룹 구조

```
/ecs/
├── auth-service
├── user-service
├── product-service
├── order-service
├── payment-service
├── inventory-service
├── shipping-service
├── notification-service
├── review-service
├── coupon-service
├── seller-service
├── settlement-service
├── search-service
├── stats-service
├── admin-service
└── file-service

/aws/lambda/
├── image-resize-function
├── order-event-consumer
├── payment-event-consumer
└── notification-sender

/aws/rds/cluster/
├── product-db/postgresql
├── order-db/postgresql
├── user-db/postgresql
├── payment-db/postgresql
├── inventory-db/postgresql
├── shipping-db/postgresql
└── seller-db/postgresql

/aws/vpc/
└── doa-market-vpc-flow-logs

/aws/cloudtrail/
└── doa-market-trail
```

### 4.2 구조화된 로그 포맷

**JSON 형식 로그**

**`backend/services/product-service/src/config/logger.ts`**
```typescript
import winston from 'winston';
import CloudWatchTransport from 'winston-cloudwatch';

const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  defaultMeta: {
    service: 'product-service',
    environment: process.env.NODE_ENV,
    version: process.env.APP_VERSION,
  },
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      ),
    }),
    new CloudWatchTransport({
      logGroupName: '/ecs/product-service',
      logStreamName: `${process.env.NODE_ENV}-${new Date().toISOString().split('T')[0]}`,
      awsRegion: process.env.AWS_REGION,
      jsonMessage: true,
    }),
  ],
});

// 요청 로깅 헬퍼
export function logRequest(req: any, additionalData?: any) {
  logger.info('HTTP Request', {
    method: req.method,
    url: req.url,
    path: req.path,
    query: req.query,
    userId: req.user?.id,
    correlationId: req.headers['x-correlation-id'],
    traceId: req.headers['x-amzn-trace-id'],
    userAgent: req.headers['user-agent'],
    ip: req.ip,
    ...additionalData,
  });
}

// 에러 로깅 헬퍼
export function logError(error: Error, context?: any) {
  logger.error('Error occurred', {
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
    },
    ...context,
  });
}
```

**로그 출력 예시**
```json
{
  "timestamp": "2024-01-15 10:30:45.123",
  "level": "info",
  "message": "HTTP Request",
  "service": "product-service",
  "environment": "production",
  "version": "1.2.3",
  "method": "GET",
  "url": "/api/v1/products/123",
  "path": "/api/v1/products/123",
  "userId": "user-456",
  "correlationId": "abc-123-def-456",
  "traceId": "1-5f9a2b3c-4d5e6f7g8h9i0j1k2l3m4n",
  "userAgent": "Mozilla/5.0...",
  "ip": "203.0.113.42"
}
```

### 4.3 CloudWatch Logs Insights 쿼리

#### 4.3.1 에러 분석

**최근 1시간 에러 로그 (서비스별 집계)**
```
fields @timestamp, service, @message, error.message
| filter level = "error"
| stats count() as errorCount by service
| sort errorCount desc
```

**특정 에러 타입 추적**
```
fields @timestamp, service, error.name, error.message, error.stack, userId, correlationId
| filter error.name = "PaymentGatewayError"
| sort @timestamp desc
| limit 50
```

#### 4.3.2 성능 분석

**API 엔드포인트별 평균 응답 시간**
```
fields @timestamp, path, duration
| filter @type = "request"
| stats avg(duration) as avgDuration, max(duration) as maxDuration, count() as requestCount by path
| sort avgDuration desc
```

**느린 요청 추적 (> 1초)**
```
fields @timestamp, method, url, duration, userId, correlationId
| filter duration > 1000
| sort duration desc
| limit 100
```

#### 4.3.3 사용자 행동 추적

**특정 사용자의 최근 활동**
```
fields @timestamp, method, path, statusCode, duration
| filter userId = "user-123"
| sort @timestamp desc
| limit 50
```

**Correlation ID로 전체 요청 추적**
```
fields @timestamp, service, level, @message
| filter correlationId = "abc-123-def-456"
| sort @timestamp asc
```

#### 4.3.4 비즈니스 인사이트

**시간대별 주문 생성 패턴**
```
fields @timestamp, orderId, amount
| filter @message like /Order created/
| stats count() as orderCount, sum(amount) as totalAmount by bin(@timestamp, 1h)
```

**결제 실패 원인 분석**
```
fields @timestamp, error.message, paymentMethod
| filter @message like /Payment failed/
| stats count() as failureCount by error.message, paymentMethod
| sort failureCount desc
```

### 4.4 로그 보존 정책

**Log Group Retention**
```json
{
  "/ecs/*": {
    "retentionInDays": 30,
    "kmsKeyId": "arn:aws:kms:ap-northeast-2:ACCOUNT_ID:key/xxxxx"
  },
  "/aws/lambda/*": {
    "retentionInDays": 14
  },
  "/aws/rds/cluster/*": {
    "retentionInDays": 90
  },
  "/aws/vpc/*": {
    "retentionInDays": 7
  },
  "/aws/cloudtrail/*": {
    "retentionInDays": 365
  }
}
```

**S3 장기 보관 (Compliance)**
```
CloudWatch Logs → Kinesis Firehose → S3 (Glacier)
보존 기간: 7년 (개인정보보호법 준수)
```

---

## 5. X-Ray 분산 추적

### 5.1 X-Ray 설정

**ECS Task Definition에 X-Ray 데몬 추가**

**`infrastructure/ecs/product-service-xray.json`**
```json
{
  "family": "product-service",
  "containerDefinitions": [
    {
      "name": "product-service",
      "image": "ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/product-service:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "AWS_XRAY_DAEMON_ADDRESS",
          "value": "xray-daemon:2000"
        },
        {
          "name": "AWS_XRAY_CONTEXT_MISSING",
          "value": "LOG_ERROR"
        }
      ]
    },
    {
      "name": "xray-daemon",
      "image": "public.ecr.aws/xray/aws-xray-daemon:latest",
      "cpu": 32,
      "memoryReservation": 256,
      "portMappings": [
        {
          "containerPort": 2000,
          "protocol": "udp"
        }
      ]
    }
  ]
}
```

### 5.2 Express 앱에 X-Ray 미들웨어 적용

**`backend/services/product-service/src/app.ts`**
```typescript
import express from 'express';
import AWSXRay from 'aws-xray-sdk-core';
import http from 'http';

// HTTP 및 AWS SDK 추적
AWSXRay.captureHTTPsGlobal(http);
AWSXRay.captureAWS(require('aws-sdk'));

const app = express();

// X-Ray 미들웨어 (가장 먼저 적용)
app.use(AWSXRay.express.openSegment('product-service'));

// 나머지 미들웨어 및 라우트
app.use(express.json());
app.use('/api/v1/products', productRoutes);

// X-Ray 세그먼트 종료 (마지막에 적용)
app.use(AWSXRay.express.closeSegment());

export default app;
```

### 5.3 커스텀 서브세그먼트

**데이터베이스 쿼리 추적**

**`backend/services/product-service/src/repositories/ProductRepository.ts`**
```typescript
import AWSXRay from 'aws-xray-sdk-core';

export class ProductRepository {
  async findById(id: string): Promise<Product | null> {
    const segment = AWSXRay.getSegment();
    const subsegment = segment?.addNewSubsegment('Database::findProductById');

    try {
      subsegment?.addAnnotation('productId', id);
      subsegment?.addMetadata('query', 'SELECT * FROM products WHERE id = $1');

      const product = await this.repository.findOne({ where: { id } });

      subsegment?.addMetadata('result', product ? 'found' : 'not_found');
      return product;
    } catch (error) {
      subsegment?.addError(error as Error);
      throw error;
    } finally {
      subsegment?.close();
    }
  }
}
```

**외부 API 호출 추적**

**`backend/services/payment-service/src/gateways/PaymentGateway.ts`**
```typescript
import AWSXRay from 'aws-xray-sdk-core';
import axios from 'axios';

export class PaymentGateway {
  async processPayment(data: PaymentRequest): Promise<PaymentResult> {
    const segment = AWSXRay.getSegment();
    const subsegment = segment?.addNewSubsegment('ExternalAPI::TossPayments');

    try {
      subsegment?.addAnnotation('paymentId', data.paymentId);
      subsegment?.addAnnotation('amount', data.amount);
      subsegment?.addMetadata('paymentMethod', data.paymentMethod);

      subsegment?.namespace = 'remote';
      const startTime = Date.now();

      const response = await axios.post(
        'https://api.tosspayments.com/v1/payments',
        data,
        {
          headers: { Authorization: `Bearer ${this.apiKey}` },
        }
      );

      const duration = Date.now() - startTime;
      subsegment?.addMetadata('duration_ms', duration);
      subsegment?.addMetadata('statusCode', response.status);

      return response.data;
    } catch (error) {
      subsegment?.addError(error as Error);
      throw error;
    } finally {
      subsegment?.close();
    }
  }
}
```

### 5.4 Saga 트랜잭션 추적

**`examples/event-driven-order-flow/order-service/OrderSaga.ts`**
```typescript
import AWSXRay from 'aws-xray-sdk-core';

export class OrderSaga {
  async createOrder(orderData: CreateOrderRequest): Promise<OrderSagaResult> {
    const segment = AWSXRay.getSegment();
    const sagaSegment = segment?.addNewSubsegment('Saga::CreateOrder');

    const sagaId = uuidv4();
    sagaSegment?.addAnnotation('sagaId', sagaId);
    sagaSegment?.addAnnotation('userId', orderData.userId);

    try {
      // Step 1: Create Order
      const orderSubsegment = sagaSegment?.addNewSubsegment('Saga::Step1::CreateOrder');
      const order = await this.createOrderStep(orderData, sagaId, correlationId);
      orderSubsegment?.addMetadata('orderId', order.id);
      orderSubsegment?.close();

      // Step 2: Reserve Inventory
      const inventorySubsegment = sagaSegment?.addNewSubsegment('Saga::Step2::ReserveInventory');
      await this.reserveInventoryStep(order, sagaId, correlationId);
      inventorySubsegment?.close();

      // Step 3: Process Payment
      const paymentSubsegment = sagaSegment?.addNewSubsegment('Saga::Step3::ProcessPayment');
      await this.processPaymentStep(order, sagaId, correlationId);
      paymentSubsegment?.close();

      // Step 4: Prepare Shipping
      const shippingSubsegment = sagaSegment?.addNewSubsegment('Saga::Step4::PrepareShipping');
      await this.prepareShippingStep(order, sagaId, correlationId);
      shippingSubsegment?.close();

      sagaSegment?.addAnnotation('result', 'success');
      return { success: true, orderId: order.id, sagaId };
    } catch (error) {
      sagaSegment?.addAnnotation('result', 'failed');
      sagaSegment?.addError(error as Error);

      // Compensation
      const compensationSegment = sagaSegment?.addNewSubsegment('Saga::Compensation');
      await this.compensate(sagaId, correlationId);
      compensationSegment?.close();

      return { success: false, error: error.message, sagaId };
    } finally {
      sagaSegment?.close();
    }
  }
}
```

### 5.5 X-Ray Service Map

**Service Map을 통해 시각화되는 정보**
```
Client
  ↓ (200ms avg)
ALB
  ↓ (50ms avg)
Order Service (ECS)
  ├─→ Product Service (50ms avg)
  ├─→ Inventory Service (30ms avg)
  ├─→ Payment Service (200ms avg)
  │   └─→ Toss Payments API (150ms avg)
  ├─→ RDS PostgreSQL (20ms avg)
  ├─→ DynamoDB (10ms avg)
  └─→ EventBridge (5ms avg)
```

**각 노드에 표시되는 메트릭**
- 평균 응답 시간
- 초당 요청 수 (TPS)
- 에러율
- 스로틀링 발생

### 5.6 X-Ray Insights 쿼리

**응답 시간이 느린 트레이스 찾기**
```
service("product-service") AND responsetime > 1
```

**에러가 발생한 트레이스**
```
service("payment-service") AND error
```

**특정 사용자의 트레이스**
```
annotation.userId = "user-123"
```

**Saga 보상 트랜잭션이 발생한 트레이스**
```
service("order-service") AND annotation.result = "failed"
```

---

## 6. OpenSearch 로그 분석

### 6.1 OpenSearch 클러스터 설정

**`infrastructure/opensearch/cluster-config.json`**
```json
{
  "DomainName": "doa-market-logs",
  "EngineVersion": "OpenSearch_2.11",
  "ClusterConfig": {
    "InstanceType": "r6g.large.search",
    "InstanceCount": 3,
    "DedicatedMasterEnabled": true,
    "DedicatedMasterType": "r6g.large.search",
    "DedicatedMasterCount": 3,
    "ZoneAwarenessEnabled": true,
    "ZoneAwarenessConfig": {
      "AvailabilityZoneCount": 3
    }
  },
  "EBSOptions": {
    "EBSEnabled": true,
    "VolumeType": "gp3",
    "VolumeSize": 100,
    "Iops": 3000,
    "Throughput": 125
  },
  "EncryptionAtRestOptions": {
    "Enabled": true
  },
  "NodeToNodeEncryptionOptions": {
    "Enabled": true
  },
  "DomainEndpointOptions": {
    "EnforceHTTPS": true
  },
  "AdvancedSecurityOptions": {
    "Enabled": true,
    "InternalUserDatabaseEnabled": false,
    "SAMLOptions": {
      "Enabled": false
    }
  }
}
```

### 6.2 CloudWatch Logs → OpenSearch 스트리밍

**Lambda 함수로 로그 전송**

**`infrastructure/lambda/cloudwatch-to-opensearch/index.ts`**
```typescript
import { CloudWatchLogsEvent, CloudWatchLogsDecodedData } from 'aws-lambda';
import { Client } from '@opensearch-project/opensearch';
import * as zlib from 'zlib';

const osClient = new Client({
  node: process.env.OPENSEARCH_ENDPOINT!,
  auth: {
    username: process.env.OPENSEARCH_USERNAME!,
    password: process.env.OPENSEARCH_PASSWORD!,
  },
});

export async function handler(event: CloudWatchLogsEvent) {
  // CloudWatch Logs 데이터 디코딩
  const payload = Buffer.from(event.awslogs.data, 'base64');
  const decompressed = zlib.gunzipSync(payload);
  const data: CloudWatchLogsDecodedData = JSON.parse(decompressed.toString('utf8'));

  const bulkBody = [];

  for (const logEvent of data.logEvents) {
    let message;
    try {
      message = JSON.parse(logEvent.message);
    } catch {
      message = { message: logEvent.message };
    }

    // OpenSearch 인덱스 액션
    bulkBody.push({
      index: {
        _index: `logs-${data.logGroup.replace(/\//g, '-')}-${new Date().toISOString().split('T')[0]}`,
        _id: logEvent.id,
      },
    });

    // 문서 본문
    bulkBody.push({
      '@timestamp': new Date(logEvent.timestamp).toISOString(),
      logGroup: data.logGroup,
      logStream: data.logStream,
      ...message,
    });
  }

  // Bulk 인덱싱
  await osClient.bulk({ body: bulkBody });

  return { statusCode: 200, body: 'Success' };
}
```

### 6.3 OpenSearch Index Templates

**로그 인덱스 템플릿**

**`infrastructure/opensearch/index-templates/logs-template.json`**
```json
{
  "index_patterns": ["logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 3,
      "number_of_replicas": 1,
      "index.refresh_interval": "5s",
      "index.lifecycle.name": "logs-lifecycle-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "level": { "type": "keyword" },
        "service": { "type": "keyword" },
        "environment": { "type": "keyword" },
        "message": { "type": "text" },
        "userId": { "type": "keyword" },
        "correlationId": { "type": "keyword" },
        "traceId": { "type": "keyword" },
        "method": { "type": "keyword" },
        "path": { "type": "keyword" },
        "statusCode": { "type": "integer" },
        "duration": { "type": "float" },
        "error": {
          "properties": {
            "name": { "type": "keyword" },
            "message": { "type": "text" },
            "stack": { "type": "text" }
          }
        }
      }
    }
  }
}
```

### 6.4 OpenSearch Dashboards

**대시보드 생성 (Kibana 형식)**

**주요 시각화**
1. **시간대별 로그 레벨 분포** (Stacked Bar Chart)
2. **서비스별 에러 발생 추이** (Line Chart)
3. **Top 10 에러 메시지** (Data Table)
4. **API 엔드포인트별 평균 응답 시간** (Heat Map)
5. **사용자별 활동 로그** (Timeline)

**Lucene 쿼리 예시**
```
# 특정 서비스의 에러 로그
service:"order-service" AND level:"error"

# 느린 API 요청
duration:>1000 AND path:"/api/v1/orders"

# 특정 사용자의 활동
userId:"user-123"

# Correlation ID로 추적
correlationId:"abc-123-def-456"

# 결제 실패 로그
message:"Payment failed" AND service:"payment-service"
```

### 6.5 OpenSearch Alerting

**알림 규칙 설정**

**예시: 높은 에러율 감지**
```json
{
  "name": "High Error Rate Alert",
  "type": "monitor",
  "enabled": true,
  "schedule": {
    "period": {
      "interval": 5,
      "unit": "MINUTES"
    }
  },
  "inputs": [
    {
      "search": {
        "indices": ["logs-*"],
        "query": {
          "size": 0,
          "query": {
            "bool": {
              "filter": [
                { "term": { "level": "error" } },
                {
                  "range": {
                    "@timestamp": {
                      "gte": "now-5m",
                      "lte": "now"
                    }
                  }
                }
              ]
            }
          },
          "aggs": {
            "error_count": {
              "value_count": { "field": "level" }
            }
          }
        }
      }
    }
  ],
  "triggers": [
    {
      "name": "Error count exceeds threshold",
      "severity": "1",
      "condition": {
        "script": {
          "source": "ctx.results[0].aggregations.error_count.value > 100",
          "lang": "painless"
        }
      },
      "actions": [
        {
          "name": "Send Slack notification",
          "destination_id": "slack-webhook-destination",
          "message_template": {
            "source": "High error rate detected: {{ctx.results.0.aggregations.error_count.value}} errors in the last 5 minutes"
          }
        }
      ]
    }
  ]
}
```

---

## 7. 알람 전략

### 7.1 알람 우선순위

**P1 (Critical) - 즉시 대응**
- 서비스 완전 다운
- 데이터베이스 연결 불가
- 결제 시스템 장애
- 보안 침해 의심

**P2 (High) - 15분 내 대응**
- 5xx 에러율 > 5%
- API 응답 시간 p99 > 3초
- RDS CPU > 90%
- Lambda 스로틀링 발생

**P3 (Medium) - 1시간 내 대응**
- 4xx 에러율 > 10%
- Disk 사용량 > 80%
- ECS Task 비정상 종료
- 재고 부족 빈번 발생

**P4 (Low) - 영업일 내 확인**
- 성능 저하 경고
- 리소스 사용률 증가 추세
- 로그 패턴 이상

### 7.2 CloudWatch Alarms

#### 7.2.1 ALB 알람

**`infrastructure/cloudwatch/alarms/alb-alarms.json`**
```json
{
  "alarms": [
    {
      "AlarmName": "ALB-HighErrorRate",
      "MetricName": "HTTPCode_Target_5XX_Count",
      "Namespace": "AWS/ApplicationELB",
      "Statistic": "Sum",
      "Period": 300,
      "EvaluationPeriods": 2,
      "Threshold": 10,
      "ComparisonOperator": "GreaterThanThreshold",
      "TreatMissingData": "notBreaching",
      "AlarmActions": [
        "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:critical-alerts"
      ],
      "AlarmDescription": "P2: ALB 5xx errors exceed threshold"
    },
    {
      "AlarmName": "ALB-HighLatency-p99",
      "Metrics": [
        {
          "Id": "m1",
          "ReturnData": true,
          "MetricStat": {
            "Metric": {
              "Namespace": "AWS/ApplicationELB",
              "MetricName": "TargetResponseTime"
            },
            "Period": 300,
            "Stat": "p99"
          }
        }
      ],
      "EvaluationPeriods": 2,
      "Threshold": 3,
      "ComparisonOperator": "GreaterThanThreshold",
      "AlarmActions": [
        "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:high-priority-alerts"
      ],
      "AlarmDescription": "P2: ALB p99 latency > 3 seconds"
    },
    {
      "AlarmName": "ALB-UnhealthyHostCount",
      "MetricName": "UnHealthyHostCount",
      "Namespace": "AWS/ApplicationELB",
      "Statistic": "Maximum",
      "Period": 60,
      "EvaluationPeriods": 2,
      "Threshold": 1,
      "ComparisonOperator": "GreaterThanOrEqualToThreshold",
      "AlarmActions": [
        "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:critical-alerts"
      ],
      "AlarmDescription": "P1: Unhealthy targets detected"
    }
  ]
}
```

#### 7.2.2 RDS 알람

**`infrastructure/cloudwatch/alarms/rds-alarms.json`**
```json
{
  "alarms": [
    {
      "AlarmName": "RDS-HighCPU",
      "MetricName": "CPUUtilization",
      "Namespace": "AWS/RDS",
      "Statistic": "Average",
      "Period": 300,
      "EvaluationPeriods": 3,
      "Threshold": 90,
      "ComparisonOperator": "GreaterThanThreshold",
      "Dimensions": [
        {
          "Name": "DBClusterIdentifier",
          "Value": "doa-market-product-db"
        }
      ],
      "AlarmActions": [
        "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:high-priority-alerts"
      ]
    },
    {
      "AlarmName": "RDS-LowFreeableMemory",
      "MetricName": "FreeableMemory",
      "Namespace": "AWS/RDS",
      "Statistic": "Average",
      "Period": 300,
      "EvaluationPeriods": 2,
      "Threshold": 1073741824,
      "ComparisonOperator": "LessThanThreshold",
      "Dimensions": [
        {
          "Name": "DBClusterIdentifier",
          "Value": "doa-market-product-db"
        }
      ],
      "AlarmActions": [
        "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:high-priority-alerts"
      ],
      "AlarmDescription": "RDS freeable memory < 1GB"
    },
    {
      "AlarmName": "RDS-HighDatabaseConnections",
      "MetricName": "DatabaseConnections",
      "Namespace": "AWS/RDS",
      "Statistic": "Average",
      "Period": 300,
      "EvaluationPeriods": 2,
      "Threshold": 80,
      "ComparisonOperator": "GreaterThanThreshold",
      "AlarmActions": [
        "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:medium-priority-alerts"
      ]
    }
  ]
}
```

#### 7.2.3 ECS 알람

**`infrastructure/cloudwatch/alarms/ecs-alarms.json`**
```json
{
  "alarms": [
    {
      "AlarmName": "ECS-ProductService-HighCPU",
      "MetricName": "CPUUtilization",
      "Namespace": "AWS/ECS",
      "Statistic": "Average",
      "Period": 300,
      "EvaluationPeriods": 2,
      "Threshold": 80,
      "ComparisonOperator": "GreaterThanThreshold",
      "Dimensions": [
        {
          "Name": "ServiceName",
          "Value": "product-service"
        },
        {
          "Name": "ClusterName",
          "Value": "doa-market-cluster"
        }
      ],
      "AlarmActions": [
        "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:medium-priority-alerts",
        "arn:aws:autoscaling:ap-northeast-2:ACCOUNT_ID:scalingPolicy:xxxxx:autoScalingGroupName/product-service-asg:policyName/scale-up"
      ]
    },
    {
      "AlarmName": "ECS-ProductService-NoRunningTasks",
      "Metrics": [
        {
          "Id": "m1",
          "ReturnData": true,
          "MetricStat": {
            "Metric": {
              "Namespace": "ECS/ContainerInsights",
              "MetricName": "RunningTaskCount",
              "Dimensions": [
                {
                  "Name": "ServiceName",
                  "Value": "product-service"
                },
                {
                  "Name": "ClusterName",
                  "Value": "doa-market-cluster"
                }
              ]
            },
            "Period": 60,
            "Stat": "Average"
          }
        }
      ],
      "EvaluationPeriods": 2,
      "Threshold": 1,
      "ComparisonOperator": "LessThanThreshold",
      "AlarmActions": [
        "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:critical-alerts"
      ],
      "AlarmDescription": "P1: No running tasks for product-service"
    }
  ]
}
```

### 7.3 SNS 토픽 및 구독

**`infrastructure/sns/alerting-topics.json`**
```json
{
  "topics": [
    {
      "TopicName": "critical-alerts",
      "DisplayName": "DOA Market Critical Alerts (P1)",
      "Subscriptions": [
        {
          "Protocol": "email",
          "Endpoint": "oncall@doamarket.com"
        },
        {
          "Protocol": "sms",
          "Endpoint": "+821012345678"
        },
        {
          "Protocol": "https",
          "Endpoint": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
        },
        {
          "Protocol": "https",
          "Endpoint": "https://events.pagerduty.com/integration/xxxxx/enqueue"
        }
      ]
    },
    {
      "TopicName": "high-priority-alerts",
      "DisplayName": "DOA Market High Priority Alerts (P2)",
      "Subscriptions": [
        {
          "Protocol": "email",
          "Endpoint": "devops@doamarket.com"
        },
        {
          "Protocol": "https",
          "Endpoint": "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
        }
      ]
    },
    {
      "TopicName": "medium-priority-alerts",
      "DisplayName": "DOA Market Medium Priority Alerts (P3)",
      "Subscriptions": [
        {
          "Protocol": "email",
          "Endpoint": "devops@doamarket.com"
        }
      ]
    }
  ]
}
```

### 7.4 Slack 알림 Lambda

**`infrastructure/lambda/sns-to-slack/index.ts`**
```typescript
import { SNSEvent } from 'aws-lambda';
import axios from 'axios';

const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL!;

export async function handler(event: SNSEvent) {
  for (const record of event.Records) {
    const message = JSON.parse(record.Sns.Message);

    const alarmName = message.AlarmName;
    const newState = message.NewStateValue;
    const reason = message.NewStateReason;
    const timestamp = message.StateChangeTime;

    const color = newState === 'ALARM' ? 'danger' : 'good';
    const emoji = newState === 'ALARM' ? ':rotating_light:' : ':white_check_mark:';

    await axios.post(SLACK_WEBHOOK_URL, {
      text: `${emoji} CloudWatch Alarm: ${alarmName}`,
      attachments: [
        {
          color: color,
          fields: [
            {
              title: 'Alarm Name',
              value: alarmName,
              short: true,
            },
            {
              title: 'State',
              value: newState,
              short: true,
            },
            {
              title: 'Reason',
              value: reason,
              short: false,
            },
            {
              title: 'Time',
              value: timestamp,
              short: true,
            },
          ],
        },
      ],
    });
  }

  return { statusCode: 200, body: 'Success' };
}
```

---

## 8. SLI/SLO/SLA

### 8.1 정의

**SLI (Service Level Indicator)**
- 서비스 수준을 측정하는 실제 메트릭

**SLO (Service Level Objective)**
- 목표로 하는 SLI 값

**SLA (Service Level Agreement)**
- 고객과 합의한 서비스 수준

### 8.2 DOA Market SLI/SLO 정의

**가용성 (Availability)**
```
SLI: (Successful Requests / Total Requests) × 100
SLO: 99.9% (월간)
SLA: 99.5% (월간)

측정 방법:
- ALB RequestCount 대비 HTTPCode_Target_2XX_Count 비율
- 5분 간격 측정
```

**지연 시간 (Latency)**
```
SLI: API 응답 시간 p95
SLO: < 500ms (p95)
SLA: < 1000ms (p95)

측정 방법:
- ALB TargetResponseTime p95
- 1분 간격 측정
```

**에러율 (Error Rate)**
```
SLI: (5xx Errors / Total Requests) × 100
SLO: < 0.1%
SLA: < 1%

측정 방법:
- ALB HTTPCode_Target_5XX_Count / RequestCount
- 5분 간격 측정
```

**처리량 (Throughput)**
```
SLI: Requests per second
SLO: 주문 생성 > 100 TPS, 상품 조회 > 1000 TPS
SLA: N/A

측정 방법:
- ALB RequestCount per second
- CloudWatch 커스텀 메트릭
```

### 8.3 Error Budget 계산

**월간 Error Budget (99.9% SLO)**
```
Total time: 30일 × 24시간 × 60분 = 43,200분
Downtime allowed: 43,200분 × 0.1% = 43.2분

Error Budget 소진 추적:
- 실시간 모니터링
- 일일/주간 리포트
- 50% 소진 시 경고
- 80% 소진 시 릴리스 동결
```

**Error Budget 대시보드**

**`infrastructure/cloudwatch/dashboards/error-budget.json`**
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "title": "Error Budget 소진율 (월간)",
        "metrics": [
          {
            "expression": "(m1 / (m1 + m2)) * 100",
            "label": "Error Rate (%)",
            "id": "e1"
          },
          {
            "expression": "e1 / 0.1",
            "label": "Error Budget Consumed (%)",
            "id": "e2"
          },
          [
            "AWS/ApplicationELB",
            "HTTPCode_Target_5XX_Count",
            { "stat": "Sum", "id": "m1", "visible": false }
          ],
          [
            ".",
            "HTTPCode_Target_2XX_Count",
            { "stat": "Sum", "id": "m2", "visible": false }
          ]
        ],
        "period": 86400,
        "region": "ap-northeast-2",
        "annotations": {
          "horizontal": [
            { "value": 50, "label": "Warning (50%)" },
            { "value": 80, "label": "Critical (80%)" },
            { "value": 100, "label": "Budget Exhausted" }
          ]
        }
      }
    }
  ]
}
```

---

## 9. 성능 모니터링

### 9.1 Database Performance Insights

**RDS Performance Insights 활성화**
```json
{
  "EnablePerformanceInsights": true,
  "PerformanceInsightsRetentionPeriod": 7,
  "PerformanceInsightsKMSKeyId": "arn:aws:kms:ap-northeast-2:ACCOUNT_ID:key/xxxxx"
}
```

**주요 메트릭**
- DB Load (Average Active Sessions)
- Top SQL by Load
- Top Wait Events
- Top Users/Hosts

### 9.2 Slow Query 모니터링

**PostgreSQL Slow Query Log**

**RDS Parameter Group**
```
log_min_duration_statement = 1000  # 1초 이상 쿼리 로깅
log_statement = 'all'              # 모든 쿼리 로깅 (개발 환경)
log_duration = 'on'                # 실행 시간 로깅
```

**CloudWatch Logs Insights 쿼리**
```
fields @timestamp, @message
| filter @message like /duration/
| parse @message /duration: (?<duration>\d+\.\d+) ms/
| filter duration > 1000
| sort duration desc
| limit 20
```

### 9.3 Cache Hit Rate 모니터링

**Redis Cache Hit Rate**

**`backend/services/product-service/src/monitoring/cache-metrics.ts`**
```typescript
export class CacheMetrics {
  private hits = 0;
  private misses = 0;

  recordHit() {
    this.hits++;
    this.publishMetrics();
  }

  recordMiss() {
    this.misses++;
    this.publishMetrics();
  }

  private async publishMetrics() {
    const total = this.hits + this.misses;
    if (total % 100 === 0) {
      // 100번마다 메트릭 발행
      const hitRate = (this.hits / total) * 100;

      await cloudwatch.send(
        new PutMetricDataCommand({
          Namespace: 'DOAMarket/Cache',
          MetricData: [
            {
              MetricName: 'CacheHitRate',
              Value: hitRate,
              Unit: 'Percent',
              Dimensions: [{ Name: 'Service', Value: 'product-service' }],
            },
          ],
        })
      );

      // 카운터 리셋
      this.hits = 0;
      this.misses = 0;
    }
  }
}
```

---

## 10. 비용 모니터링

### 10.1 Cost Explorer API

**일일 비용 추적**

**`infrastructure/lambda/cost-monitoring/index.ts`**
```typescript
import { CostExplorerClient, GetCostAndUsageCommand } from '@aws-sdk/client-cost-explorer';

const costExplorer = new CostExplorerClient({ region: 'us-east-1' });

export async function handler() {
  const end = new Date();
  const start = new Date(end.getTime() - 30 * 24 * 60 * 60 * 1000); // 30일 전

  const response = await costExplorer.send(
    new GetCostAndUsageCommand({
      TimePeriod: {
        Start: start.toISOString().split('T')[0],
        End: end.toISOString().split('T')[0],
      },
      Granularity: 'DAILY',
      Metrics: ['UnblendedCost'],
      GroupBy: [
        {
          Type: 'DIMENSION',
          Key: 'SERVICE',
        },
      ],
    })
  );

  // 비용 분석 및 알림
  const costs = response.ResultsByTime?.map((result) => ({
    date: result.TimePeriod?.Start,
    services: result.Groups?.map((group) => ({
      service: group.Keys?.[0],
      cost: parseFloat(group.Metrics?.UnblendedCost?.Amount || '0'),
    })),
  }));

  // 일일 비용이 임계값 초과 시 알림
  const todayCost = costs?.[costs.length - 1]?.services?.reduce(
    (sum, s) => sum + s.cost,
    0
  );

  if (todayCost && todayCost > 500) {
    // $500 초과
    await sns.publish({
      TopicArn: process.env.COST_ALERT_TOPIC_ARN,
      Subject: 'High AWS Cost Alert',
      Message: `Today's AWS cost: $${todayCost.toFixed(2)}`,
    });
  }

  return { statusCode: 200, body: JSON.stringify(costs) };
}
```

### 10.2 Budget Alerts

**`infrastructure/budgets/monthly-budget.json`**
```json
{
  "BudgetName": "DOAMarket-Monthly-Budget",
  "BudgetType": "COST",
  "TimeUnit": "MONTHLY",
  "BudgetLimit": {
    "Amount": "10000",
    "Unit": "USD"
  },
  "CostFilters": {},
  "CostTypes": {
    "IncludeTax": true,
    "IncludeSubscription": true,
    "UseBlended": false
  },
  "NotificationsWithSubscribers": [
    {
      "Notification": {
        "NotificationType": "ACTUAL",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": 80,
        "ThresholdType": "PERCENTAGE"
      },
      "Subscribers": [
        {
          "SubscriptionType": "EMAIL",
          "Address": "finance@doamarket.com"
        }
      ]
    },
    {
      "Notification": {
        "NotificationType": "FORECASTED",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": 100,
        "ThresholdType": "PERCENTAGE"
      },
      "Subscribers": [
        {
          "SubscriptionType": "EMAIL",
          "Address": "finance@doamarket.com"
        },
        {
          "SubscriptionType": "EMAIL",
          "Address": "devops@doamarket.com"
        }
      ]
    }
  ]
}
```

---

## 11. 모니터링 체크리스트

### 11.1 인프라 모니터링
- [ ] CloudWatch Container Insights 활성화
- [ ] RDS Performance Insights 활성화
- [ ] VPC Flow Logs 활성화
- [ ] CloudTrail 전체 리전 활성화
- [ ] X-Ray 분산 추적 활성화

### 11.2 애플리케이션 모니터링
- [ ] 구조화된 JSON 로그 사용
- [ ] Correlation ID 추적
- [ ] 커스텀 비즈니스 메트릭 수집
- [ ] API 지연 시간 측정
- [ ] 에러 추적 및 알림

### 11.3 알람 설정
- [ ] P1/P2/P3/P4 알람 분류
- [ ] SNS 토픽 및 구독 설정
- [ ] Slack/PagerDuty 통합
- [ ] Error Budget 모니터링
- [ ] 비용 알림 설정

### 11.4 대시보드
- [ ] 전체 시스템 대시보드
- [ ] 서비스별 대시보드
- [ ] 비즈니스 메트릭 대시보드
- [ ] Error Budget 대시보드
- [ ] 비용 대시보드

### 11.5 로그 관리
- [ ] 로그 보존 정책 설정
- [ ] OpenSearch 인덱스 라이프사이클
- [ ] S3 장기 보관 설정
- [ ] 로그 검색 및 분석 가능

---

**문서 버전**: 1.0
**최종 수정일**: 2024-01-15
**작성자**: DOA Market DevOps Team
