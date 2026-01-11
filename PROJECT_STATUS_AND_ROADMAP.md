# DOA Market 프로젝트 현황 및 로드맵

**작성일**: 2025-01-XX  
**분석 범위**: 전체 프로젝트 구조, Terraform 인프라, 배포 준비 상태

---

## 📊 프로젝트 현황 요약

### ✅ 완료된 부분

#### 1. 아키텍처 설계 및 문서화
- ✅ 전체 시스템 아키텍처 설계 완료
- ✅ 마이크로서비스 구조 정의 (16개 서비스)
- ✅ ECS Fargate 배포 전략 문서화
- ✅ CI/CD 파이프라인 설계 문서화
- ✅ Infrastructure as Code 전략 문서화

#### 2. 백엔드 서비스 구현
- ✅ 16개 마이크로서비스 코드 구현
- ✅ 대부분의 서비스에 Dockerfile 존재
- ✅ API Gateway 구현
- ✅ 공유 모듈 (_shared) 구현

#### 3. Terraform 인프라 (부분 완료)
- ✅ VPC 모듈 완성
  - 3-tier 아키텍처 (Public, Private, Database 서브넷)
  - NAT Gateway, VPC Endpoints
  - Flow Logs
- ✅ ECS Cluster 모듈 완성
  - Fargate 설정
  - Service Discovery
  - IAM Roles
  - Security Groups
- ✅ Production 환경 기본 구조
  - VPC, ECS Cluster 배포 가능
  - ALB 기본 설정
  - RDS 예시 (product-db만)

---

## ❌ 미완성/부족한 부분

### 1. Terraform 인프라 (중요도: 🔴 높음)

#### 1.1 ECS 서비스 모듈 없음
**현재 상태**: ECS Cluster는 있지만, 실제 서비스를 배포할 모듈이 없음

**필요한 작업**:
- [ ] `modules/ecs-service/` 모듈 생성
  - Task Definition 생성
  - ECS Service 생성
  - Target Group 연동
  - Auto Scaling 설정
  - Service Discovery 등록

#### 1.2 16개 서비스에 대한 ECS 서비스 정의 없음
**현재 상태**: Production main.tf에 서비스 정의가 전혀 없음

**필요한 작업**:
- [ ] 각 서비스별 ECS 서비스 리소스 생성
  - auth-service
  - user-service
  - product-service
  - order-service
  - payment-service
  - shipping-service
  - seller-service
  - settlement-service
  - coupon-service
  - inventory-service
  - notification-service
  - review-service
  - search-service
  - admin-service
  - file-service
  - stats-service

#### 1.3 데이터베이스 리소스 부족
**현재 상태**: RDS product-db 예시만 있음

**필요한 작업**:
- [ ] 나머지 RDS 데이터베이스 생성
  - users_db (auth, user, seller)
  - orders_db
  - payments_db
  - settlements_db
  - 등등...
- [ ] RDS 모듈화 (재사용 가능한 모듈)

#### 1.4 기타 AWS 리소스 없음
**필요한 작업**:
- [ ] ElastiCache Redis 모듈 및 리소스
- [ ] OpenSearch 모듈 및 리소스
- [ ] DynamoDB 테이블들
- [ ] S3 버킷들 (상품 이미지, 로그 등)
- [ ] EventBridge 설정
- [ ] SQS 큐들
- [ ] Lambda 함수들

#### 1.5 Terraform 설정 파일 부족
**필요한 작업**:
- [ ] `environments/production/variables.tf` 생성
- [ ] `environments/production/terraform.tfvars` 생성
- [ ] `environments/production/outputs.tf` 생성
- [ ] Dev, Staging 환경 디렉토리 및 설정

### 2. CI/CD 파이프라인 (중요도: 🔴 높음)

**현재 상태**: 문서만 있고 실제 GitHub Actions 워크플로우 없음

**필요한 작업**:
- [ ] `.github/workflows/` 디렉토리 생성
- [ ] 재사용 가능한 워크플로우 생성
  - `_reusable-build-and-push.yml`
  - `_reusable-deploy-ecs.yml`
  - `_reusable-test.yml`
