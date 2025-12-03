# 5단계: Lambda 함수 목록 및 트리거 매핑

## 목차
- [Lambda 함수 설계 원칙](#lambda-함수-설계-원칙)
- [Lambda 함수 목록](#lambda-함수-목록)
- [트리거 매핑 전체](#lambda-함수-트리거-매핑-전체)
- [배포 및 모니터링](#배포-및-모니터링)

---

## Lambda 함수 설계 원칙

### 1. 함수 분류

**Event Processor**
- EventBridge 이벤트 처리
- 특정 비즈니스 이벤트에 반응
- 예: order.created, payment.completed

**Queue Worker**
- SQS 메시지 배치 처리
- 순서 보장 및 재시도 로직
- 예: notification-queue, inventory-queue

**HTTP Handler**
- API Gateway와 직접 연동
- RESTful API 엔드포인트 구현
- 예: authorizer, webhook-handler

**Scheduled Task**
- EventBridge Schedule 기반
- 주기적인 배치 작업
- 예: 정산 계산, 통계 집계

**Stream Processor**
- DynamoDB Stream, Kinesis 처리
- 실시간 데이터 파이프라인
- 예: 이벤트 소싱, 분석 데이터 처리

---

### 2. 함수 네이밍 규칙

```
{environment}-{service}-{function-name}

예시:
- prod-payment-processor
- prod-notification-sender
- prod-image-optimizer
- staging-settlement-calculator
```

---

### 3. 리소스 제한

| 함수 유형 | 메모리 | 타임아웃 | 동시 실행 | Reserved Concurrency |
|----------|--------|---------|----------|---------------------|
| Event Processor | 512MB | 30s | 100 | - |
| Queue Worker | 1024MB | 60s | 50 | 50 |
| Image Processor | 2048MB | 120s | 20 | 20 |
| Scheduled Task | 512MB | 300s | 1 | 1 |
| API Authorizer | 256MB | 5s | 1000 | - |

---

### 4. 환경 변수 관리

```typescript
// 공통 환경 변수
{
  "NODE_ENV": "production",
  "AWS_REGION": "ap-northeast-2",
  "EVENT_BUS_NAME": "doa-market-event-bus",
  "LOG_LEVEL": "info"
}

// 서비스별 환경 변수
{
  "DB_HOST": "${ssm:/doa-market/rds/host}",
  "DB_NAME": "payments_db",
  "REDIS_HOST": "${ssm:/doa-market/redis/host}",
  "PG_API_KEY": "${secretsmanager:pg-api-key}"
}
```

---

## Lambda 함수 목록

### 1. Payment Processor

**함수명**: `prod-payment-processor`
**트리거**: EventBridge (order.created)
**목적**: 주문 생성 시 결제 프로세스 시작

```typescript
// lambda/payment-processor/index.ts
import { EventBridgeEvent } from 'aws-lambda';
import { publishEvent } from './lib/eventbridge';
import { preparePayment } from './lib/payment';

export const handler = async (event: EventBridgeEvent<'order.created', OrderCreatedPayload>) => {
  console.log('Processing order.created event', { orderId: event.detail.orderId });

  try {
    const { orderId, userId, totalAmount, paymentMethod } = event.detail;

    // 결제 준비
    const payment = await preparePayment({
      orderId,
      userId,
      amount: totalAmount,
      method: paymentMethod
    });

    // EventBridge로 결과 발행
    await publishEvent('payment.prepared', payment);

    console.log('Payment prepared successfully', { paymentId: payment.id });

    return { statusCode: 200, body: 'Success' };
  } catch (error) {
    console.error('Payment preparation failed', error);

    // DLQ로 메시지 이동
    throw error;
  }
};
```

**환경 변수**:
```json
{
  "PAYMENT_DB_HOST": "${ssm:/doa-market/rds/host}",
  "PAYMENT_DB_NAME": "payments_db",
  "PG_API_KEY": "${secretsmanager:pg-api-key}",
  "PG_API_URL": "https://api.tosspayments.com",
  "EVENT_BUS_NAME": "doa-market-event-bus"
}
```

**IAM 권한**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["rds-data:ExecuteStatement"],
      "Resource": "arn:aws:rds:*:*:cluster:payments-db"
    },
    {
      "Effect": "Allow",
      "Action": ["events:PutEvents"],
      "Resource": "arn:aws:events:*:*:event-bus/doa-market-event-bus"
    },
    {
      "Effect": "Allow",
      "Action": ["secretsmanager:GetSecretValue"],
      "Resource": "arn:aws:secretsmanager:*:*:secret:pg-api-key*"
    }
  ]
}
```

---

### 2. Inventory Updater

**함수명**: `prod-inventory-updater`
**트리거**: SQS (payment-completed-queue)
**목적**: 결제 완료 시 재고 확정 차감

```typescript
// lambda/inventory-updater/index.ts
import { SQSEvent, SQSRecord } from 'aws-lambda';
import { updateInventory } from './lib/inventory';
import { publishEvent } from './lib/eventbridge';

export const handler = async (event: SQSEvent) => {
  const results = [];

  for (const record of event.Records) {
    try {
      const { orderId, items } = JSON.parse(record.body);

      console.log('Processing inventory update', { orderId, itemCount: items.length });

      for (const item of items) {
        await updateInventory({
          productId: item.productId,
          variantId: item.variantId,
          quantity: -item.quantity,
          type: 'confirmed',
          referenceId: orderId
        });
      }

      await publishEvent('inventory.updated', { orderId, items });

      results.push({ messageId: record.messageId, status: 'success' });
    } catch (error) {
      console.error('Failed to update inventory', {
        messageId: record.messageId,
        error
      });

      // 재시도 로직 (SQS에서 자동 처리)
      results.push({ messageId: record.messageId, status: 'failed' });
      throw error;
    }
  }

  return {
    batchItemFailures: results
      .filter(r => r.status === 'failed')
      .map(r => ({ itemIdentifier: r.messageId }))
  };
};
```

**SQS 설정**:
```json
{
  "QueueName": "payment-completed-queue",
  "VisibilityTimeout": 120,
  "MessageRetentionPeriod": 1209600,
  "ReceiveMessageWaitTimeSeconds": 20,
  "RedrivePolicy": {
    "deadLetterTargetArn": "arn:aws:sqs:*:*:payment-completed-dlq",
    "maxReceiveCount": 3
  }
}
```

**Lambda 배치 설정**:
- Batch Size: 10
- Max Batching Window: 5s
- Function Response Types: ReportBatchItemFailures

---

### 3. Notification Sender

**함수명**: `prod-notification-sender`
**트리거**: SQS (notification-queue)
**목적**: 다양한 채널로 알림 발송

```typescript
// lambda/notification-sender/index.ts
import { SQSEvent } from 'aws-lambda';
import { sendPushNotification } from './lib/fcm';
import { sendEmail } from './lib/ses';
import { sendSMS } from './lib/sns';
import { getNotificationSettings } from './lib/dynamodb';

export const handler = async (event: SQSEvent) => {
  for (const record of event.Records) {
    const notification = JSON.parse(record.body);

    const { userId, channels, title, message, data, type } = notification;

    console.log('Sending notification', { userId, type, channels });

    try {
      // 사용자 알림 설정 조회
      const settings = await getNotificationSettings(userId);

      const promises = [];

      // Push 알림
      if (channels.includes('push') && settings.channels.push && settings.preferences[type]) {
        promises.push(
          sendPushNotification({
            userId,
            title,
            message,
            data
          })
        );
      }

      // 이메일
      if (channels.includes('email') && settings.channels.email && settings.preferences[type]) {
        promises.push(
          sendEmail({
            userId,
            subject: title,
            body: message,
            templateId: `${type}_email`
          })
        );
      }

      // SMS
      if (channels.includes('sms') && settings.channels.sms) {
        promises.push(
          sendSMS({
            userId,
            message: `[DoaMarket] ${message}`
          })
        );
      }

      // 병렬 발송
      await Promise.allSettled(promises);

      // DynamoDB에 알림 이력 저장
      await saveNotificationHistory({
        userId,
        notificationId: data.notificationId || generateId(),
        type,
        title,
        message,
        channels,
        sentAt: new Date().toISOString()
      });

      console.log('Notification sent successfully', { userId, type });
    } catch (error) {
      console.error('Failed to send notification', { userId, type, error });
      throw error;
    }
  }
};
```

**통합 서비스**:
- FCM (Firebase Cloud Messaging) - 푸시 알림
- Amazon SES - 이메일
- Amazon SNS - SMS

---

### 4. Image Optimizer

**함수명**: `prod-image-optimizer`
**트리거**: S3 (ObjectCreated:*)
**목적**: 이미지 업로드 시 자동 리사이징 및 최적화

```typescript
// lambda/image-optimizer/index.ts
import { S3Event } from 'aws-lambda';
import { S3 } from '@aws-sdk/client-s3';
import sharp from 'sharp';

const s3 = new S3({ region: process.env.AWS_REGION });

export const handler = async (event: S3Event) => {
  for (const record of event.Records) {
    const bucket = record.s3.bucket.name;
    const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));

    // 이미 최적화된 이미지는 스킵
    if (key.includes('_thumb') || key.includes('_medium')) {
      continue;
    }

    console.log('Optimizing image', { bucket, key });

    try {
      // S3에서 원본 이미지 가져오기
      const { Body } = await s3.getObject({ Bucket: bucket, Key: key });
      const buffer = await Body.transformToByteArray();

      // 썸네일 생성 (300x300)
      const thumbnail = await sharp(buffer)
        .resize(300, 300, {
          fit: 'cover',
          position: 'center'
        })
        .jpeg({
          quality: 80,
          progressive: true
        })
        .toBuffer();

      // 중간 크기 (800x800)
      const medium = await sharp(buffer)
        .resize(800, 800, {
          fit: 'inside',
          withoutEnlargement: true
        })
        .jpeg({
          quality: 85,
          progressive: true
        })
        .toBuffer();

      // WebP 변환 (원본 크기)
      const webp = await sharp(buffer)
        .webp({ quality: 85 })
        .toBuffer();

      // S3에 저장
      const uploads = [
        s3.putObject({
          Bucket: bucket,
          Key: key.replace(/\.(jpg|jpeg|png)$/i, '_thumb.jpg'),
          Body: thumbnail,
          ContentType: 'image/jpeg',
          CacheControl: 'max-age=31536000'
        }),
        s3.putObject({
          Bucket: bucket,
          Key: key.replace(/\.(jpg|jpeg|png)$/i, '_medium.jpg'),
          Body: medium,
          ContentType: 'image/jpeg',
          CacheControl: 'max-age=31536000'
        }),
        s3.putObject({
          Bucket: bucket,
          Key: key.replace(/\.(jpg|jpeg|png)$/i, '.webp'),
          Body: webp,
          ContentType: 'image/webp',
          CacheControl: 'max-age=31536000'
        })
      ];

      await Promise.all(uploads);

      console.log('Image optimization completed', { bucket, key });
    } catch (error) {
      console.error('Image optimization failed', { bucket, key, error });
      throw error;
    }
  }
};
```

**Layer 종속성**:
- sharp (이미지 처리 라이브러리)

**메모리**: 2048MB
**타임아웃**: 120s
**Ephemeral Storage**: 1024MB

---

### 5. Settlement Calculator

**함수명**: `prod-settlement-calculator`
**트리거**: EventBridge Schedule (cron: 0 2 1 * ? *)
**목적**: 매월 1일 새벽 2시에 판매자 정산 계산

```typescript
// lambda/settlement-calculator/index.ts
import { ScheduledEvent } from 'aws-lambda';
import { Lambda } from '@aws-sdk/client-lambda';
import { getAllActiveSellers, getDeliveredOrders, createSettlement } from './lib/db';
import { publishEvent } from './lib/eventbridge';

