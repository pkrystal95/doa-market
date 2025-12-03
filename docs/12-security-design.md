# 12. 보안 설계 (Security Design)

## 목차
1. [VPC 아키텍처](#1-vpc-아키텍처)
2. [IAM 역할 및 정책](#2-iam-역할-및-정책)
3. [보안 그룹 (Security Groups)](#3-보안-그룹-security-groups)
4. [WAF 규칙](#4-waf-규칙)
5. [Secrets Manager](#5-secrets-manager)
6. [암호화 전략](#6-암호화-전략)
7. [네트워크 격리](#7-네트워크-격리)
8. [보안 모니터링](#8-보안-모니터링)

---

## 1. VPC 아키텍처

### 1.1 전체 VPC 구조

```
VPC (10.0.0.0/16)
├── Public Subnets (인터넷 게이트웨이 연결)
│   ├── Public Subnet A (10.0.1.0/24) - AZ-A
│   ├── Public Subnet B (10.0.2.0/24) - AZ-B
│   └── Public Subnet C (10.0.3.0/24) - AZ-C
│
├── Private Subnets (NAT Gateway 연결)
│   ├── Private Subnet A (10.0.11.0/24) - AZ-A
│   ├── Private Subnet B (10.0.12.0/24) - AZ-B
│   └── Private Subnet C (10.0.13.0/24) - AZ-C
│
└── Database Subnets (외부 접근 불가)
    ├── DB Subnet A (10.0.21.0/24) - AZ-A
    ├── DB Subnet B (10.0.22.0/24) - AZ-B
    └── DB Subnet C (10.0.23.0/24) - AZ-C
```

### 1.2 서브넷 배치 전략

**Public Subnets (0.0.0.0/0 → IGW)**
- ALB (Application Load Balancer)
- NAT Gateway
- Bastion Host (관리용)

**Private Subnets (0.0.0.0/0 → NAT Gateway)**
- ECS Fargate Tasks (모든 마이크로서비스)
- Lambda Functions (VPC 내부)
- ElastiCache Redis
- OpenSearch Service

**Database Subnets (인터넷 접근 불가)**
- RDS PostgreSQL (Multi-AZ)
- DynamoDB VPC Endpoint로 연결

### 1.3 라우팅 테이블

**Public Subnet Route Table**
```
Destination       Target
10.0.0.0/16      local
0.0.0.0/0        igw-xxxxx (Internet Gateway)
```

**Private Subnet Route Table**
```
Destination       Target
10.0.0.0/16      local
0.0.0.0/0        nat-xxxxx (NAT Gateway)
```

**Database Subnet Route Table**
```
Destination       Target
10.0.0.0/16      local
# 외부 인터넷 연결 없음
```

### 1.4 VPC Endpoints (PrivateLink)

프라이빗 서브넷에서 AWS 서비스 접근 시 인터넷 경유 없이 직접 연결:

```yaml
VPC Endpoints:
  - S3 (Gateway Endpoint)
  - DynamoDB (Gateway Endpoint)
  - ECR (Interface Endpoint) - Docker 이미지 pull
  - CloudWatch Logs (Interface Endpoint)
  - Secrets Manager (Interface Endpoint)
  - EventBridge (Interface Endpoint)
  - SQS (Interface Endpoint)
```

**비용 절감 및 보안 강화**
- NAT Gateway 트래픽 감소
- 데이터 전송 비용 절감
- AWS 네트워크 내부에서만 통신

---

## 2. IAM 역할 및 정책

### 2.1 ECS Task 실행 역할 (Task Execution Role)

ECS가 컨테이너를 시작하고 관리하기 위한 역할

**`infrastructure/iam/ecs-task-execution-role.json`**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRImagePull",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/ecs/*"
    },
    {
      "Sid": "SecretsManager",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:doa-market/*"
    },
    {
      "Sid": "SSMParameters",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Resource": "arn:aws:ssm:*:*:parameter/doa-market/*"
    }
  ]
}
```

### 2.2 서비스별 Task Role

각 마이크로서비스가 AWS 리소스에 접근하기 위한 역할

#### 2.2.1 Product Service Task Role

**`infrastructure/iam/product-service-task-role.json`**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ProductImages",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::doa-market-products/*"
      ]
    },
    {
      "Sid": "OpenSearchAccess",
      "Effect": "Allow",
      "Action": [
        "es:ESHttpPost",
        "es:ESHttpPut",
        "es:ESHttpGet",
        "es:ESHttpDelete"
      ],
      "Resource": "arn:aws:es:*:*:domain/doa-market-search/*"
    },
    {
      "Sid": "EventBridgePublish",
      "Effect": "Allow",
      "Action": [
        "events:PutEvents"
      ],
      "Resource": "arn:aws:events:*:*:event-bus/doa-market-event-bus"
    },
    {
      "Sid": "XRayTracing",
      "Effect": "Allow",
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Resource": "*"
    }
  ]
}
```

#### 2.2.2 Order Service Task Role

**`infrastructure/iam/order-service-task-role.json`**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EventBridgePublish",
      "Effect": "Allow",
      "Action": [
        "events:PutEvents"
      ],
      "Resource": "arn:aws:events:*:*:event-bus/doa-market-event-bus"
    },
    {
      "Sid": "SQSConsume",
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ],
      "Resource": [
        "arn:aws:sqs:*:*:order-service-*"
      ]
    },
    {
      "Sid": "DynamoDBAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": [
        "arn:aws:dynamodb:*:*:table/order_events",
        "arn:aws:dynamodb:*:*:table/order_events/index/*"
      ]
    },
    {
      "Sid": "XRayTracing",
      "Effect": "Allow",
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Resource": "*"
    }
  ]
}
```

#### 2.2.3 Payment Service Task Role

**`infrastructure/iam/payment-service-task-role.json`**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SecretsManagerPGKeys",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:*:*:secret:doa-market/pg-api-keys/*"
      ]
    },
    {
      "Sid": "EventBridgePublish",
      "Effect": "Allow",
      "Action": [
        "events:PutEvents"
      ],
      "Resource": "arn:aws:events:*:*:event-bus/doa-market-event-bus"
    },
    {
      "Sid": "SQSConsume",
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": [
        "arn:aws:sqs:*:*:payment-service-*"
      ]
    },
    {
      "Sid": "SNSPublish",
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": "arn:aws:sns:*:*:payment-alerts"
    }
  ]
}
```

#### 2.2.4 File Service Task Role

**`infrastructure/iam/file-service-task-role.json`**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3FullAccess",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::doa-market-uploads/*",
        "arn:aws:s3:::doa-market-products/*",
        "arn:aws:s3:::doa-market-reviews/*"
      ]
    },
    {
      "Sid": "S3PresignedURL",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "private"
        }
      }
    }
  ]
}
```

### 2.3 Lambda 함수 실행 역할

#### 2.3.1 Image Resize Lambda Role

**`infrastructure/iam/lambda-image-resize-role.json`**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3ReadSource",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::doa-market-uploads/*"
    },
    {
      "Sid": "S3WriteResized",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::doa-market-products/*",
        "arn:aws:s3:::doa-market-reviews/*"
      ]
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/lambda/image-*"
    }
  ]
}
```

#### 2.3.2 EventBridge Consumer Lambda Role

**`infrastructure/iam/lambda-eventbridge-consumer-role.json`**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SQSConsume",
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "arn:aws:sqs:*:*:*-lambda-queue"
    },
    {
      "Sid": "EventBridgePublish",
      "Effect": "Allow",
      "Action": [
        "events:PutEvents"
      ],
      "Resource": "arn:aws:events:*:*:event-bus/doa-market-event-bus"
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

### 2.4 CI/CD 배포 역할

#### 2.4.1 GitHub Actions OIDC Role

**`infrastructure/iam/github-actions-role.json`**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRPushImages",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECSUpdateService",
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices",
        "ecs:RegisterTaskDefinition",
        "ecs:DescribeTaskDefinition"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ecs:cluster": "arn:aws:ecs:*:*:cluster/doa-market-cluster"
        }
      }
    },
    {
      "Sid": "PassRoleToECS",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": [
        "arn:aws:iam::*:role/ecsTaskExecutionRole",
        "arn:aws:iam::*:role/*-task-role"
      ]
    },
    {
      "Sid": "CodeDeploy",
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:GetApplicationRevision",
        "codedeploy:RegisterApplicationRevision"
      ],
      "Resource": "*"
    }
  ]
}
```

**Trust Policy (OIDC)**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/doa-market:*"
        }
      }
    }
  ]
}
```

---

## 3. 보안 그룹 (Security Groups)

### 3.1 ALB Security Group

**Name**: `doa-market-alb-sg`

**Inbound Rules**
```
Type        Protocol  Port Range  Source          Description
HTTPS       TCP       443         0.0.0.0/0       HTTPS from internet
HTTP        TCP       80          0.0.0.0/0       HTTP redirect to HTTPS
```

**Outbound Rules**
```
Type        Protocol  Port Range  Destination     Description
Custom TCP  TCP       3000-8000   ecs-services-sg  To ECS services
```

### 3.2 ECS Services Security Group

**Name**: `doa-market-ecs-services-sg`

**Inbound Rules**
```
Type        Protocol  Port Range  Source                 Description
Custom TCP  TCP       3000-8000   doa-market-alb-sg      From ALB
Custom TCP  TCP       3000-8000   doa-market-ecs-services-sg  Service-to-Service
```

**Outbound Rules**
```
Type        Protocol  Port Range  Destination              Description
PostgreSQL  TCP       5432        doa-market-rds-sg        To RDS
Redis       TCP       6379        doa-market-redis-sg      To Redis
HTTPS       TCP       443         doa-market-opensearch-sg To OpenSearch
HTTPS       TCP       443         0.0.0.0/0                AWS APIs (via NAT)
```

### 3.3 RDS Security Group

**Name**: `doa-market-rds-sg`

**Inbound Rules**
```
Type        Protocol  Port Range  Source                      Description
PostgreSQL  TCP       5432        doa-market-ecs-services-sg  From ECS services
PostgreSQL  TCP       5432        doa-market-lambda-sg        From Lambda
PostgreSQL  TCP       5432        doa-market-bastion-sg       From Bastion (관리용)
```

**Outbound Rules**
```
None (기본 deny all)
```

### 3.4 Redis Security Group

**Name**: `doa-market-redis-sg`

**Inbound Rules**
```
Type   Protocol  Port Range  Source                      Description
Redis  TCP       6379        doa-market-ecs-services-sg  From ECS services
Redis  TCP       6379        doa-market-lambda-sg        From Lambda
```

**Outbound Rules**
```
None (기본 deny all)
```

### 3.5 OpenSearch Security Group

**Name**: `doa-market-opensearch-sg`

**Inbound Rules**
```
Type   Protocol  Port Range  Source                      Description
HTTPS  TCP       443         doa-market-ecs-services-sg  From ECS services
HTTPS  TCP       443         doa-market-lambda-sg        From Lambda
```

**Outbound Rules**
```
None (기본 deny all)
```

### 3.6 Lambda Security Group

**Name**: `doa-market-lambda-sg`

**Inbound Rules**
```
None (Lambda는 inbound 연결 받지 않음)
```

**Outbound Rules**
```
Type        Protocol  Port Range  Destination                 Description
PostgreSQL  TCP       5432        doa-market-rds-sg           To RDS
Redis       TCP       6379        doa-market-redis-sg         To Redis
HTTPS       TCP       443         0.0.0.0/0                   AWS APIs
```

### 3.7 Bastion Host Security Group

**Name**: `doa-market-bastion-sg`

**Inbound Rules**
```
Type  Protocol  Port Range  Source                    Description
SSH   TCP       22          YOUR_OFFICE_IP/32         SSH from office IP only
```

**Outbound Rules**
```
Type        Protocol  Port Range  Destination           Description
PostgreSQL  TCP       5432        doa-market-rds-sg     To RDS
SSH         TCP       22          ecs-services-sg       To ECS (debug)
```

---

## 4. WAF 규칙

### 4.1 Web ACL 구성

**Web ACL Name**: `doa-market-waf-acl`

**연결 대상**
- API Gateway (REST API)
- CloudFront Distribution (정적 자산)
- Application Load Balancer

### 4.2 관리형 규칙 세트

**`infrastructure/waf/web-acl.json`**
```json
{
  "Name": "doa-market-waf-acl",
  "Scope": "REGIONAL",
  "DefaultAction": {
    "Allow": {}
  },
  "Rules": [
    {
      "Name": "AWSManagedRulesCommonRuleSet",
      "Priority": 1,
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesCommonRuleSet",
          "ExcludedRules": []
        }
      },
      "OverrideAction": {
        "None": {}
      },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "AWSManagedRulesCommonRuleSetMetric"
      }
    },
    {
      "Name": "AWSManagedRulesKnownBadInputsRuleSet",
      "Priority": 2,
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesKnownBadInputsRuleSet"
        }
      },
      "OverrideAction": {
        "None": {}
      },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "AWSManagedRulesKnownBadInputsRuleSetMetric"
      }
    },
    {
      "Name": "AWSManagedRulesSQLiRuleSet",
      "Priority": 3,
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesSQLiRuleSet"
        }
      },
      "OverrideAction": {
        "None": {}
      },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "AWSManagedRulesSQLiRuleSetMetric"
      }
    }
  ],
  "VisibilityConfig": {
    "SampledRequestsEnabled": true,
    "CloudWatchMetricsEnabled": true,
    "MetricName": "doa-market-waf-acl"
  }
}
```

### 4.3 커스텀 규칙

#### 4.3.1 Rate Limiting (요청 제한)

**목적**: DDoS 방지, API 남용 방지

```json
{
  "Name": "RateLimitRule",
  "Priority": 10,
  "Statement": {
    "RateBasedStatement": {
      "Limit": 2000,
      "AggregateKeyType": "IP"
    }
  },
  "Action": {
    "Block": {
      "CustomResponse": {
        "ResponseCode": 429,
        "CustomResponseBodyKey": "rate-limit-exceeded"
      }
    }
  },
  "VisibilityConfig": {
    "SampledRequestsEnabled": true,
    "CloudWatchMetricsEnabled": true,
    "MetricName": "RateLimitRule"
  }
}
```

**설명**
- IP당 5분간 2000 요청으로 제한
- 초과 시 429 Too Many Requests 반환

#### 4.3.2 Geo Blocking (지역 차단)

```json
{
  "Name": "GeoBlockingRule",
  "Priority": 11,
  "Statement": {
    "NotStatement": {
      "Statement": {
        "GeoMatchStatement": {
          "CountryCodes": ["KR", "US", "JP"]
        }
      }
    }
  },
  "Action": {
    "Block": {}
  },
  "VisibilityConfig": {
    "SampledRequestsEnabled": true,
    "CloudWatchMetricsEnabled": true,
    "MetricName": "GeoBlockingRule"
  }
}
```

**설명**
- 한국, 미국, 일본 외 국가에서의 접근 차단
- 필요 시 국가 추가/제거

#### 4.3.3 Admin Path Protection

```json
{
  "Name": "AdminPathProtection",
  "Priority": 12,
  "Statement": {
    "AndStatement": {
      "Statements": [
        {
          "ByteMatchStatement": {
            "FieldToMatch": {
              "UriPath": {}
            },
            "PositionalConstraint": "STARTS_WITH",
            "SearchString": "/api/v1/admin",
            "TextTransformations": [
              {
                "Type": "LOWERCASE",
                "Priority": 0
              }
            ]
          }
        },
        {
          "NotStatement": {
            "Statement": {
              "IPSetReferenceStatement": {
                "Arn": "arn:aws:wafv2:region:account:regional/ipset/admin-ips/xxxxx"
              }
            }
          }
        }
      ]
    }
  },
  "Action": {
    "Block": {}
  },
  "VisibilityConfig": {
    "SampledRequestsEnabled": true,
    "CloudWatchMetricsEnabled": true,
    "MetricName": "AdminPathProtection"
  }
}
```

**설명**
- `/api/v1/admin` 경로는 특정 IP에서만 접근 가능
- IP Set에 사무실 IP, VPN IP 등록

#### 4.3.4 User-Agent Filtering (봇 차단)

```json
{
  "Name": "BlockBadBots",
  "Priority": 13,
  "Statement": {
    "OrStatement": {
      "Statements": [
        {
          "ByteMatchStatement": {
            "FieldToMatch": {
              "SingleHeader": {
                "Name": "user-agent"
              }
            },
            "PositionalConstraint": "CONTAINS",
            "SearchString": "bot",
            "TextTransformations": [
              {
                "Type": "LOWERCASE",
                "Priority": 0
              }
            ]
          }
        },
        {
          "ByteMatchStatement": {
            "FieldToMatch": {
              "SingleHeader": {
                "Name": "user-agent"
              }
            },
            "PositionalConstraint": "CONTAINS",
            "SearchString": "crawler",
            "TextTransformations": [
              {
                "Type": "LOWERCASE",
                "Priority": 0
              }
            ]
          }
        }
      ]
    }
  },
  "Action": {
    "Block": {}
  },
  "VisibilityConfig": {
    "SampledRequestsEnabled": true,
    "CloudWatchMetricsEnabled": true,
    "MetricName": "BlockBadBots"
  }
}
```

**예외 처리**
- 구글봇, 네이버봇 등 정상 크롤러는 별도 Allow 규칙 추가

---

## 5. Secrets Manager

### 5.1 시크릿 구조

```
/doa-market/
├── databases/
│   ├── product-db        # PostgreSQL 연결 정보
│   ├── order-db
│   ├── user-db
│   ├── payment-db
│   ├── inventory-db
│   ├── shipping-db
│   └── seller-db
│
├── pg-api-keys/          # 결제 게이트웨이 API 키
│   ├── toss-payments
│   ├── inicis
│   └── nice-pay
│
├── external-apis/        # 외부 API 키
│   ├── kakao-api
│   ├── naver-api
│   ├── aws-ses
│   └── firebase-fcm
│
├── jwt/                  # JWT 시크릿
│   ├── access-token-secret
│   └── refresh-token-secret
│
└── redis/                # Redis 비밀번호
    └── auth-token
```

### 5.2 시크릿 예시

#### 5.2.1 Database Connection Secret

**Secret Name**: `/doa-market/databases/product-db`

**Secret Value (JSON)**
```json
{
  "engine": "postgres",
  "host": "doa-market-product-db.cluster-xxxxx.ap-northeast-2.rds.amazonaws.com",
  "port": 5432,
  "username": "product_service",
  "password": "RANDOM_64_CHAR_PASSWORD",
  "dbname": "product_db",
  "ssl": true,
  "pool": {
    "min": 2,
    "max": 10
  }
}
```

**로테이션 설정**
- 자동 로테이션: 30일마다
- Lambda 함수: AWS 제공 RDS 로테이션 함수 사용

#### 5.2.2 PG API Keys Secret

**Secret Name**: `/doa-market/pg-api-keys/toss-payments`

**Secret Value (JSON)**
```json
{
  "clientKey": "test_ck_XXXXXXXXXXXXXXXXXXXXX",
  "secretKey": "test_sk_XXXXXXXXXXXXXXXXXXXXX",
  "environment": "production",
  "webhookSecret": "RANDOM_WEBHOOK_SECRET"
}
```

#### 5.2.3 JWT Secrets

**Secret Name**: `/doa-market/jwt/access-token-secret`

**Secret Value (PlainText)**
```
RANDOM_256_BIT_BASE64_ENCODED_STRING
```

**로테이션 설정**
- 수동 로테이션 (분기별)
- 로테이션 시 기존 키 유지 (grace period 7일)

### 5.3 코드에서 시크릿 사용

**Node.js (TypeScript)**

**`backend/services/product-service/src/config/secrets.ts`**
```typescript
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from '@aws-sdk/client-secrets-manager';

const secretsClient = new SecretsManagerClient({
  region: process.env.AWS_REGION || 'ap-northeast-2',
});

// 캐싱 (5분간 유효)
const secretCache: Map<string, { value: any; expiresAt: number }> = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5분

export async function getSecret<T = any>(secretName: string): Promise<T> {
  // 캐시 확인
  const cached = secretCache.get(secretName);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.value as T;
  }

  try {
    const response = await secretsClient.send(
      new GetSecretValueCommand({
        SecretId: secretName,
      })
    );

    let secretValue: any;
    if (response.SecretString) {
      // JSON 형식 시크릿
      try {
        secretValue = JSON.parse(response.SecretString);
      } catch {
        // Plain text 시크릿
        secretValue = response.SecretString;
      }
    } else if (response.SecretBinary) {
      // Binary 시크릿
      const buff = Buffer.from(response.SecretBinary);
      secretValue = buff.toString('utf-8');
    }

    // 캐싱
    secretCache.set(secretName, {
      value: secretValue,
      expiresAt: Date.now() + CACHE_TTL,
    });

    return secretValue as T;
  } catch (error) {
    logger.error('Failed to retrieve secret', {
      secretName,
      error: error.message,
    });
    throw error;
  }
}

// 데이터베이스 연결 정보 가져오기
export async function getDatabaseConfig() {
  const dbSecret = await getSecret<{
    host: string;
    port: number;
    username: string;
    password: string;
    dbname: string;
    ssl: boolean;
  }>('/doa-market/databases/product-db');

  return {
    type: 'postgres' as const,
    host: dbSecret.host,
    port: dbSecret.port,
    username: dbSecret.username,
    password: dbSecret.password,
    database: dbSecret.dbname,
    ssl: dbSecret.ssl,
  };
}
```

**사용 예시**
```typescript
import { getDatabaseConfig } from './config/secrets';
import { DataSource } from 'typeorm';

async function initializeDatabase() {
  const dbConfig = await getDatabaseConfig();

  const dataSource = new DataSource({
    ...dbConfig,
    entities: ['src/models/**/*.ts'],
    synchronize: false,
  });

  await dataSource.initialize();
  return dataSource;
}
```

### 5.4 ECS Task Definition에서 시크릿 주입

**`infrastructure/ecs/product-service-task-definition.json`**
```json
{
  "family": "product-service",
  "taskRoleArn": "arn:aws:iam::ACCOUNT_ID:role/product-service-task-role",
  "executionRoleArn": "arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "product-service",
      "image": "ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/product-service:latest",
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "AWS_REGION",
          "value": "ap-northeast-2"
        }
      ],
      "secrets": [
        {
          "name": "DB_SECRET",
          "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:ACCOUNT_ID:secret:/doa-market/databases/product-db"
        },
        {
          "name": "JWT_ACCESS_SECRET",
          "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:ACCOUNT_ID:secret:/doa-market/jwt/access-token-secret"
        },
        {
          "name": "JWT_REFRESH_SECRET",
          "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:ACCOUNT_ID:secret:/doa-market/jwt/refresh-token-secret"
        }
      ]
    }
  ]
}
```

**코드에서 사용**
```typescript
// Secrets Manager를 직접 호출하지 않고 환경 변수로 주입됨
const dbSecret = JSON.parse(process.env.DB_SECRET!);
const jwtSecret = process.env.JWT_ACCESS_SECRET!;
```

---

## 6. 암호화 전략

### 6.1 전송 중 암호화 (Encryption in Transit)

**모든 통신 TLS 1.2+ 사용**

| 구간 | 프로토콜 | 인증서 |
|------|----------|--------|
| Client → CloudFront | HTTPS (TLS 1.3) | ACM Certificate |
| CloudFront → ALB | HTTPS (TLS 1.2) | ACM Certificate |
| ALB → ECS Services | HTTP (VPC 내부) | - |
| ECS → RDS | PostgreSQL TLS | RDS CA Certificate |
| ECS → Redis | TLS Enabled | ElastiCache Certificate |
| ECS → OpenSearch | HTTPS | Fine-grained access control |
| ECS → AWS APIs | HTTPS | AWS-managed |

**ALB HTTPS Listener 설정**
```json
{
  "Protocol": "HTTPS",
  "Port": 443,
  "Certificates": [
    {
      "CertificateArn": "arn:aws:acm:region:account:certificate/xxxxx"
    }
  ],
  "SslPolicy": "ELBSecurityPolicy-TLS-1-2-2017-01",
  "DefaultActions": [
    {
      "Type": "forward",
      "TargetGroupArn": "arn:aws:elasticloadbalancing:..."
    }
  ]
}
```

**RDS TLS 강제 설정**
```sql
-- PostgreSQL Parameter Group
rds.force_ssl = 1
```

**Redis TLS 설정**
```
TransitEncryptionEnabled: true
```

### 6.2 저장 데이터 암호화 (Encryption at Rest)

#### 6.2.1 RDS 암호화

**KMS Key**: `alias/doa-market-rds-key`

```json
{
  "StorageEncrypted": true,
  "KmsKeyId": "arn:aws:kms:ap-northeast-2:ACCOUNT_ID:key/xxxxx",
  "EnableCloudwatchLogsExports": ["postgresql"],
  "BackupRetentionPeriod": 7,
  "PreferredBackupWindow": "03:00-04:00"
}
```

**자동 백업 암호화**
- 스냅샷: 자동 암호화 (동일 KMS 키)
- Point-in-Time Recovery: 활성화

#### 6.2.2 DynamoDB 암호화

**KMS Key**: `alias/doa-market-dynamodb-key`

```json
{
  "TableName": "order_events",
  "SSESpecification": {
    "Enabled": true,
    "SSEType": "KMS",
    "KMSMasterKeyId": "arn:aws:kms:ap-northeast-2:ACCOUNT_ID:key/xxxxx"
  }
}
```

#### 6.2.3 S3 암호화

**Bucket**: `doa-market-uploads`, `doa-market-products`, `doa-market-reviews`

**Default Encryption**
```json
{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "arn:aws:kms:ap-northeast-2:ACCOUNT_ID:alias/doa-market-s3-key"
      },
      "BucketKeyEnabled": true
    }
  ]
}
```

**Bucket Policy (강제 암호화)**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::doa-market-uploads/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    }
  ]
}
```

