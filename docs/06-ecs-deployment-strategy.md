# 6단계: EKS/ECS Fargate 배포 전략

## 목차
- [EKS vs ECS Fargate 비교](#eks-vs-ecs-fargate-비교)
- [ECS Fargate 아키텍처](#ecs-fargate-아키텍처)
- [Task 및 Service 정의](#task-및-service-정의)
- [Auto Scaling 전략](#auto-scaling-전략)
- [배포 전략](#배포-전략)
- [네트워킹 및 서비스 디스커버리](#네트워킹-및-서비스-디스커버리)
- [보안 설정](#보안-설정)

---

## EKS vs ECS Fargate 비교

### 옵션 1: Amazon EKS (Elastic Kubernetes Service)

#### 장점
✅ **표준화**: Kubernetes 표준 사용으로 멀티 클라우드 호환
✅ **에코시스템**: 풍부한 도구 (Helm, Istio, Prometheus, ArgoCD)
✅ **유연성**: 세밀한 제어와 커스터마이징 가능
✅ **확장성**: 대규모 마이크로서비스 환경에 적합
✅ **커뮤니티**: 활발한 오픈소스 커뮤니티

#### 단점
❌ **복잡도**: 높은 학습 곡선 및 운영 복잡도
❌ **비용**: 컨트롤 플레인 비용 ($0.10/hour ≈ $73/month)
❌ **관리 부담**: 노드 관리, 업그레이드, 보안 패치 필요
❌ **초기 설정**: 클러스터 구성에 시간 소요

#### 추천 시나리오
- 50개 이상의 마이크로서비스
- 복잡한 네트워킹 요구사항 (Service Mesh 등)
- 기존 Kubernetes 경험 보유
- 멀티 클라우드 전략

---

### 옵션 2: Amazon ECS Fargate

#### 장점
✅ **서버리스**: 인프라 관리 완전 자동화
✅ **간편성**: 빠른 시작 및 간단한 설정
✅ **AWS 통합**: IAM, CloudWatch, X-Ray 네이티브 연동
✅ **비용 효율**: 사용한 만큼만 과금, 컨트롤 플레인 비용 없음
✅ **보안**: AWS 책임 공유 모델로 보안 부담 감소

#### 단점
❌ **AWS 종속**: AWS 외 환경 사용 불가
❌ **제한**: Kubernetes 에코시스템 미사용
❌ **유연성**: 일부 고급 기능 제한
❌ **비용**: 대규모 워크로드에서는 EC2 대비 비쌀 수 있음

#### 추천 시나리오
- 50개 미만의 마이크로서비스
- 빠른 출시 필요
- 인프라 관리 최소화
- AWS 중심 아키텍처

---

## 추천: ECS Fargate 채택

### 선택 이유

16개 마이크로서비스로 구성된 오픈마켓 프로젝트에서는 **Amazon ECS Fargate**를 추천합니다.

**핵심 근거**:
1. **적정 규모**: 16개 서비스는 ECS로 충분히 관리 가능
2. **관리 효율**: 인프라 관리 부담 최소화로 개발에 집중
3. **AWS 생태계**: EventBridge, RDS, DynamoDB와 seamless 통합
4. **비용 최적화**: 초기 단계에서 불필요한 인프라 비용 절감
5. **빠른 배포**: 낮은 학습 곡선으로 빠른 개발 및 배포 가능

**향후 마이그레이션 경로**:
- 서비스가 50개 이상으로 확장되면 EKS로 마이그레이션 고려
- ECS Task Definition을 Kubernetes Deployment로 변환 가능

---

## ECS Fargate 아키텍처

### 전체 구조

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Application Load Balancer                        │
│                    alb.doamarket.com                                │
│                    *.doamarket.com                                  │
└───────┬─────────────────────────────────────────────────────────────┘
        │
        ├─── /api/v1/auth/*        → Target Group → auth-service:3001
        ├─── /api/v1/users/*       → Target Group → user-service:3002
        ├─── /api/v1/products/*    → Target Group → product-service:3003
        ├─── /api/v1/orders/*      → Target Group → order-service:3004
        ├─── /api/v1/payments/*    → Target Group → payment-service:3005
        └─── ...
        │
┌───────▼──────────────────────────────────────────────────────────────┐
│                    ECS Cluster: doa-market-cluster                   │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │ ECS Service      │  │ ECS Service      │  │ ECS Service      │  │
│  │ auth-service     │  │ user-service     │  │ product-service  │  │
│  │                  │  │                  │  │                  │  │
│  │ Desired: 2       │  │ Desired: 3       │  │ Desired: 4       │  │
│  │ Running: 2       │  │ Running: 3       │  │ Running: 4       │  │
│  │                  │  │                  │  │                  │  │
│  │ ┌─────┐ ┌─────┐ │  │ ┌─────┐ ┌─────┐ │  │ ┌─────┐ ┌─────┐ │  │
│  │ │Task1│ │Task2│ │  │ │Task1│ │Task2│ │  │ │Task1│ │Task2│ │  │
│  │ └─────┘ └─────┘ │  │ └─────┘ └─────┘ │  │ └─────┘ └─────┘ │  │
│  │                  │  │         └─────┘ │  │ ┌─────┐ ┌─────┐ │  │
│  │                  │  │         │Task3│ │  │ │Task3│ │Task4│ │  │
│  │                  │  │         └─────┘ │  │ └─────┘ └─────┘ │  │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  │
│                                                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │ ECS Service      │  │ ECS Service      │  │ ECS Service      │  │
│  │ order-service    │  │ payment-service  │  │ shipping-service │  │
│  │ Desired: 5       │  │ Desired: 3       │  │ Desired: 2       │  │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  │
│                                                                       │
│  ... (remaining 10 services)                                         │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  Service Discovery: AWS Cloud Map                              │ │
│  │  - auth-service.local → 10.0.10.x                              │ │
│  │  - user-service.local → 10.0.10.x                              │ │
│  │  - product-service.local → 10.0.10.x                           │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  Auto Scaling: Application Auto Scaling                        │ │
│  │  - Target Tracking: CPU 70%, Memory 80%                        │ │
│  │  - Min: 2, Max: 20 (서비스별 차등)                             │ │
│  └────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────────┘
```

---

## Task 및 Service 정의

### ECS Task Definition

각 마이크로서비스는 독립적인 Task Definition으로 정의됩니다.

#### Product Service Task Definition

```json
{
  "family": "product-service",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/productServiceTaskRole",
  "containerDefinitions": [
    {
      "name": "product-service",
      "image": "123456789012.dkr.ecr.ap-northeast-2.amazonaws.com/product-service:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3003,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "PORT",
          "value": "3003"
        },
        {
          "name": "SERVICE_NAME",
          "value": "product-service"
        },
        {
          "name": "AWS_REGION",
          "value": "ap-northeast-2"
        }
      ],
      "secrets": [
        {
          "name": "DB_HOST",
          "valueFrom": "arn:aws:ssm:ap-northeast-2:123456789012:parameter/doa-market/products-db/host"
        },
        {
          "name": "DB_NAME",
          "valueFrom": "arn:aws:ssm:ap-northeast-2:123456789012:parameter/doa-market/products-db/name"
        },
        {
          "name": "DB_USER",
          "valueFrom": "arn:aws:ssm:ap-northeast-2:123456789012:parameter/doa-market/products-db/user"
        },
        {
          "name": "DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:123456789012:secret:products-db-password-abc123"
        },
        {
          "name": "REDIS_HOST",
          "valueFrom": "arn:aws:ssm:ap-northeast-2:123456789012:parameter/doa-market/redis/host"
        },
        {
          "name": "REDIS_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:ap-northeast-2:123456789012:secret:redis-password-xyz789"
        },
        {
          "name": "OPENSEARCH_ENDPOINT",
          "valueFrom": "arn:aws:ssm:ap-northeast-2:123456789012:parameter/doa-market/opensearch/endpoint"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/product-service",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs",
          "awslogs-create-group": "true"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:3003/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "ulimits": [
        {
          "name": "nofile",
          "softLimit": 65536,
          "hardLimit": 65536
        }
      ],
      "stopTimeout": 30
    }
  ],
  "tags": [
    {
      "key": "Environment",
      "value": "production"
    },
    {
      "key": "Service",
      "value": "product"
    },
    {
      "key": "ManagedBy",
      "value": "terraform"
    }
  ]
}
```

### 서비스별 리소스 할당

| 서비스 | CPU | Memory | 설명 |
|--------|-----|--------|------|
| auth-service | 256 | 512MB | 가벼운 인증 로직 |
| user-service | 256 | 512MB | CRUD 위주 |
| product-service | 512 | 1024MB | 이미지 처리, 검색 |
| order-service | 512 | 1024MB | 복잡한 비즈니스 로직 |
| payment-service | 512 | 1024MB | 외부 API 호출 |
| shipping-service | 256 | 512MB | 간단한 로직 |
| seller-service | 256 | 512MB | CRUD 위주 |
| settlement-service | 512 | 1024MB | 계산 집약적 |
| coupon-service | 256 | 512MB | 가벼운 로직 |
| inventory-service | 512 | 1024MB | 동시성 처리 |
| notification-service | 256 | 512MB | 외부 API 호출 |
| review-service | 256 | 512MB | CRUD 위주 |
| search-service | 512 | 1024MB | OpenSearch 연동 |
| admin-service | 512 | 1024MB | 복잡한 조회 |
| file-service | 512 | 1024MB | S3 업로드 |
| stats-service | 512 | 1024MB | 데이터 집계 |

---

### ECS Service Definition

```json
{
  "serviceName": "product-service",
  "cluster": "doa-market-cluster",
  "taskDefinition": "product-service:12",
  "desiredCount": 3,
  "launchType": "FARGATE",
  "platformVersion": "LATEST",
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": [
        "subnet-0abc123-app-az-a",
        "subnet-0def456-app-az-c"
      ],
      "securityGroups": ["sg-0xyz789-app"],
      "assignPublicIp": "DISABLED"
    }
  },
  "loadBalancers": [
    {
      "targetGroupArn": "arn:aws:elasticloadbalancing:ap-northeast-2:123456789012:targetgroup/product-service/abc123",
      "containerName": "product-service",
      "containerPort": 3003
    }
  ],
  "serviceRegistries": [
    {
      "registryArn": "arn:aws:servicediscovery:ap-northeast-2:123456789012:service/srv-abc123",
      "containerName": "product-service",
      "containerPort": 3003
    }
  ],
  "deploymentConfiguration": {
    "deploymentCircuitBreaker": {
      "enable": true,
      "rollback": true
    },
    "maximumPercent": 200,
    "minimumHealthyPercent": 100
  },
  "deploymentController": {
    "type": "ECS"
  },
  "enableECSManagedTags": true,
  "propagateTags": "SERVICE",
  "enableExecuteCommand": true,
  "tags": [
    {
      "key": "Environment",
      "value": "production"
    },
    {
      "key": "Service",
      "value": "product"
    }
  ]
}
```

---

## Auto Scaling 전략

### Application Auto Scaling

#### Target Tracking Scaling Policy (CPU)

```json
{
  "PolicyName": "product-service-cpu-scaling",
  "ServiceNamespace": "ecs",
  "ResourceId": "service/doa-market-cluster/product-service",
  "ScalableDimension": "ecs:service:DesiredCount",
  "PolicyType": "TargetTrackingScaling",
  "TargetTrackingScalingPolicyConfiguration": {
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
    },
    "ScaleInCooldown": 300,
    "ScaleOutCooldown": 60
  }
}
```

#### Target Tracking Scaling Policy (Memory)

```json
{
  "PolicyName": "product-service-memory-scaling",
  "ServiceNamespace": "ecs",
  "ResourceId": "service/doa-market-cluster/product-service",
  "ScalableDimension": "ecs:service:DesiredCount",
  "PolicyType": "TargetTrackingScaling",
  "TargetTrackingScalingPolicyConfiguration": {
    "TargetValue": 80.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ECSServiceAverageMemoryUtilization"
    },
    "ScaleInCooldown": 300,
    "ScaleOutCooldown": 60
  }
}
```

#### ALB Request Count Scaling

```json
{
  "PolicyName": "product-service-request-count-scaling",
  "ServiceNamespace": "ecs",
  "ResourceId": "service/doa-market-cluster/product-service",
  "ScalableDimension": "ecs:service:DesiredCount",
  "PolicyType": "TargetTrackingScaling",
  "TargetTrackingScalingPolicyConfiguration": {
    "TargetValue": 1000.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ALBRequestCountPerTarget",
      "ResourceLabel": "app/doa-market-alb/abc123/targetgroup/product-service/xyz789"
    },
    "ScaleInCooldown": 300,
    "ScaleOutCooldown": 60
  }
}
```

### 서비스별 Auto Scaling 설정

| 서비스 | Min | Max | Target CPU | Target Memory | Target RPS |
|--------|-----|-----|-----------|--------------|-----------|
| auth-service | 2 | 10 | 70% | 80% | 1000 |
| user-service | 2 | 8 | 70% | 80% | 800 |
| product-service | 3 | 15 | 70% | 80% | 1500 |
| order-service | 4 | 20 | 70% | 80% | 1200 |
| payment-service | 3 | 12 | 70% | 80% | 1000 |
| shipping-service | 2 | 8 | 70% | 80% | 500 |
| seller-service | 2 | 6 | 70% | 80% | 400 |
| settlement-service | 2 | 6 | 70% | 80% | 200 |
| coupon-service | 2 | 8 | 70% | 80% | 800 |
| inventory-service | 3 | 12 | 70% | 80% | 1000 |
| notification-service | 2 | 10 | 70% | 80% | 1500 |
| review-service | 2 | 8 | 70% | 80% | 600 |
| search-service | 3 | 12 | 70% | 80% | 2000 |
| admin-service | 2 | 6 | 70% | 80% | 300 |
| file-service | 2 | 10 | 70% | 80% | 800 |
| stats-service | 2 | 6 | 70% | 80% | 400 |

---

## 배포 전략

### 1. Rolling Update (기본)

ECS의 기본 배포 전략으로, 점진적으로 Task를 교체합니다.

```
기존 Task: [T1] [T2] [T3]
          ↓
단계 1:   [T1] [T2] [T3] [T4-new]
단계 2:   [T1] [T2] [T4-new] [T5-new]
단계 3:   [T1] [T4-new] [T5-new] [T6-new]
단계 4:   [T4-new] [T5-new] [T6-new]
```

**설정**:
```json
{
  "maximumPercent": 200,
  "minimumHealthyPercent": 100
}
```

---

### 2. Blue/Green 배포 (CodeDeploy)

무중단 배포를 위한 Blue/Green 전략을 사용합니다.

#### CodeDeploy AppSpec

```yaml
# appspec.yml
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "arn:aws:ecs:ap-northeast-2:123456789012:task-definition/product-service:TASK_DEFINITION"
        LoadBalancerInfo:
          ContainerName: "product-service"
          ContainerPort: 3003
        PlatformVersion: "LATEST"
        NetworkConfiguration:
          AwsvpcConfiguration:
            Subnets:
              - "subnet-0abc123"
              - "subnet-0def456"
            SecurityGroups:
              - "sg-0xyz789"
            AssignPublicIp: "DISABLED"

Hooks:
  - BeforeInstall: "LambdaFunctionToValidateBeforeInstall"
  - AfterInstall: "LambdaFunctionToValidateAfterInstall"
  - AfterAllowTestTraffic: "LambdaFunctionToValidateAfterTestTrafficStarts"
  - BeforeAllowTraffic: "LambdaFunctionToValidateBeforeAllowingProductionTraffic"
  - AfterAllowTraffic: "LambdaFunctionToValidateAfterAllowingProductionTraffic"
```

#### Deployment Configuration

```json
{
  "deploymentConfigName": "CodeDeployDefault.ECSLinear10PercentEvery1Minutes",
  "computePlatform": "ECS",
  "trafficRoutingConfig": {
    "type": "TimeBasedLinear",
    "timeBasedLinear": {
      "linearPercentage": 10,
      "linearInterval": 1
    }
  },
  "autoRollbackConfiguration": {
    "enabled": true,
    "events": [
      "DEPLOYMENT_FAILURE",
      "DEPLOYMENT_STOP_ON_ALARM"
    ]
  },
  "blueGreenDeploymentConfiguration": {
    "terminateBlueInstancesOnDeploymentSuccess": {
      "action": "TERMINATE",
      "terminationWaitTimeInMinutes": 5
    },
    "deploymentReadyOption": {
      "actionOnTimeout": "CONTINUE_DEPLOYMENT"
    }
  },
  "alarmConfiguration": {
    "alarms": [
      {
        "name": "product-service-5xx-errors"
      },
      {
        "name": "product-service-high-latency"
      }
    ],
    "enabled": true,
    "ignorePollAlarmFailure": false
  }
}
```

#### 배포 프로세스

```
1. Blue Environment (현재 운영 중)
   └─ Task x3 → ALB (100% traffic)

2. Green Environment 생성
   └─ New Task x3 → ALB (0% traffic)

3. Health Check 통과 확인

4. Traffic Shift (10% every 1 minute)
   Blue: 100% → 90% → 80% → ... → 0%
   Green: 0% → 10% → 20% → ... → 100%

5. Alarm 모니터링
   - 5xx 에러율
   - 응답 시간
   - CPU/Memory

6. 성공 시 Blue 환경 종료
   실패 시 자동 롤백
```

---

### 3. Canary 배포

일부 트래픽만 새 버전으로 라우팅하여 테스트합니다.

```json
{
  "deploymentConfigName": "CodeDeployDefault.ECSCanary10Percent5Minutes",
  "trafficRoutingConfig": {
    "type": "TimeBasedCanary",
    "timeBasedCanary": {
      "canaryPercentage": 10,
      "canaryInterval": 5
    }
  }
}
```

**프로세스**:
1. 10% 트래픽을 새 버전으로 라우팅
2. 5분간 모니터링
3. 문제 없으면 나머지 90% 트래픽 전환
4. 문제 발생 시 즉시 롤백

---

## 네트워킹 및 서비스 디스커버리

### AWS Cloud Map (Service Discovery)

```json
{
  "Name": "product-service",
  "DnsConfig": {
    "NamespaceId": "ns-abc123",
    "DnsRecords": [
      {
        "Type": "A",
        "TTL": 60
      }
    ],
    "RoutingPolicy": "MULTIVALUE"
  },
  "HealthCheckCustomConfig": {
    "FailureThreshold": 1
  }
}
```

**결과**:
- `product-service.local` → `10.0.10.45, 10.0.10.67, 10.0.10.89`
- 내부 서비스 간 통신에 사용
- DNS 기반 로드 밸런싱

---

### Application Load Balancer

#### Listener Rules

```json
{
  "Rules": [
    {
      "Priority": 1,
      "Conditions": [
        {
          "Field": "path-pattern",
          "Values": ["/api/v1/auth/*"]
        }
      ],
      "Actions": [
        {
          "Type": "forward",
          "TargetGroupArn": "arn:aws:elasticloadbalancing:...:targetgroup/auth-service"
        }
      ]
    },
    {
      "Priority": 2,
      "Conditions": [
        {
          "Field": "path-pattern",
          "Values": ["/api/v1/products/*"]
        }
      ],
      "Actions": [
        {
          "Type": "forward",
          "TargetGroupArn": "arn:aws:elasticloadbalancing:...:targetgroup/product-service"
        }
      ]
    }
  ]
}
```

#### Target Group (Health Check)

```json
{
  "HealthCheckProtocol": "HTTP",
  "HealthCheckPath": "/health",
  "HealthCheckIntervalSeconds": 30,
  "HealthCheckTimeoutSeconds": 5,
  "HealthyThresholdCount": 2,
  "UnhealthyThresholdCount": 3,
  "Matcher": {
    "HttpCode": "200"
  },
  "TargetType": "ip",
  "DeregistrationDelay": 30
}
```

---

## 보안 설정

### IAM Roles

#### Task Execution Role

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
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
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/ecs/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:ssm:*:*:parameter/doa-market/*",
        "arn:aws:secretsmanager:*:*:secret:*"
      ]
    }
  ]
}
```

#### Task Role (Product Service 예시)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement"
      ],
      "Resource": "arn:aws:rds:*:*:cluster:products-db"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/ProductViews"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::doa-market-product-images/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "events:PutEvents"
      ],
      "Resource": "arn:aws:events:*:*:event-bus/doa-market-event-bus"
    },
    {
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

---

### Security Groups

```hcl
# ALB Security Group
resource "aws_security_group" "alb" {
  name = "doa-market-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Tasks Security Group
resource "aws_security_group" "ecs_tasks" {
  name = "doa-market-ecs-tasks-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3000
    to_port         = 3999
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

## 모니터링 및 로깅

### CloudWatch Container Insights

```hcl
resource "aws_ecs_cluster" "main" {
  name = "doa-market-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
```

**제공 메트릭**:
- CPU Utilization
- Memory Utilization
- Network I/O
- Task Count
- Service Count

---

### CloudWatch Alarms

```json
{
  "AlarmName": "product-service-high-cpu",
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
  "AlarmActions": ["arn:aws:sns:ap-northeast-2:123456789012:alerts"]
}
```

---

**6단계 완료**: ECS Fargate 배포 전략이 완성되었습니다!

**작성일**: 2025-12-03
**버전**: 1.0