const lambda = new Lambda({ region: process.env.AWS_REGION });

export const handler = async (event: ScheduledEvent) => {
  console.log('Starting settlement calculation');

  const lastMonth = getLastMonth();
  const sellers = await getAllActiveSellers();

  console.log(`Processing ${sellers.length} sellers`);

  for (const seller of sellers) {
    try {
      // 지난 달 배송완료된 주문 조회
      const orders = await getDeliveredOrders({
        sellerId: seller.id,
        startDate: lastMonth.start,
        endDate: lastMonth.end
      });

      if (orders.length === 0) {
        console.log('No orders for seller', { sellerId: seller.id });
        continue;
      }

      // 정산 금액 계산
      const totalSales = orders.reduce((sum, order) => sum + order.totalAmount, 0);
      const commissionAmount = totalSales * (seller.commissionRate / 100);
      const shippingFee = orders.reduce((sum, order) => sum + order.shippingFee, 0);
      const refundAmount = await getRefundAmount(seller.id, lastMonth);

      const settlementAmount = totalSales - commissionAmount + shippingFee - refundAmount;

      console.log('Settlement calculated', {
        sellerId: seller.id,
        orderCount: orders.length,
        totalSales,
        settlementAmount
      });

      // 정산 데이터 생성
      const settlement = await createSettlement({
        sellerId: seller.id,
        settlementNumber: generateSettlementNumber(lastMonth),
        periodStart: lastMonth.start,
        periodEnd: lastMonth.end,
        totalSales,
        commissionAmount,
        commissionRate: seller.commissionRate,
        shippingFee,
        refundAmount,
        settlementAmount,
        bankName: seller.bankName,
        bankAccountNumber: seller.bankAccountNumber,
        bankAccountHolder: seller.bankAccountHolder,
        status: 'calculated'
      });

      // 정산 내역 아이템 생성
      await createSettlementItems(settlement.id, orders);

      // 정산서 PDF 생성 (비동기)
      await lambda.invoke({
        FunctionName: 'prod-settlement-pdf-generator',
        InvocationType: 'Event',
        Payload: JSON.stringify({ settlementId: settlement.id })
      });

      // 이벤트 발행
      await publishEvent('settlement.calculated', {
        settlementId: settlement.id,
        sellerId: seller.id,
        settlementAmount
      });

    } catch (error) {
      console.error('Settlement calculation failed', {
        sellerId: seller.id,
        error
      });

      // 개별 판매자 실패는 전체 프로세스 중단하지 않음
      continue;
    }
  }

  console.log('Settlement calculation completed');

  return { statusCode: 200, processedSellers: sellers.length };
};