#### 6.2.4 ElastiCache Redis 암호화

```json
{
  "AtRestEncryptionEnabled": true,
  "TransitEncryptionEnabled": true,
  "AuthToken": "STRONG_RANDOM_PASSWORD_FROM_SECRETS_MANAGER",
  "KmsKeyId": "arn:aws:kms:ap-northeast-2:ACCOUNT_ID:key/xxxxx"
}
```

#### 6.2.5 OpenSearch 암호화

```json
{
  "EncryptionAtRestOptions": {
    "Enabled": true,
    "KmsKeyId": "arn:aws:kms:ap-northeast-2:ACCOUNT_ID:key/xxxxx"
  },
  "NodeToNodeEncryptionOptions": {
    "Enabled": true
  },
  "DomainEndpointOptions": {
    "EnforceHTTPS": true,
    "TLSSecurityPolicy": "Policy-Min-TLS-1-2-2019-07"
  }
}
```

### 6.3 KMS Key 정책

**`infrastructure/kms/doa-market-rds-key-policy.json`**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow RDS to use the key",
      "Effect": "Allow",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Action": [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:CreateGrant"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "rds.ap-northeast-2.amazonaws.com"
        }
      }
    },
    {
      "Sid": "Allow ECS tasks to decrypt",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:role/*-task-role"
      },
      "Action": [
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## 7. 네트워크 격리

### 7.1 3-Tier 아키텍처

```
Internet
   ↓
[Internet Gateway]
   ↓
┌─────────────────────────────────────────┐
│ Public Subnet (Tier 1)                  │
│ - ALB (443, 80)                         │
│ - NAT Gateway                           │
│ - Bastion Host (22, whitelisted IP)    │
└─────────────────────────────────────────┘
   ↓
[Security Group: ALB → ECS]
   ↓
┌─────────────────────────────────────────┐
│ Private Subnet (Tier 2)                 │
│ - ECS Fargate Tasks                     │
│ - Lambda Functions (VPC)                │
│ - ElastiCache Redis                     │
│ - OpenSearch Service                    │
└─────────────────────────────────────────┘
   ↓
[Security Group: ECS → RDS]
   ↓
┌─────────────────────────────────────────┐
│ Database Subnet (Tier 3)                │
│ - RDS PostgreSQL (Multi-AZ)             │
│ - No Internet Access                    │
└─────────────────────────────────────────┘
```

### 7.2 네트워크 ACL (NACL)

**Public Subnet NACL**
```
Inbound Rules:
Rule #  Type         Protocol  Port Range  Source          Allow/Deny
100     HTTP         TCP       80          0.0.0.0/0       ALLOW
110     HTTPS        TCP       443         0.0.0.0/0       ALLOW
120     SSH          TCP       22          OFFICE_IP/32    ALLOW
*       All Traffic  All       All         0.0.0.0/0       DENY

Outbound Rules:
Rule #  Type         Protocol  Port Range  Destination     Allow/Deny
100     All Traffic  All       All         0.0.0.0/0       ALLOW
```

**Private Subnet NACL**
```
Inbound Rules:
Rule #  Type         Protocol  Port Range  Source          Allow/Deny
100     All Traffic  TCP       1024-65535  10.0.0.0/16     ALLOW
110     PostgreSQL   TCP       5432        10.0.0.0/16     ALLOW
120     Redis        TCP       6379        10.0.0.0/16     ALLOW
*       All Traffic  All       All         0.0.0.0/0       DENY

Outbound Rules:
Rule #  Type         Protocol  Port Range  Destination     Allow/Deny
100     All Traffic  All       All         0.0.0.0/0       ALLOW
```

**Database Subnet NACL**
```
Inbound Rules:
Rule #  Type         Protocol  Port Range  Source          Allow/Deny
100     PostgreSQL   TCP       5432        10.0.11.0/24    ALLOW
110     PostgreSQL   TCP       5432        10.0.12.0/24    ALLOW
120     PostgreSQL   TCP       5432        10.0.13.0/24    ALLOW
*       All Traffic  All       All         0.0.0.0/0       DENY

Outbound Rules:
Rule #  Type         Protocol  Port Range  Destination     Allow/Deny
100     TCP Response TCP       1024-65535  10.0.11.0/24    ALLOW
110     TCP Response TCP       1024-65535  10.0.12.0/24    ALLOW
120     TCP Response TCP       1024-65535  10.0.13.0/24    ALLOW
*       All Traffic  All       All         0.0.0.0/0       DENY
```

### 7.3 VPC Flow Logs

**모든 트래픽 로깅**

```json
{
  "ResourceType": "VPC",
  "ResourceIds": ["vpc-xxxxx"],
  "TrafficType": "ALL",
  "LogDestinationType": "cloud-watch-logs",
  "LogGroupName": "/aws/vpc/doa-market-vpc-flow-logs",
  "DeliverLogsPermissionArn": "arn:aws:iam::ACCOUNT_ID:role/vpc-flow-logs-role",
  "LogFormat": "${srcaddr} ${dstaddr} ${srcport} ${dstport} ${protocol} ${packets} ${bytes} ${start} ${end} ${action} ${log-status}"
}
```

**분석 쿼리 (CloudWatch Logs Insights)**

**Rejected 연결 분석**
```
fields @timestamp, srcAddr, dstAddr, dstPort, action
| filter action = "REJECT"
| stats count(*) by srcAddr, dstPort
| sort count desc
| limit 20
```

**Top Talkers (통신량 많은 IP)**
```
fields @timestamp, srcAddr, dstAddr, bytes
| stats sum(bytes) as totalBytes by srcAddr
| sort totalBytes desc
| limit 10
```

---

## 8. 보안 모니터링

### 8.1 CloudWatch Alarms

#### 8.1.1 WAF 관련 알람

**High Request Rate**
```json
{
  "AlarmName": "WAF-HighRequestRate",
  "MetricName": "AllowedRequests",
  "Namespace": "AWS/WAFV2",
  "Statistic": "Sum",
  "Period": 300,
  "EvaluationPeriods": 2,
  "Threshold": 100000,
  "ComparisonOperator": "GreaterThanThreshold",
  "AlarmActions": [
    "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:security-alerts"
  ]
}
```

**Blocked Requests Spike**
```json
{
  "AlarmName": "WAF-BlockedRequestsSpike",
  "MetricName": "BlockedRequests",
  "Namespace": "AWS/WAFV2",
  "Statistic": "Sum",
  "Period": 300,
  "EvaluationPeriods": 1,
  "Threshold": 1000,
  "ComparisonOperator": "GreaterThanThreshold",
  "AlarmActions": [
    "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:security-alerts"
  ]
}
```

#### 8.1.2 IAM 관련 알람

**Unauthorized API Calls (CloudTrail)**

**CloudWatch Logs Metric Filter**
```json
{
  "filterName": "UnauthorizedAPICalls",
  "filterPattern": "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }",
  "logGroupName": "/aws/cloudtrail/doa-market"
}
```

**Alarm**
```json
{
  "AlarmName": "IAM-UnauthorizedAPICalls",
  "MetricName": "UnauthorizedAPICallsCount",
  "Namespace": "CloudTrailMetrics",
  "Statistic": "Sum",
  "Period": 300,
  "EvaluationPeriods": 1,
  "Threshold": 5,
  "ComparisonOperator": "GreaterThanThreshold",
  "AlarmActions": [
    "arn:aws:sns:ap-northeast-2:ACCOUNT_ID:security-alerts"
  ]
}
```

#### 8.1.3 RDS 관련 알람

**Failed Login Attempts**

**CloudWatch Logs Metric Filter (PostgreSQL 로그)**
```json
{
  "filterName": "RDS-FailedLoginAttempts",
  "filterPattern": "[time, host, user, db, pid, line, type=FATAL, code=28P01, ...]",
  "logGroupName": "/aws/rds/cluster/doa-market-product-db/postgresql"
}
```

### 8.2 AWS GuardDuty

**위협 탐지 서비스 활성화**

```json
{
  "DetectorId": "xxxxx",
  "Enable": true,
  "FindingPublishingFrequency": "FIFTEEN_MINUTES",
  "DataSources": {
    "S3Logs": {
      "Enable": true
    },
    "Kubernetes": {
      "AuditLogs": {
        "Enable": true
      }
    }
  }
}
```

**주요 탐지 항목**
- Backdoor:EC2/DenialOfService
- CryptoCurrency:EC2/BitcoinTool
- Trojan:EC2/DNSDataExfiltration
- UnauthorizedAccess:EC2/SSHBruteForce
- UnauthorizedAccess:IAMUser/InstanceCredentialExfiltration
- Recon:EC2/PortProbeUnprotectedPort

**EventBridge 연동**
```json
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"],
  "detail": {
    "severity": [7, 8, 8.9]
  }
}
```
→ Lambda 함수 트리거 → Slack/PagerDuty 알림

### 8.3 AWS Security Hub

**통합 보안 대시보드**

```json
{
  "EnableDefaultStandards": true,
  "EnabledStandards": [
    "arn:aws:securityhub:ap-northeast-2::standards/aws-foundational-security-best-practices/v/1.0.0",
    "arn:aws:securityhub:ap-northeast-2::standards/cis-aws-foundations-benchmark/v/1.2.0"
  ]
}
```

**주요 체크 항목**
- IAM.1: IAM policies should not allow full "*:*" administrative privileges
- EC2.2: VPC default security group should prohibit inbound and outbound traffic
- RDS.3: RDS DB instances should have encryption at rest enabled
- S3.4: S3 buckets should have server-side encryption enabled
- CloudTrail.1: CloudTrail should be enabled and configured with at least one multi-region trail

### 8.4 CloudTrail 로깅

**모든 API 호출 로깅**

```json
{
  "Name": "doa-market-trail",
  "S3BucketName": "doa-market-cloudtrail-logs",
  "IncludeGlobalServiceEvents": true,
  "IsMultiRegionTrail": true,
  "EnableLogFileValidation": true,
  "EventSelectors": [
    {
      "ReadWriteType": "All",
      "IncludeManagementEvents": true,
      "DataResources": [
        {
          "Type": "AWS::S3::Object",
          "Values": [
            "arn:aws:s3:::doa-market-uploads/*",
            "arn:aws:s3:::doa-market-products/*"
          ]
        },
        {
          "Type": "AWS::Lambda::Function",
          "Values": ["arn:aws:lambda:*:*:function/*"]
        }
      ]
    }
  ],
  "InsightSelectors": [
    {
      "InsightType": "ApiCallRateInsight"
    }
  ]
}
```

**S3 버킷 정책 (CloudTrail 쓰기 권한)**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::doa-market-cloudtrail-logs"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::doa-market-cloudtrail-logs/AWSLogs/ACCOUNT_ID/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
```

### 8.5 보안 인시던트 대응

**인시던트 대응 플레이북**

#### Step 1: 탐지 (Detection)
- GuardDuty Finding 발생
- Security Hub 알림
- CloudWatch Alarm 트리거
- 비정상 로그 패턴 감지

#### Step 2: 격리 (Containment)
```bash
# 의심스러운 ECS Task 즉시 중지
aws ecs stop-task \
  --cluster doa-market-cluster \
  --task <task-arn> \
  --reason "Security incident"

# Security Group 인바운드 규칙 즉시 제거
aws ec2 revoke-security-group-ingress \
  --group-id sg-xxxxx \
  --ip-permissions ...

# IAM 사용자 액세스 키 비활성화
aws iam update-access-key \
  --access-key-id AKIAXXXXX \
  --status Inactive \
  --user-name compromised-user
```

#### Step 3: 조사 (Investigation)
```bash
# CloudTrail 로그 분석
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=compromised-user \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z

# VPC Flow Logs 분석
aws logs filter-log-events \
  --log-group-name /aws/vpc/doa-market-vpc-flow-logs \
  --filter-pattern "10.0.1.100"

# GuardDuty Finding 상세 조회
aws guardduty get-findings \
  --detector-id xxxxx \
  --finding-ids xxxxx
```

#### Step 4: 복구 (Recovery)
- 영향받은 리소스 재생성
- 시크릿 로테이션
- IAM 정책 재검토
- 백업에서 복구 (필요 시)

#### Step 5: 사후 분석 (Post-Incident)
- 근본 원인 분석
- 보안 정책 업데이트
- 팀 교육
- 문서화

---

## 9. 보안 체크리스트

### 9.1 네트워크 보안
- [ ] VPC 3-tier 아키텍처 구현
- [ ] Private Subnet에 NAT Gateway 배치
- [ ] Database Subnet은 인터넷 접근 불가
- [ ] Security Group은 최소 권한 원칙
- [ ] NACL로 추가 방어 계층 구현
- [ ] VPC Flow Logs 활성화
- [ ] VPC Endpoints로 AWS 서비스 접근

### 9.2 인증 및 권한
- [ ] IAM 역할은 최소 권한 원칙
- [ ] Root 계정 사용 금지
- [ ] MFA 활성화 (모든 IAM 사용자)
- [ ] IAM Access Analyzer 활성화
- [ ] Service Control Policies (SCP) 적용
- [ ] Cross-account access는 External ID 사용

### 9.3 암호화
- [ ] 모든 데이터 전송 시 TLS 1.2+ 사용
- [ ] RDS 암호화 활성화
- [ ] DynamoDB 암호화 활성화
- [ ] S3 버킷 기본 암호화 활성화
- [ ] ElastiCache 암호화 활성화
- [ ] KMS 키 정책 검토
- [ ] 암호화되지 않은 객체 업로드 차단

### 9.4 시크릿 관리
- [ ] 하드코딩된 비밀번호 없음
- [ ] Secrets Manager로 모든 시크릿 관리
- [ ] 자동 시크릿 로테이션 설정
- [ ] 시크릿 액세스 로그 활성화
- [ ] 환경 변수 대신 Secrets Manager 사용

### 9.5 애플리케이션 보안
- [ ] WAF 활성화 (API Gateway, ALB, CloudFront)
- [ ] Rate Limiting 설정
- [ ] SQL Injection 방어
- [ ] XSS 방어
- [ ] CSRF 토큰 사용
- [ ] Input validation
- [ ] Output encoding

### 9.6 모니터링
- [ ] CloudTrail 활성화 (Multi-Region)
- [ ] GuardDuty 활성화
- [ ] Security Hub 활성화
- [ ] CloudWatch Alarms 설정
- [ ] VPC Flow Logs 분석
- [ ] X-Ray 추적 활성화

### 9.7 백업 및 복구
- [ ] RDS 자동 백업 활성화
- [ ] RDS Point-in-Time Recovery 활성화
- [ ] DynamoDB PITR 활성화
- [ ] S3 버전 관리 활성화
- [ ] S3 Lifecycle 정책 설정
- [ ] 재해 복구 계획 수립

### 9.8 컴플라이언스
- [ ] PCI-DSS 요구사항 검토 (결제 데이터)
- [ ] 개인정보보호법 준수
- [ ] 데이터 보존 정책 수립
- [ ] 감사 로그 90일 이상 보존
- [ ] 정기 보안 감사 실시

---

## 10. 참고 자료

### AWS 보안 베스트 프랙티스
- [AWS Well-Architected Framework - Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)

### 도구
- [AWS IAM Policy Simulator](https://policysim.aws.amazon.com/)
- [AWS Trusted Advisor](https://aws.amazon.com/premiumsupport/technology/trusted-advisor/)
- [Prowler (오픈소스 보안 스캐너)](https://github.com/prowler-cloud/prowler)

---

**문서 버전**: 1.0
**최종 수정일**: 2024-01-15
**작성자**: DOA Market DevOps Team