- [ ] 각 서비스별 CI/CD 워크플로우 생성
- [ ] 인프라 배포 워크플로우 (`infrastructure-terraform.yml`)
- [ ] 데이터베이스 마이그레이션 워크플로우

### 3. ECR 및 컨테이너 이미지 (중요도: 🟡 중간)

**필요한 작업**:
- [ ] ECR 리포지토리 Terraform 리소스 생성
- [ ] 각 서비스별 ECR 리포지토리
- [ ] 이미지 스캔 설정

### 4. 보안 및 설정 관리 (중요도: 🟡 중간)

**필요한 작업**:
- [ ] Secrets Manager에 저장할 시크릿 정의
- [ ] SSM Parameter Store 설정
- [ ] KMS 키 관리
- [ ] IAM 역할 및 정책 세분화

### 5. 모니터링 및 로깅 (중요도: 🟡 중간)

**필요한 작업**:
- [ ] CloudWatch Alarms 설정
- [ ] X-Ray 추적 설정
- [ ] 로그 집계 설정
- [ ] 대시보드 구성

---

## 🎯 배포 준비 상태 평가

### 현재 배포 가능 여부: ❌ **불가능**

**이유**:
1. ECS 서비스 모듈이 없어서 실제 서비스를 배포할 수 없음
2. 16개 서비스에 대한 ECS 서비스 정의가 없음
3. 대부분의 데이터베이스 리소스가 없음
4. ALB Target Group 및 Listener Rules가 서비스별로 설정되지 않음
5. CI/CD 파이프라인이 없어서 자동 배포 불가능

### 배포까지 필요한 최소 작업

**Phase 1: 기본 인프라 완성 (우선순위 높음)**
1. ECS Service 모듈 생성
2. 최소 1개 서비스 (예: product-service) 배포 가능하도록 설정
3. 관련 RDS 데이터베이스 생성
4. ALB Target Group 및 Listener Rule 설정

**Phase 2: 나머지 서비스 배포**
5. 나머지 15개 서비스 ECS 서비스 정의
6. 관련 데이터베이스 및 리소스 생성

**Phase 3: CI/CD 구축**
7. GitHub Actions 워크플로우 생성
8. 자동 빌드 및 배포 파이프라인 구축

---

## 📋 앞으로 할 일 (우선순위별)

### 🔴 높은 우선순위 (배포 필수)

#### 1. ECS Service 모듈 생성
```
infrastructure/terraform/modules/ecs-service/
├── main.tf          # Task Definition, ECS Service, Target Group
├── variables.tf
├── outputs.tf
└── README.md
```

**기능**:
- Task Definition 생성 (컨테이너 이미지, 환경 변수, 시크릿)
- ECS Service 생성
- Target Group 생성 및 ALB 연동
- Auto Scaling 설정
- Service Discovery 등록
- CloudWatch Logs 설정

#### 2. Production 환경 완성
```
infrastructure/terraform/environments/production/
├── main.tf          # (기존 + 서비스 정의 추가)
├── variables.tf     # (신규 생성)
├── terraform.tfvars # (신규 생성)
└── outputs.tf      # (신규 생성)
```

**작업 내용**:
- 16개 서비스에 대한 ECS 서비스 리소스 추가
- ALB Listener Rules 추가
- 필요한 데이터베이스 리소스 추가

#### 3. RDS 모듈 생성 및 데이터베이스 리소스
```
infrastructure/terraform/modules/rds/
├── main.tf
├── variables.tf
└── outputs.tf
```

**데이터베이스 목록**:
- users_db (auth, user, seller 서비스)
- products_db
- orders_db
- payments_db
- settlements_db
- 등등...

#### 4. ECR 리포지토리 생성
- 각 서비스별 ECR 리포지토리 Terraform 리소스

### 🟡 중간 우선순위 (운영 필수)

#### 5. ElastiCache Redis 모듈 및 리소스
- 캐시 레이어 구축

#### 6. OpenSearch 모듈 및 리소스
- 검색 서비스 인프라

#### 7. DynamoDB 테이블들
- 세션, 장바구니, 로그 등

#### 8. S3 버킷들
- 상품 이미지, 로그 아카이브 등