function getLastMonth() {
  const now = new Date();
  const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0);

  return {
    start: lastMonth.toISOString().split('T')[0],
    end: lastMonthEnd.toISOString().split('T')[0]
  };
}

function generateSettlementNumber(period: { start: string }) {
  const yearMonth = period.start.substring(0, 7).replace('-', '');
  return `SETTLE-${yearMonth}-${Date.now().toString().slice(-6)}`;
}
```

**타임아웃**: 300s (5분)
**Reserved Concurrency**: 1 (중복 실행 방지)

---

### 6. Settlement PDF Generator

**함수명**: `prod-settlement-pdf-generator`
**트리거**: Lambda Direct Invoke
**목적**: 정산서 PDF 생성 및 S3 업로드

```typescript
// lambda/settlement-pdf-generator/index.ts
import PDFDocument from 'pdfkit';
import { S3 } from '@aws-sdk/client-s3';
import { getSettlement, updateSettlementDocumentUrl } from './lib/db';

const s3 = new S3({ region: process.env.AWS_REGION });

export const handler = async (event: { settlementId: string }) => {
  const { settlementId } = event;

  console.log('Generating settlement PDF', { settlementId });

  const settlement = await getSettlement(settlementId);

  // PDF 생성
  const doc = new PDFDocument({ size: 'A4', margin: 50 });
  const chunks = [];

  doc.on('data', chunk => chunks.push(chunk));

  // PDF 내용 작성
  doc.fontSize(20).text('정산서', { align: 'center' });
  doc.moveDown();
  doc.fontSize(12).text(`정산번호: ${settlement.settlementNumber}`);
  doc.text(`정산기간: ${settlement.periodStart} ~ ${settlement.periodEnd}`);
  doc.text(`판매자: ${settlement.seller.businessName}`);
  doc.moveDown();

  // 정산 내역 테이블
  doc.text(`총 매출: ${settlement.totalSales.toLocaleString()}원`);
  doc.text(`수수료 (${settlement.commissionRate}%): -${settlement.commissionAmount.toLocaleString()}원`);
  doc.text(`배송비: +${settlement.shippingFee.toLocaleString()}원`);
  doc.text(`환불액: -${settlement.refundAmount.toLocaleString()}원`);
  doc.moveDown();
  doc.fontSize(14).text(`정산 금액: ${settlement.settlementAmount.toLocaleString()}원`, { bold: true });

  doc.end();

  const pdfBuffer = await new Promise<Buffer>((resolve) => {
    doc.on('end', () => resolve(Buffer.concat(chunks)));
  });

  // S3 업로드
  const key = `settlements/${settlement.settlementNumber}.pdf`;
  await s3.putObject({
    Bucket: process.env.SETTLEMENT_BUCKET,
    Key: key,
    Body: pdfBuffer,
    ContentType: 'application/pdf'
  });

  const documentUrl = `https://${process.env.SETTLEMENT_BUCKET}.s3.amazonaws.com/${key}`;

  // DB 업데이트
  await updateSettlementDocumentUrl(settlementId, documentUrl);

  console.log('Settlement PDF generated', { settlementId, documentUrl });

  return { settlementId, documentUrl };
};
```

---

### 7. Order Events Logger

**함수명**: `prod-order-events-logger`
**트리거**: DynamoDB Stream (orders 테이블)
**목적**: 주문 변경 이력을 이벤트 소싱 테이블에 기록

```typescript
// lambda/order-events-logger/index.ts
import { DynamoDBStreamEvent, AttributeValue } from 'aws-lambda';
import { unmarshall } from '@aws-sdk/util-dynamodb';
import { saveOrderEvent } from './lib/dynamodb';

