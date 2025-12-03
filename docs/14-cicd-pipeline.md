# 14. CI/CD 파이프라인 (CI/CD Pipeline)

## 목차
1. [CI/CD 전략](#1-cicd-전략)
2. [GitHub Actions 구조](#2-github-actions-구조)
3. [워크플로우 목록](#3-워크플로우-목록)
4. [환경별 배포 전략](#4-환경별-배포-전략)
5. [보안 스캐닝](#5-보안-스캐닝)
6. [테스트 전략](#6-테스트-전략)
7. [롤백 전략](#7-롤백-전략)
8. [배포 승인 프로세스](#8-배포-승인-프로세스)

---

## 1. CI/CD 전략

### 1.1 전체 파이프라인 흐름

```
┌─────────────────────────────────────────────────────────────┐
│                     1. Code Push                             │
│  Developer → Git Push → GitHub Repository                    │
└───────────────────────────┬─────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                2. Continuous Integration (CI)                │
│  ├─ Checkout Code                                            │
│  ├─ Install Dependencies                                     │
│  ├─ Lint & Format Check                                      │
│  ├─ Unit Tests                                               │
│  ├─ Integration Tests                                        │
│  ├─ Security Scan (Snyk, Trivy)                              │
│  ├─ Code Quality (SonarQube)                                 │
│  └─ Build Docker Image                                       │
└───────────────────────────┬─────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│            3. Container Registry (ECR)                       │
│  ├─ Tag Image (git sha, semver)                              │
│  ├─ Push to Amazon ECR                                       │
│  └─ Image Scanning                                           │
└───────────────────────────┬─────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│        4. Continuous Deployment (CD) - Dev                   │
│  ├─ Update ECS Task Definition                               │
│  ├─ Deploy to Dev Environment                                │
│  ├─ Smoke Tests                                              │
│  └─ Notify Slack                                             │
└───────────────────────────┬─────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│        5. Continuous Deployment (CD) - Staging               │
│  ├─ Manual Approval (Optional)                               │
│  ├─ Deploy to Staging Environment                            │
│  ├─ E2E Tests                                                │
│  ├─ Performance Tests                                        │
│  └─ Notify Slack                                             │
└───────────────────────────┬─────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│        6. Continuous Deployment (CD) - Production            │
│  ├─ Manual Approval (Required)                               │
│  ├─ Blue/Green Deployment                                    │
│  ├─ Health Checks                                            │
│  ├─ Gradual Traffic Shift (10% → 50% → 100%)                │
│  ├─ Auto Rollback on Failure                                 │
│  └─ Notify Slack                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 브랜치 전략 (Git Flow)

```
main (production)
  ↑
  merge (with PR approval)
  ↑
develop (staging)
  ↑
  merge
  ↑
feature/* (개발)
hotfix/* (긴급 수정)
```

**브랜치별 배포 환경**
- `feature/*` → Dev Environment (자동 배포)
- `develop` → Staging Environment (자동 배포)
- `main` → Production Environment (수동 승인 후 배포)
- `hotfix/*` → Production Environment (긴급 배포, 간소화된 승인)

### 1.3 배포 빈도

```
Development:  매 커밋마다 (수시)
Staging:      하루 2-3회 (오전 10시, 오후 3시, 오후 6시)
Production:   주 2-3회 (화/목 오후 4시)
Hotfix:       필요 시 즉시
```

---

## 2. GitHub Actions 구조

### 2.1 디렉토리 구조

```
.github/
├── workflows/
│   ├── _reusable-build-and-push.yml         # 재사용 가능한 빌드/푸시
│   ├── _reusable-deploy-ecs.yml             # 재사용 가능한 ECS 배포
│   ├── _reusable-test.yml                   # 재사용 가능한 테스트
│   │
│   ├── backend-product-service.yml          # Product Service CI/CD
│   ├── backend-order-service.yml            # Order Service CI/CD
│   ├── backend-payment-service.yml          # Payment Service CI/CD
│   ├── backend-inventory-service.yml        # Inventory Service CI/CD
│   ├── backend-shipping-service.yml         # Shipping Service CI/CD
│   ├── backend-notification-service.yml     # Notification Service CI/CD
│   ├── backend-all-services.yml             # 모든 백엔드 서비스 일괄 배포
│   │
│   ├── frontend-admin-web.yml               # Admin Web CI/CD
│   ├── frontend-seller-web.yml              # Seller Web CI/CD
│   ├── frontend-user-app.yml                # User App CI/CD
│   │
│   ├── lambda-image-resize.yml              # Lambda 함수 배포
│   ├── lambda-event-consumers.yml           # Lambda 이벤트 컨슈머 배포
│   │
│   ├── db-migration.yml                     # 데이터베이스 마이그레이션
│   ├── infrastructure-terraform.yml         # 인프라 변경
│   │
│   ├── security-scan.yml                    # 보안 스캔 (야간 실행)
│   ├── performance-test.yml                 # 성능 테스트
│   └── rollback.yml                         # 롤백 워크플로우
│
└── actions/
    ├── setup-node/action.yml                # Node.js 설정 액션
    ├── setup-aws/action.yml                 # AWS 설정 액션
    └── notify-slack/action.yml              # Slack 알림 액션
```

### 2.2 GitHub Secrets

**Repository Secrets**
```
AWS_ACCOUNT_ID              # AWS 계정 ID
AWS_REGION                  # ap-northeast-2
AWS_ROLE_TO_ASSUME          # GitHub OIDC 역할 ARN

ECR_REGISTRY                # ECR 레지스트리 URL

SLACK_WEBHOOK_URL           # Slack 알림 웹훅
SONARQUBE_TOKEN             # SonarQube 토큰
SNYK_TOKEN                  # Snyk 토큰

DEV_ECS_CLUSTER             # Dev ECS 클러스터명
STAGING_ECS_CLUSTER         # Staging ECS 클러스터명
PRODUCTION_ECS_CLUSTER      # Production ECS 클러스터명
```

### 2.3 GitHub Environments

**Environment별 설정**

```yaml
# Development Environment
Environment: development
Required Reviewers: 없음
Deployment Branches: feature/*, develop
Secrets:
  - ECS_CLUSTER_NAME: doa-market-dev-cluster
  - DOMAIN: dev.doamarket.com

# Staging Environment
Environment: staging
Required Reviewers: 없음
Deployment Branches: develop
Secrets:
  - ECS_CLUSTER_NAME: doa-market-staging-cluster
  - DOMAIN: staging.doamarket.com

# Production Environment
Environment: production
Required Reviewers: 2명 이상 (DevOps Team)
Deployment Branches: main
Wait Timer: 10분 (배포 전 대기)
Secrets:
  - ECS_CLUSTER_NAME: doa-market-production-cluster
  - DOMAIN: api.doamarket.com
```

---

## 3. 워크플로우 목록

### 3.1 재사용 가능한 워크플로우

#### 3.1.1 빌드 및 푸시 워크플로우

**`.github/workflows/_reusable-build-and-push.yml`**
- Docker 이미지 빌드
- ECR 푸시
- 이미지 태깅 (git sha, semver)
- 취약점 스캔 (Trivy)

#### 3.1.2 ECS 배포 워크플로우

**`.github/workflows/_reusable-deploy-ecs.yml`**
- Task Definition 업데이트
- ECS 서비스 업데이트
- Blue/Green 배포 (CodeDeploy)
- Health Check
- 롤백 (실패 시)

#### 3.1.3 테스트 워크플로우

**`.github/workflows/_reusable-test.yml`**
- Unit Tests
- Integration Tests
- E2E Tests (선택적)
- Test Coverage Report

### 3.2 백엔드 서비스 워크플로우

**트리거**:
- `push` to `feature/*`, `develop`, `main`
- `pull_request` to `develop`, `main`
- `workflow_dispatch` (수동 실행)

**Jobs**:
1. **Lint & Test**: ESLint, Prettier, Jest
2. **Build & Push**: Docker 이미지 빌드 및 ECR 푸시
3. **Deploy Dev**: feature/* 브랜치는 자동 배포
4. **Deploy Staging**: develop 브랜치는 자동 배포
5. **Deploy Production**: main 브랜치는 수동 승인 후 배포

### 3.3 프론트엔드 워크플로우

#### Next.js (Admin/Seller Web)
1. **Build**: Next.js 프로덕션 빌드
2. **Upload to S3**: 정적 파일 S3 업로드
3. **CloudFront Invalidation**: 캐시 무효화

#### Flutter (User App)
1. **Build Android**: APK/AAB 빌드
2. **Build iOS**: IPA 빌드
3. **Upload to Stores**: Google Play / App Store (수동 승인)

### 3.4 Lambda 워크플로우

1. **Package**: 람다 함수 zip 패키징
2. **Upload to S3**: Lambda 코드 S3 업로드
3. **Update Function**: Lambda 함수 코드 업데이트
4. **Publish Version**: 버전 발행
5. **Update Alias**: Alias 업데이트 (Blue/Green)

### 3.5 데이터베이스 마이그레이션

**트리거**: `workflow_dispatch` (수동 실행)

**Jobs**:
1. **Dry Run**: 마이그레이션 시뮬레이션
2. **Approval**: 수동 승인 (Production)
3. **Migrate**: TypeORM 마이그레이션 실행
4. **Verify**: 마이그레이션 검증
5. **Rollback**: 실패 시 롤백

---

## 4. 환경별 배포 전략

### 4.1 Development 환경

**배포 방식**: Rolling Update (빠른 배포)

```yaml
Deployment Strategy: RollingUpdate
Min Healthy Percent: 50%
Max Healthy Percent: 200%
Health Check Grace Period: 30초
Rollback: 자동 (2회 실패 시)
```

**특징**:
- 가장 빠른 배포
- 다운타임 최소화
- 즉각적인 피드백

### 4.2 Staging 환경

**배포 방식**: Blue/Green (안전한 테스트)

```yaml
Deployment Strategy: Blue/Green
Traffic Shift: Linear (10분간 10% → 100%)
Health Check: 엄격한 체크
Rollback: 자동 (Health Check 실패 시)
```

**특징**:
- Production과 동일한 환경
- 완벽한 롤백 가능
- E2E 테스트 실행

### 4.3 Production 환경

**배포 방식**: Blue/Green with Canary (점진적 배포)

```yaml
Deployment Strategy: Blue/Green + Canary
Traffic Shift:
  - Step 1: 10% for 5분 (카나리)
  - Step 2: 50% for 10분
  - Step 3: 100%
Health Check: 매우 엄격
CloudWatch Alarms: 모니터링 (에러율, 지연시간)
Auto Rollback: 알람 트리거 시 자동 롤백
Manual Approval: 필수 (2명 이상)
```

**특징**:
- 최소 리스크
- 점진적 트래픽 전환
- 실시간 모니터링
- 즉각 롤백 가능

### 4.4 배포 타임라인 (Production)

```
T+0min:  배포 시작 (Blue 환경 유지, Green 환경 생성)
T+5min:  Green 환경 Health Check 완료
T+10min: Canary 시작 (10% 트래픽 → Green)
T+15min: CloudWatch 메트릭 확인 (에러율, 지연시간)
         - 정상: 계속 진행
         - 비정상: 자동 롤백 → Blue 환경으로 100% 복구
T+20min: 50% 트래픽 → Green
T+25min: CloudWatch 메트릭 재확인
T+30min: 100% 트래픽 → Green
T+35min: Blue 환경 대기 상태 유지 (1시간)
T+95min: Blue 환경 종료 (롤백 불가능한 시점)
```

---

## 5. 보안 스캐닝

### 5.1 코드 보안 스캔

**도구**: Snyk, SonarQube, ESLint Security Plugin

**스캔 항목**:
- 의존성 취약점
- 하드코딩된 시크릿
- SQL Injection
- XSS 취약점
- 보안 위반 코드 패턴

**실행 시점**:
- PR 생성 시
- main/develop 브랜치 푸시 시
- 매일 야간 (scheduled)

### 5.2 컨테이너 이미지 스캔

**도구**: Trivy, AWS ECR Image Scanning

**스캔 항목**:
- OS 패키지 취약점 (CVE)
- 애플리케이션 의존성 취약점
- 잘못된 설정

**실행 시점**:
- Docker 이미지 빌드 후
- ECR 푸시 시 (자동)

**기준**:
- Critical/High 취약점 발견 시 배포 차단
- Medium 이하는 경고만 표시

### 5.3 인프라 보안 스캔

**도구**: Checkov, tfsec (Terraform)

**스캔 항목**:
- IAM 과도한 권한
- 암호화되지 않은 리소스
- 공개된 보안 그룹
- 잘못된 네트워크 설정

**실행 시점**:
- Terraform PR 생성 시
- 인프라 변경 전

---

## 6. 테스트 전략

### 6.1 테스트 피라미드

```
           ┌─────────────────┐
          ╱  E2E Tests (5%)   ╲
         ╱────────────────────╲
        ╱  Integration Tests   ╲
       ╱       (15%)            ╲
      ╱──────────────────────────╲
     ╱     Unit Tests (80%)       ╲
    ╱──────────────────────────────╲
```

### 6.2 Unit Tests (80%)

**프레임워크**: Jest (Node.js), Flutter Test (Flutter)

**커버리지 목표**: 80% 이상

**실행 시점**:
- 로컬 개발 (pre-commit hook)
- PR 생성 시
- 모든 브랜치 푸시 시

**예시 (Jest)**:
```bash
npm run test:unit
npm run test:coverage
```

### 6.3 Integration Tests (15%)

**프레임워크**: Jest + Supertest (API 테스트)

**테스트 범위**:
- API 엔드포인트
- 데이터베이스 연동
- 외부 서비스 Mock

**실행 시점**:
- PR 생성 시
- develop/main 브랜치 푸시 시

**예시**:
```bash
npm run test:integration
```

### 6.4 E2E Tests (5%)

**프레임워크**: Playwright (Web), Maestro (Flutter)

**테스트 시나리오**:
- 사용자 회원가입 → 로그인
- 상품 검색 → 상세 보기 → 장바구니 추가
- 주문 생성 → 결제 → 주문 완료

**실행 시점**:
- Staging 배포 후
- Production 배포 전 (선택적)
- 야간 scheduled 실행

**예시**:
```bash
npm run test:e2e
```

### 6.5 Performance Tests

**도구**: k6, Artillery

**테스트 시나리오**:
- 부하 테스트 (100, 500, 1000 TPS)
- Spike 테스트 (순간 트래픽 급증)
- Endurance 테스트 (장시간 안정성)

**실행 시점**:
- Staging 배포 후
- Production 배포 전 (주요 변경 시)
- 주간 scheduled 실행

**성공 기준**:
- p95 응답 시간 < 500ms
- 에러율 < 0.1%
- CPU/Memory 사용률 < 70%

---

## 7. 롤백 전략

### 7.1 자동 롤백

**트리거 조건**:
```yaml
Auto Rollback Conditions:
  - Health Check 3회 연속 실패
  - 5xx 에러율 > 5% (5분간)
  - p99 응답 시간 > 3초 (5분간)
  - CPU 사용률 > 95% (5분간)
  - CloudWatch Alarm 트리거
```

**롤백 방식**:
1. CodeDeploy가 자동으로 이전 버전으로 트래픽 전환
2. 5분 내 100% 롤백 완료
3. Slack 알림 전송
4. 자동 Post-Mortem 이슈 생성

### 7.2 수동 롤백

**방법 1: GitHub Actions 워크플로우**
```bash
# .github/workflows/rollback.yml 실행
workflow_dispatch 입력:
  - service: product-service
  - environment: production
  - target_version: v1.2.3 (또는 git sha)
```

**방법 2: AWS CLI**
```bash
# ECS 이전 Task Definition으로 롤백
aws ecs update-service \
  --cluster doa-market-production-cluster \
  --service product-service \
  --task-definition product-service:123 \
  --force-new-deployment
```

**방법 3: CodeDeploy Console**
- AWS Console → CodeDeploy → Deployments
- "Stop and roll back" 클릭

### 7.3 데이터베이스 롤백

**Forward-Only Migration 원칙**:
- 데이터베이스는 롤백하지 않음
- 대신 "보상 마이그레이션" 생성

**예시**:
```sql
-- Migration: Add column
ALTER TABLE products ADD COLUMN new_field VARCHAR(255);

-- Rollback (X) - 실행하지 않음
-- ALTER TABLE products DROP COLUMN new_field;

-- Compensation Migration (O) - 새로운 마이그레이션 생성
-- Migration: Remove column (if needed)
ALTER TABLE products DROP COLUMN new_field;
```

**이유**:
- 데이터 손실 방지
- 동시 실행 중인 이전 버전 호환성
- Blue/Green 배포 시 두 버전 동시 실행

---

## 8. 배포 승인 프로세스

### 8.1 Development 환경

```
Approval Required: ✗
Auto Deploy: ✓
Notification: Slack (#dev-deployments)
```

### 8.2 Staging 환경

```
Approval Required: ✗
Auto Deploy: ✓
Smoke Tests: ✓ (자동 실행)
Notification: Slack (#staging-deployments)
```

### 8.3 Production 환경

```
Approval Required: ✓ (2명 이상)
Approvers:
  - DevOps Team
  - Backend Team Lead
  - CTO (주요 변경 시)
Wait Timer: 10분 (긴급 상황 대비)
Pre-Deployment Checklist:
  ✓ Staging 테스트 완료
  ✓ Performance 테스트 통과
  ✓ Security 스캔 통과
  ✓ 문서 업데이트
  ✓ Rollback 계획 수립
  ✓ On-call 엔지니어 대기
Deployment Window:
  - 화/목 오후 2시 ~ 6시 (정규 배포)
  - 월/수/금 긴급 배포만 가능
  - 주말/공휴일 배포 금지
Notification:
  - Slack (#production-deployments)
  - Email (전체 엔지니어링 팀)
Post-Deployment:
  - 30분간 모니터링
  - CloudWatch Dashboard 확인
  - Sentry 에러 모니터링
```

### 8.4 Hotfix 배포

**긴급 수정 프로세스**:
```
1. hotfix/* 브랜치 생성
2. 수정 커밋
3. PR 생성 → main
4. CI 통과 확인
5. 1명 승인 (간소화)
6. Production 배포
7. develop 브랜치에 merge
```

**승인 조건**:
- Critical/High 보안 취약점
- 서비스 장애
- 데이터 손실 위험
- 결제 시스템 오류

---

## 9. 모니터링 및 알림

### 9.1 배포 상태 알림

**Slack 채널**:
- `#dev-deployments`: Development 배포
- `#staging-deployments`: Staging 배포
- `#production-deployments`: Production 배포
- `#deployment-failures`: 실패한 배포

**알림 내용**:
```
🚀 Deployment Started
Service: product-service
Environment: production
Version: v1.2.3
Deployed by: @john.doe
Git SHA: abc123
```

```
✅ Deployment Successful
Service: product-service
Environment: production
Duration: 15m 32s
Health Status: ✓ Healthy
Metrics: 5xx: 0.01%, p99: 250ms
```

```
❌ Deployment Failed
Service: product-service
Environment: production
Reason: Health check failed
Rollback: ✓ Completed
Action Required: @oncall-team
```

### 9.2 배포 메트릭

**추적 메트릭**:
- Deployment Frequency (배포 빈도)
- Lead Time for Changes (변경 리드 타임)
- Change Failure Rate (변경 실패율)
- Mean Time to Recovery (평균 복구 시간)

**목표 (DORA Metrics)**:
```
Deployment Frequency: Daily (Elite)
Lead Time: < 1 day (Elite)
Change Failure Rate: < 15% (High)
MTTR: < 1 hour (Elite)
```

---

## 10. 워크플로우 파일 위치

### 10.1 백엔드 서비스
- `.github/workflows/backend-product-service.yml`
- `.github/workflows/backend-order-service.yml`
- `.github/workflows/backend-payment-service.yml`
- (나머지 13개 서비스)

### 10.2 프론트엔드
- `.github/workflows/frontend-admin-web.yml`
- `.github/workflows/frontend-seller-web.yml`
- `.github/workflows/frontend-user-app.yml`

### 10.3 Lambda
- `.github/workflows/lambda-image-resize.yml`
- `.github/workflows/lambda-event-consumers.yml`

### 10.4 인프라
- `.github/workflows/infrastructure-terraform.yml`
- `.github/workflows/db-migration.yml`

### 10.5 재사용 가능한 워크플로우
- `.github/workflows/_reusable-build-and-push.yml`
- `.github/workflows/_reusable-deploy-ecs.yml`
- `.github/workflows/_reusable-test.yml`

---

**문서 버전**: 1.0
**최종 수정일**: 2024-01-15
**작성자**: DOA Market DevOps Team