#### 9. EventBridge 및 SQS 설정
- 이벤트 기반 아키텍처 인프라

### 🟢 낮은 우선순위 (향후 개선)

#### 10. Dev, Staging 환경 구축
- 개발 및 스테이징 환경 Terraform 설정

#### 11. 모니터링 및 알람 고도화
- CloudWatch Alarms, Dashboards

#### 12. 보안 강화
- WAF 설정
- 보안 그룹 세분화
- IAM 최소 권한 원칙 적용

---

## 🚀 즉시 시작 가능한 작업

### 1단계: ECS Service 모듈 생성 (1-2일)

**목표**: 재사용 가능한 ECS 서비스 모듈 생성

**작업**:
1. `infrastructure/terraform/modules/ecs-service/` 디렉토리 생성
2. Task Definition 리소스 작성
3. ECS Service 리소스 작성
4. Target Group 및 ALB 연동
5. Auto Scaling 설정
6. Service Discovery 연동

### 2단계: 첫 번째 서비스 배포 테스트 (1일)

**목표**: product-service를 예시로 배포 가능하도록 설정

**작업**:
1. Production main.tf에 product-service ECS 서비스 추가
2. ECR 리포지토리 생성
3. ALB Target Group 및 Listener Rule 추가
4. Terraform plan/apply 테스트

### 3단계: 나머지 서비스 배포 (3-5일)

**목표**: 모든 서비스 배포 가능하도록 설정

**작업**:
1. 나머지 15개 서비스 ECS 서비스 정의
2. 필요한 데이터베이스 리소스 생성
3. ALB Listener Rules 추가

### 4단계: CI/CD 파이프라인 구축 (2-3일)

**목표**: 자동 빌드 및 배포 파이프라인 구축

**작업**:
1. GitHub Actions 워크플로우 생성
2. ECR 푸시 자동화
3. ECS 배포 자동화

---

## 📝 체크리스트

### Terraform 인프라
- [ ] ECS Service 모듈 생성
- [ ] 16개 서비스 ECS 서비스 정의
- [ ] RDS 모듈 생성
- [ ] 필요한 데이터베이스 리소스 생성
- [ ] ECR 리포지토리 생성
- [ ] ElastiCache Redis 리소스
- [ ] OpenSearch 리소스
- [ ] DynamoDB 테이블들
- [ ] S3 버킷들
- [ ] EventBridge 설정
- [ ] SQS 큐들
- [ ] ALB Listener Rules 완성
- [ ] Variables 및 tfvars 파일 생성
- [ ] Outputs 파일 생성

### CI/CD
- [ ] GitHub Actions 워크플로우 생성
- [ ] 재사용 가능한 워크플로우
- [ ] 서비스별 CI/CD 워크플로우
- [ ] 인프라 배포 워크플로우

### 보안 및 설정
- [ ] Secrets Manager 설정
- [ ] SSM Parameter Store 설정
- [ ] IAM 역할 세분화

### 모니터링
- [ ] CloudWatch Alarms
- [ ] X-Ray 설정
- [ ] 로그 집계

---

## 💡 권장 사항

### 1. 점진적 접근
- 한 번에 모든 것을 구현하지 말고, 단계적으로 진행
- 먼저 1-2개 서비스로 테스트 배포 후 확장

### 2. 모듈화 우선
- 재사용 가능한 모듈을 먼저 만들고, 이를 활용하여 서비스 정의

### 3. 문서화 유지
- Terraform 코드와 함께 README 작성
- 변수 설명 및 사용 예시 포함

### 4. 테스트 환경 구축
- Production 배포 전에 Dev 환경에서 충분히 테스트

### 5. 비용 고려
- 초기에는 최소 리소스로 시작
- Auto Scaling으로 필요시 확장

---

## 📞 다음 단계

**즉시 시작 가능한 작업**:
1. ECS Service 모듈 생성부터 시작
2. 첫 번째 서비스 배포 테스트
3. 점진적으로 나머지 서비스 추가

**예상 소요 시간**:
- 기본 배포 가능: 1주일
- 전체 서비스 배포: 2-3주
- CI/CD 구축: 추가 1주

---

**문서 버전**: 1.0  
**최종 업데이트**: 2025-01-XX