export const handler = async (event: DynamoDBStreamEvent) => {
  for (const record of event.Records) {
    try {
      const eventName = record.eventName; // INSERT, MODIFY, REMOVE

      if (eventName === 'MODIFY') {
        const oldImage = unmarshall(record.dynamodb.OldImage as Record<string, AttributeValue>);
        const newImage = unmarshall(record.dynamodb.NewImage as Record<string, AttributeValue>);

        // 상태 변경 감지
        if (oldImage.status !== newImage.status) {
          await saveOrderEvent({
            orderId: newImage.id,
            eventType: `order.status.changed.${newImage.status}`,
            eventVersion: 'v1',
            timestamp: Date.now(),
            data: {
              oldStatus: oldImage.status,
              newStatus: newImage.status,
              updatedFields: getChangedFields(oldImage, newImage)
            },
            metadata: {
              eventSource: 'dynamodb-stream',
              sequenceNumber: record.dynamodb.SequenceNumber
            }
          });

          console.log('Order event logged', {
            orderId: newImage.id,
            oldStatus: oldImage.status,
            newStatus: newImage.status
          });
        }
      }
    } catch (error) {
      console.error('Failed to log order event', {
        recordId: record.eventID,
        error
      });
      // DynamoDB Stream은 순서 보장이 중요하므로 에러 발생 시 중단
      throw error;
    }
  }
};

