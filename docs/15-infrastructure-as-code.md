# 15. Infrastructure as Code (IaC)

## 목차
1. [IaC 전략](#1-iac-전략)
2. [Terraform 구조](#2-terraform-구조)
3. [AWS CDK 구조](#3-aws-cdk-구조)
4. [모듈 설명](#4-모듈-설명)
5. [환경 관리](#5-환경-관리)
6. [상태 관리](#6-상태-관리)
7. [배포 프로세스](#7-배포-프로세스)

---

## 1. IaC 전략

### 1.1 도구 선택

**Terraform vs CDK 비교**

| 항목 | Terraform | AWS CDK |
|------|-----------|---------|
| 언어 | HCL (선언적) | TypeScript (명령형) |
| 멀티 클라우드 | ✅ 지원 | ❌ AWS 전용 |
| 학습 곡선 | 낮음 | 중간 (TypeScript 필요) |
| 커뮤니티 | 매우 큼 | 성장 중 |
| 상태 관리 | S3 + DynamoDB | CloudFormation |
| 모듈화 | Module | Construct |
| 테스팅 | Terratest | CDK Assertions |
| 변경 미리보기 | `plan` | `diff` |

**선택 기준**:
- **Terraform**: 인프라 전반 (VPC, 네트워크, 보안)
- **CDK**: 애플리케이션 리소스 (Lambda, ECS 서비스)

### 1.2 디렉토리 구조

```
infrastructure/
├── terraform/
│   ├── modules/
│   │   ├── vpc/                    # VPC 모듈
│   │   ├── ecs-cluster/            # ECS 클러스터
│   │   ├── ecs-service/            # ECS 서비스
│   │   ├── rds/                    # RDS Aurora
│   │   ├── dynamodb/               # DynamoDB
│   │   ├── elasticache/            # Redis
│   │   ├── opensearch/             # OpenSearch
│   │   ├── s3/                     # S3 버킷
│   │   ├── cloudfront/             # CloudFront
│   │   ├── alb/                    # Application Load Balancer
│   │   ├── security-group/         # Security Group
│   │   └── iam/                    # IAM 역할
│   │
│   ├── environments/
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── terraform.tfvars
│   │   ├── staging/
│   │   └── production/
│   │
│   ├── backend.tf                  # 상태 관리 설정
│   └── providers.tf                # Provider 설정
│
├── cdk/
│   ├── bin/
│   │   └── app.ts                  # CDK 앱 진입점
│   ├── lib/
│   │   ├── stacks/
│   │   │   ├── lambda-stack.ts
│   │   │   ├── eventbridge-stack.ts
│   │   │   └── sqs-stack.ts
│   │   └── constructs/
│   │       ├── lambda-function.ts
│   │       └── api-gateway.ts
│   ├── cdk.json
│   ├── package.json
│   └── tsconfig.json
│
└── scripts/
    ├── deploy-dev.sh
    ├── deploy-staging.sh
    └── deploy-production.sh
```

### 1.3 워크플로우

```
1. 개발자가 IaC 코드 작성
   ↓
2. Pull Request 생성
   ↓
3. GitHub Actions: terraform plan / cdk diff
   ↓
4. 코드 리뷰 및 승인
   ↓
5. Merge to develop/main
   ↓
6. GitHub Actions: terraform apply / cdk deploy
   ↓
7. 인프라 변경 완료
```

---

## 2. Terraform 구조

### 2.1 백엔드 설정

**`infrastructure/terraform/backend.tf`**
```hcl
terraform {
  backend "s3" {
    bucket         = "doa-market-terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "doa-market-terraform-locks"

    # State 파일 암호화
    kms_key_id = "arn:aws:kms:ap-northeast-2:ACCOUNT_ID:key/xxxxx"
  }

  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**상태 잠금 테이블 (DynamoDB)**:
```hcl
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "doa-market-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "shared"
  }
}
```

### 2.2 Provider 설정

**`infrastructure/terraform/providers.tf`**
```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DOA Market"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"  # CloudFront 인증서용
}
```

### 2.3 변수 정의

**`infrastructure/terraform/environments/production/variables.tf`**
```hcl
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "doa-market"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

variable "ecs_services" {
  description = "ECS Services configuration"
  type = map(object({
    cpu    = number
    memory = number
    desired_count = number
    autoscaling_min = number
    autoscaling_max = number
  }))
  default = {
    product-service = {
      cpu               = 512
      memory            = 1024
      desired_count     = 3
      autoscaling_min   = 2
      autoscaling_max   = 10
    }
    order-service = {
      cpu               = 512
      memory            = 1024
      desired_count     = 3
      autoscaling_min   = 2
      autoscaling_max   = 10
    }
    # ... 나머지 서비스
  }
}

variable "rds_databases" {
  description = "RDS databases configuration"
  type = map(object({
    instance_class = string
    allocated_storage = number
    max_allocated_storage = number
  }))
  default = {
    product-db = {
      instance_class         = "db.r6g.large"
      allocated_storage      = 100
      max_allocated_storage  = 1000
    }
    # ... 나머지 DB
  }
}
```

### 2.4 환경별 변수

**`infrastructure/terraform/environments/production/terraform.tfvars`**
```hcl
environment = "production"
aws_region  = "ap-northeast-2"

vpc_cidr = "10.0.0.0/16"

# ECS 서비스 스케일
ecs_services = {
  product-service = {
    cpu             = 1024
    memory          = 2048
    desired_count   = 5
    autoscaling_min = 3
    autoscaling_max = 20
  }
  order-service = {
    cpu             = 1024
    memory          = 2048
    desired_count   = 5
    autoscaling_min = 3
    autoscaling_max = 20
  }
}

# RDS 인스턴스 크기
rds_databases = {
  product-db = {
    instance_class         = "db.r6g.xlarge"
    allocated_storage      = 500
    max_allocated_storage  = 5000
  }
}

# ElastiCache Redis
redis_node_type = "cache.r6g.large"
redis_num_cache_nodes = 3

# OpenSearch
opensearch_instance_type = "r6g.xlarge.search"
opensearch_instance_count = 3
```

---

## 3. AWS CDK 구조

### 3.1 CDK 앱 진입점

**`infrastructure/cdk/bin/app.ts`**
```typescript
#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { LambdaStack } from '../lib/stacks/lambda-stack';
import { EventBridgeStack } from '../lib/stacks/eventbridge-stack';
import { SqsStack } from '../lib/stacks/sqs-stack';

const app = new cdk.App();

const env = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: process.env.CDK_DEFAULT_REGION || 'ap-northeast-2',
};

const environment = app.node.tryGetContext('environment') || 'development';

// Lambda Functions Stack
new LambdaStack(app, `DOAMarket-Lambda-${environment}`, {
  env,
  environment,
  stackName: `doa-market-lambda-${environment}`,
  description: 'Lambda functions for DOA Market',
});

// EventBridge Stack
new EventBridgeStack(app, `DOAMarket-EventBridge-${environment}`, {
  env,
  environment,
  stackName: `doa-market-eventbridge-${environment}`,
});

// SQS Stack
new SqsStack(app, `DOAMarket-SQS-${environment}`, {
  env,
  environment,
  stackName: `doa-market-sqs-${environment}`,
});

app.synth();
```

### 3.2 CDK 설정

**`infrastructure/cdk/cdk.json`**
```json
{
  "app": "npx ts-node --prefer-ts-exts bin/app.ts",
  "watch": {
    "include": [
      "**"
    ],
    "exclude": [
      "README.md",
      "cdk*.json",
      "**/*.d.ts",
      "**/*.js",
      "tsconfig.json",
      "package*.json",
      "yarn.lock",
      "node_modules"
    ]
  },
  "context": {
    "@aws-cdk/aws-lambda:recognizeLayerVersion": true,
    "@aws-cdk/core:checkSecretUsage": true,
    "@aws-cdk/core:target-partitions": [
      "aws",
      "aws-cn"
    ],
    "@aws-cdk-containers/ecs-service-extensions:enableDefaultLogDriver": true,
    "@aws-cdk/aws-ec2:uniqueImdsv2TemplateName": true,
    "@aws-cdk/aws-ecs:arnFormatIncludesClusterName": true,
    "@aws-cdk/aws-iam:minimizePolicies": true,
    "@aws-cdk/core:validateSnapshotRemovalPolicy": true,
    "@aws-cdk/aws-codepipeline:crossAccountKeyAliasStackSafeResourceName": true,
    "@aws-cdk/aws-s3:createDefaultLoggingPolicy": true,
    "@aws-cdk/aws-sns-subscriptions:restrictSqsDescryption": true,
    "@aws-cdk/aws-apigateway:disableCloudWatchRole": true,
    "@aws-cdk/core:enablePartitionLiterals": true,
    "@aws-cdk/aws-events:eventsTargetQueueSameAccount": true,
    "@aws-cdk/aws-iam:standardizedServicePrincipals": true,
    "@aws-cdk/aws-ecs:disableExplicitDeploymentControllerForCircuitBreaker": true,
    "@aws-cdk/aws-iam:importedRoleStackSafeDefaultPolicyName": true,
    "@aws-cdk/aws-s3:serverAccessLogsUseBucketPolicy": true,
    "@aws-cdk/aws-route53-patters:useCertificate": true,
    "@aws-cdk/customresources:installLatestAwsSdkDefault": false,
    "@aws-cdk/aws-rds:databaseProxyUniqueResourceName": true,
    "@aws-cdk/aws-codedeploy:removeAlarmsFromDeploymentGroup": true,
    "@aws-cdk/aws-apigateway:authorizerChangeDeploymentLogicalId": true,
    "@aws-cdk/aws-ec2:launchTemplateDefaultUserData": true,
    "@aws-cdk/aws-secretsmanager:useAttachedSecretResourcePolicyForSecretTargetAttachments": true,
    "@aws-cdk/aws-redshift:columnId": true,
    "@aws-cdk/aws-stepfunctions-tasks:enableEmrServicePolicyV2": true,
    "@aws-cdk/aws-ec2:restrictDefaultSecurityGroup": true,
    "@aws-cdk/aws-apigateway:requestValidatorUniqueId": true,
    "@aws-cdk/aws-kms:aliasNameRef": true,
    "@aws-cdk/aws-autoscaling:generateLaunchTemplateInsteadOfLaunchConfig": true,
    "@aws-cdk/core:includePrefixInUniqueNameGeneration": true,
    "@aws-cdk/aws-efs:denyAnonymousAccess": true,
    "@aws-cdk/aws-opensearchservice:enableOpensearchMultiAzWithStandby": true,
    "@aws-cdk/aws-lambda-nodejs:useLatestRuntimeVersion": true,
    "@aws-cdk/aws-efs:mountTargetOrderInsensitiveLogicalId": true,
    "@aws-cdk/aws-rds:auroraClusterChangeScopeOfInstanceParameterGroupWithEachParameters": true,
    "@aws-cdk/aws-appsync:useArnForSourceApiAssociationIdentifier": true,
    "@aws-cdk/aws-rds:preventRenderingDeprecatedCredentials": true,
    "@aws-cdk/aws-codepipeline-actions:useNewDefaultBranchForCodeCommitSource": true,
    "@aws-cdk/aws-cloudwatch-actions:changeLambdaPermissionLogicalIdForLambdaAction": true,
    "@aws-cdk/aws-codepipeline:crossAccountKeysDefaultValueToFalse": true,
    "@aws-cdk/aws-codepipeline:defaultPipelineTypeToV2": true,
    "@aws-cdk/aws-kms:reduceCrossAccountRegionPolicyScope": true,
    "@aws-cdk/aws-eks:nodegroupNameAttribute": true,
    "@aws-cdk/aws-ec2:ebsDefaultGp3Volume": true,
    "@aws-cdk/aws-ecs:removeDefaultDeploymentAlarm": true,
    "@aws-cdk/custom-resources:logApiResponseDataPropertyTrueDefault": false,
    "@aws-cdk/aws-s3:keepNotificationInImportedBucket": false
  }
}
```

---

## 4. 모듈 설명

### 4.1 VPC 모듈
- 3-tier 아키텍처 (Public, Private, Database 서브넷)
- NAT Gateway (고가용성)
- VPC Endpoints (S3, DynamoDB, ECR, Secrets Manager)
- Flow Logs

### 4.2 ECS 모듈
- Fargate 클러스터
- Container Insights 활성화
- Auto Scaling 정책
- Task Definition
- Service Discovery

### 4.3 RDS 모듈
- Aurora PostgreSQL (Multi-AZ)
- 자동 백업 (7일 보존)
- Performance Insights
- Enhanced Monitoring
- KMS 암호화

### 4.4 DynamoDB 모듈
- On-Demand 또는 Provisioned 모드
- GSI 인덱스
- Point-in-Time Recovery
- KMS 암호화
- TTL 설정

### 4.5 ElastiCache 모듈
- Redis 클러스터 모드
- Multi-AZ 자동 장애 조치
- 암호화 (전송/저장)
- Automatic Backups

### 4.6 OpenSearch 모듈
- 3 AZ 배포
- 전용 마스터 노드
- EBS 볼륨 (gp3)
- Fine-grained Access Control
- 암호화

### 4.7 S3 모듈
- 버킷 암호화 (KMS)
- 버전 관리
- Lifecycle 정책
- CORS 설정
- Public Access Block

### 4.8 CloudFront 모듈
- Origin Access Identity
- SSL/TLS 인증서 (ACM)
- 캐싱 정책
- WAF 연동

---

## 5. 환경 관리

### 5.1 환경별 변수 관리

**Development**:
- 소규모 인스턴스 (비용 절감)
- 단일 AZ 배포
- 백업 최소화

**Staging**:
- Production과 동일한 구성
- 소규모 스케일
- 테스트 데이터

**Production**:
- 고가용성 (Multi-AZ)
- Auto Scaling 활성화
- 자동 백업 및 모니터링

### 5.2 워크스페이스

```bash
# Terraform 워크스페이스
terraform workspace new development
terraform workspace new staging
terraform workspace new production

terraform workspace select production
terraform plan
terraform apply
```

---

## 6. 상태 관리

### 6.1 S3 백엔드

**보안 설정**:
- 버킷 암호화 (KMS)
- 버전 관리 활성화
- Public Access 차단
- MFA Delete 활성화

### 6.2 상태 잠금

**DynamoDB 테이블**:
- LockID를 hash key로 사용
- Pay-per-request 모드
- 동시 변경 방지

### 6.3 상태 파일 분리

```
doa-market-terraform-state/
├── dev/
│   ├── vpc/terraform.tfstate
│   ├── ecs/terraform.tfstate
│   └── rds/terraform.tfstate
├── staging/
└── production/
```

---

## 7. 배포 프로세스

### 7.1 Terraform 배포

```bash
# 1. 초기화
cd infrastructure/terraform/environments/production
terraform init

# 2. 변경 사항 확인
terraform plan -out=tfplan

# 3. 변경 사항 적용
terraform apply tfplan

# 4. 출력 확인
terraform output
```

### 7.2 CDK 배포

```bash
# 1. 의존성 설치
cd infrastructure/cdk
npm install

# 2. CDK 부트스트랩 (최초 1회)
cdk bootstrap aws://ACCOUNT_ID/ap-northeast-2

# 3. 변경 사항 확인
cdk diff --context environment=production

# 4. 배포
cdk deploy --context environment=production --all

# 5. 특정 스택만 배포
cdk deploy DOAMarket-Lambda-production
```

### 7.3 CI/CD 통합

**GitHub Actions**:
```yaml
- name: Terraform Plan
  run: terraform plan -out=tfplan

- name: Terraform Apply
  if: github.ref == 'refs/heads/main'
  run: terraform apply -auto-approve tfplan
```

---

## 8. 베스트 프랙티스

### 8.1 모듈화
- 재사용 가능한 모듈 작성
- 입력 변수와 출력 명확히 정의
- 버전 관리

### 8.2 네이밍 컨벤션
```
{project}-{environment}-{resource}-{name}
예: doa-market-prod-vpc-main
```

### 8.3 태깅 전략
```hcl
tags = {
  Project     = "DOA Market"
  Environment = var.environment
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
}
```

### 8.4 보안
- 민감한 정보는 Secrets Manager 사용
- IAM 최소 권한 원칙
- 모든 리소스 암호화
- VPC 격리

### 8.5 비용 최적화
- 태그 기반 비용 추적
- 사용하지 않는 리소스 자동 정리
- Reserved Instances / Savings Plans
- 적절한 인스턴스 크기 선택

---

**문서 버전**: 1.0
**최종 수정일**: 2024-01-15
**작성자**: DOA Market DevOps Team