function getChangedFields(oldObj: any, newObj: any): string[] {
  const changed = [];
  for (const key in newObj) {
    if (JSON.stringify(oldObj[key]) !== JSON.stringify(newObj[key])) {
      changed.push(key);
    }
  }
  return changed;
}
```

**Stream 설정**:
- Batch Size: 100
- Starting Position: LATEST
- Retry Attempts: 3

---

### 8. API Gateway Authorizer

**함수명**: `prod-api-authorizer`
**트리거**: API Gateway (Lambda Authorizer)
**목적**: JWT 토큰 검증 및 사용자 권한 확인

```typescript
// lambda/api-authorizer/index.ts
import { APIGatewayAuthorizerEvent, APIGatewayAuthorizerResult } from 'aws-lambda';
import jwt from 'jsonwebtoken';
import { getSecretValue } from './lib/secrets-manager';

let jwtSecret: string;

export const handler = async (event: APIGatewayAuthorizerEvent): Promise<APIGatewayAuthorizerResult> => {
  console.log('Authorizing request', { methodArn: event.methodArn });

  try {
    // JWT Secret 가져오기 (캐싱)
    if (!jwtSecret) {
      jwtSecret = await getSecretValue('jwt-secret');
    }

    const token = event.authorizationToken.replace('Bearer ', '');

    if (!token) {
      throw new Error('No token provided');
    }

    // JWT 검증
    const decoded = jwt.verify(token, jwtSecret) as {
      userId: string;
      role: string;
      email: string;
      exp: number;
    };

    console.log('Token verified', { userId: decoded.userId, role: decoded.role });

    // Policy 생성
    return generatePolicy(decoded.userId, 'Allow', event.methodArn, {
      userId: decoded.userId,
      role: decoded.role,
      email: decoded.email
    });

  } catch (error) {
    console.error('Authorization failed', { error: error.message });

    // 인증 실패 시 Deny
    return generatePolicy('user', 'Deny', event.methodArn);
  }
};

function generatePolicy(
  principalId: string,
  effect: 'Allow' | 'Deny',
  resource: string,
  context: Record<string, any> = {}
): APIGatewayAuthorizerResult {
  return {
    principalId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: resource
        }
      ]
    },
    context
  };
}
```

**메모리**: 256MB
**타임아웃**: 5s
**환경 변수**:
```json
{
  "JWT_SECRET_ARN": "arn:aws:secretsmanager:*:*:secret:jwt-secret"
}
```

---

### 9. Review Reminder

**함수명**: `prod-review-reminder`
**트리거**: EventBridge (shipping.delivered)
**목적**: 배송 완료 3일 후 리뷰 작성 알림

```typescript
// lambda/review-reminder/index.ts
import { EventBridgeEvent } from 'aws-lambda';
import { Scheduler } from '@aws-sdk/client-scheduler';

const scheduler = new Scheduler({ region: process.env.AWS_REGION });

export const handler = async (event: EventBridgeEvent<'shipping.delivered', any>) => {
  const { orderId, userId, deliveredAt } = event.detail;

  console.log('Scheduling review reminder', { orderId, userId });

  // 3일 후 알림 예약
  const reminderTime = new Date(deliveredAt);
  reminderTime.setDate(reminderTime.getDate() + 3);

  await scheduler.createSchedule({
    Name: `review-reminder-${orderId}`,
    ScheduleExpression: `at(${reminderTime.toISOString().split('.')[0]})`,
    Target: {
      Arn: process.env.NOTIFICATION_QUEUE_ARN,
      RoleArn: process.env.SCHEDULER_ROLE_ARN,
      Input: JSON.stringify({
        userId,
        type: 'review_reminder',
        channels: ['push', 'email'],
        title: '리뷰를 작성해주세요',
        message: '구매하신 상품은 어떠셨나요? 리뷰를 남겨주시면 포인트를 드립니다!',
        data: { orderId }
      })
    },
    FlexibleTimeWindow: {
      Mode: 'OFF'
    }
  });

  console.log('Review reminder scheduled', { orderId, reminderTime });
};
```

---

### 10. Analytics Processor

**함수명**: `prod-analytics-processor`
**트리거**: Kinesis Data Stream
**목적**: 실시간 사용자 행동 데이터 처리 및 OpenSearch 인덱싱

```typescript
// lambda/analytics-processor/index.ts
import { KinesisStreamEvent } from 'aws-lambda';
import { Client } from '@opensearch-project/opensearch';
import { updateRealtimeStats } from './lib/redis';

const client = new Client({
  node: process.env.OPENSEARCH_ENDPOINT,
  auth: {
    username: process.env.OPENSEARCH_USERNAME,
    password: process.env.OPENSEARCH_PASSWORD
  }
});

export const handler = async (event: KinesisStreamEvent) => {
  const events = event.Records.map(record => {
    const payload = Buffer.from(record.kinesis.data, 'base64').toString('utf-8');
    return JSON.parse(payload);
  });

  console.log(`Processing ${events.length} analytics events`);

  // OpenSearch bulk 인덱싱
  const body = events.flatMap(doc => [
    { index: { _index: 'analytics', _id: doc.eventId } },
    doc
  ]);

  await client.bulk({ body });

  // 실시간 통계 업데이트 (Redis)
  await updateRealtimeStats(events);

  console.log('Analytics events processed');
};
```

---

### 11. Low Stock Alert

**함수명**: `prod-low-stock-alert`
**트리거**: EventBridge (inventory.adjusted)
**목적**: 재고 부족 시 판매자에게 알림

```typescript
// lambda/low-stock-alert/index.ts
import { EventBridgeEvent } from 'aws-lambda';
import { getProduct, getSeller } from './lib/db';
import { sendNotification } from './lib/notification';
import { publishEvent } from './lib/eventbridge';

export const handler = async (event: EventBridgeEvent<'inventory.adjusted', any>) => {
  const { productId, variantId, currentStock, threshold } = event.detail;

  console.log('Checking stock level', { productId, currentStock, threshold });

  if (currentStock < threshold) {
    const product = await getProduct(productId);
    const seller = await getSeller(product.sellerId);

    await sendNotification({
      userId: seller.userId,
      type: 'low_stock',
      channels: ['push', 'email'],
      title: '재고 부족 알림',
      message: `${product.name}의 재고가 ${currentStock}개 남았습니다`,
      data: { productId, variantId, currentStock }
    });

    await publishEvent('inventory.low_stock', {
      productId,
      variantId,
      currentStock,
      threshold
    });

    console.log('Low stock alert sent', { productId, currentStock });
  }
};
```

---

### 12. Product Sync OpenSearch

**함수명**: `prod-product-sync-opensearch`
**트리거**: EventBridge (product.*)
**목적**: 상품 변경 시 OpenSearch 검색 인덱스 동기화

```typescript
// lambda/product-sync-opensearch/index.ts
import { EventBridgeEvent } from 'aws-lambda';
import { Client } from '@opensearch-project/opensearch';
import { getProduct } from './lib/db';

const client = new Client({
  node: process.env.OPENSEARCH_ENDPOINT
});

export const handler = async (event: EventBridgeEvent<string, any>) => {
  const eventType = event['detail-type'];
  const { productId } = event.detail;

  console.log('Syncing product to OpenSearch', { eventType, productId });

  try {
    if (eventType === 'product.created' || eventType === 'product.updated') {
      const product = await getProduct(productId);

      await client.index({
        index: 'products',
        id: productId,
        body: {
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          categoryId: product.categoryId,
          categoryName: product.category.name,
          sellerId: product.sellerId,
          sellerName: product.seller.name,
          rating: product.rating,
          reviewCount: product.reviewCount,
          status: product.status,
          metadata: product.metadata,
          createdAt: product.createdAt,
          updatedAt: product.updatedAt
        }
      });

    } else if (eventType === 'product.deleted') {
      await client.delete({
        index: 'products',
        id: productId
      });
    }

    console.log('Product synced to OpenSearch', { eventType, productId });
  } catch (error) {
    console.error('Failed to sync product', { eventType, productId, error });
    throw error;
  }
};
```

---

## Lambda 함수 트리거 매핑 전체

| Lambda 함수 | 트리거 유형 | 트리거 소스 | 메모리 | 타임아웃 | 동시성 |
|------------|------------|------------|--------|---------|--------|
| payment-processor | EventBridge | order.created | 512MB | 30s | 100 |
| inventory-updater | SQS | payment-completed-queue | 1024MB | 60s | 50 |
| notification-sender | SQS | notification-queue | 512MB | 30s | 100 |
| image-optimizer | S3 | product-images/* | 2048MB | 120s | 20 |
| settlement-calculator | Schedule | cron(0 2 1 * ? *) | 512MB | 300s | 1 |
| settlement-pdf-generator | Invoke | Direct | 1024MB | 180s | 10 |
| order-events-logger | DynamoDB Stream | orders table | 256MB | 10s | - |
| api-authorizer | API Gateway | - | 256MB | 5s | 1000 |
| review-reminder | EventBridge | shipping.delivered | 256MB | 10s | - |
| analytics-processor | Kinesis | analytics-stream | 512MB | 60s | 50 |
| low-stock-alert | EventBridge | inventory.adjusted | 256MB | 10s | - |
| product-sync-opensearch | EventBridge | product.* | 512MB | 30s | 50 |

---

## 배포 및 모니터링

### 1. Lambda 배포 전략

#### Blue/Green 배포
```typescript
// AWS SAM template.yaml
Resources:
  PaymentProcessorFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: prod-payment-processor
      AutoPublishAlias: live
      DeploymentPreference:
        Type: Linear10PercentEvery1Minute
        Alarms:
          - !Ref PaymentProcessorErrorAlarm
```

#### Canary 배포
- 10% 트래픽으로 1분간 테스트
- 에러율 확인 후 100% 전환
- CloudWatch Alarm 통합

---

### 2. 모니터링 설정

#### CloudWatch Metrics
```typescript
// 커스텀 메트릭 발행
import { CloudWatch } from '@aws-sdk/client-cloudwatch';

const cloudwatch = new CloudWatch({ region: process.env.AWS_REGION });

await cloudwatch.putMetricData({
  Namespace: 'DoaMarket/Lambda',
  MetricData: [
    {
      MetricName: 'PaymentProcessingTime',
      Value: processingTime,
      Unit: 'Milliseconds',
      Dimensions: [
        { Name: 'FunctionName', Value: 'payment-processor' },
        { Name: 'Environment', Value: 'production' }
      ]
    }
  ]
});
```

#### CloudWatch Alarms
```yaml
PaymentProcessorErrorAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: payment-processor-errors
    MetricName: Errors
    Namespace: AWS/Lambda
    Statistic: Sum
    Period: 60
    EvaluationPeriods: 2
    Threshold: 5
    ComparisonOperator: GreaterThanThreshold
    AlarmActions:
      - !Ref SNSAlertTopic
```

---

### 3. 로깅 전략

#### 구조화된 로깅
```typescript
// lib/logger.ts
export const logger = {
  info: (message: string, meta: any = {}) => {
    console.log(JSON.stringify({
      level: 'INFO',
      message,
      timestamp: new Date().toISOString(),
      ...meta
    }));
  },
  error: (message: string, error: Error, meta: any = {}) => {
    console.error(JSON.stringify({
      level: 'ERROR',
      message,
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack
      },
      timestamp: new Date().toISOString(),
      ...meta
    }));
  }
};
```

#### CloudWatch Logs Insights 쿼리
```sql
-- 에러율 분석
fields @timestamp, level, message, error.message
| filter level = "ERROR"
| stats count() by bin(5m)

-- 처리 시간 분석
fields @timestamp, message, duration
| filter message like /Processing/
| stats avg(duration), max(duration), min(duration) by bin(5m)
```

---

### 4. X-Ray 분산 추적

```typescript
// X-Ray SDK 통합
import AWSXRay from 'aws-xray-sdk-core';
import AWS from 'aws-sdk';

const XAWS = AWSXRay.captureAWS(AWS);

export const handler = async (event) => {
  const segment = AWSXRay.getSegment();
  const subsegment = segment.addNewSubsegment('PaymentProcessing');

  try {
    // 비즈니스 로직
    const result = await processPayment(event);

    subsegment.addAnnotation('orderId', event.orderId);
    subsegment.addMetadata('result', result);

    return result;
  } catch (error) {
    subsegment.addError(error);
    throw error;
  } finally {
    subsegment.close();
  }
};
```

---

**5단계 완료**: Lambda 함수 목록 및 트리거 매핑이 완성되었습니다!

**작성일**: 2025-12-03
**버전**: 1.0
