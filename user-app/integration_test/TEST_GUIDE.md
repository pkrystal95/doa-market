# 📊 E2E 테스트 보고서 가이드

## 🎯 빠른 시작

### 1️⃣ 기존 테스트 보고서 보기

**HTML 보고서 (추천)**
```bash
# 브라우저에서 열기
open test-report.html
```

**커버리지 보고서**
```bash
# 커버리지 정보 확인
cat coverage/lcov.info
```

---

### 2️⃣ 새로운 E2E 테스트 실행 및 보고서 생성

#### 자동 실행 스크립트 사용 (권장)

```bash
# 스크립트 실행
./run_integration_tests.sh
```

스크립트가 자동으로:
- ✅ 사용 가능한 디바이스 목록 표시
- ✅ 모든 E2E 테스트 순차 실행
- ✅ 텍스트 보고서 생성 (`.txt`)
- ✅ HTML 보고서 생성 (`.html`)
- ✅ 결과 요약 출력
- ✅ 브라우저에서 보고서 자동 열기

**생성되는 보고서:**
- 📄 `test_reports/e2e_test_report_YYYYMMDD_HHMMSS.txt`
- 🌐 `test_reports/e2e_test_report_YYYYMMDD_HHMMSS.html`

---

#### 수동 실행 (개별 테스트)

```bash
# 1. 디바이스 확인
flutter devices

# 2. 개별 테스트 실행
flutter test integration_test/review_flow_test.dart -d <device_id>

# 3. 결과를 파일로 저장
flutter test integration_test/review_flow_test.dart -d <device_id> 2>&1 | tee test_result.txt
```

---

## 📁 보고서 위치

### 기존 보고서
```
user-app/
├── test-report.html          ← 기존 단위 테스트 보고서
└── coverage/
    └── lcov.info             ← 커버리지 정보
```

### E2E 테스트 보고서
```
user-app/
└── test_reports/             ← 새로 생성됨
    ├── e2e_test_report_20251227_003000.txt
    └── e2e_test_report_20251227_003000.html
```

---

## 🌐 HTML 보고서 기능

HTML 보고서에는 다음 정보가 포함됩니다:

### 📊 요약 대시보드
- 전체 테스트 수
- 성공한 테스트 수
- 실패한 테스트 수

### 📋 상세 결과
각 테스트별:
- ✅/❌ 성공/실패 상태
- 테스트 이름
- 파일명
- 실행 시간

### 🎨 시각화
- 색상 코딩 (성공: 초록, 실패: 빨강)
- 반응형 디자인
- 깔끔한 UI

---

## 🔍 보고서 분석

### 성공적인 테스트
```
✅ 리뷰 작성 및 조회
   파일: review_flow_test.dart
   상태: 성공
```

### 실패한 테스트
```
❌ 포인트 및 출석체크
   파일: point_checkin_flow_test.dart
   상태: 실패
   자세한 내용은 텍스트 보고서를 확인하세요.
```

---

## 🛠️ 트러블슈팅

### 테스트가 실행되지 않는 경우

**1. 디바이스가 없는 경우**
```bash
# 에뮬레이터 목록 확인
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch apple_ios_simulator
```

**2. 백엔드 서버가 실행 중이 아닌 경우**
```bash
# 백엔드 서버 시작 필요
# (백엔드 프로젝트 디렉토리에서)
docker-compose up
```

**3. 테스트 계정이 없는 경우**
- 테스트 계정 생성: `test@test.com` / `Test1234!`
- 또는 테스트 파일에서 계정 정보 수정

---

## 📈 지속적 통합 (CI/CD)

### GitHub Actions 예시

`.github/workflows/integration_test.yml` 파일 생성:

```yaml
name: E2E Integration Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.3'

    - name: Install dependencies
      run: flutter pub get
      working-directory: ./user-app

    - name: Start iOS Simulator
      run: |
        xcrun simctl boot "iPhone 14" || true

    - name: Run Integration Tests
      run: ./run_integration_tests.sh
      working-directory: ./user-app

    - name: Upload Test Reports
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: test-reports
        path: user-app/test_reports/
```

---

## 📊 커버리지 보고서 생성

단위 테스트의 코드 커버리지를 확인하려면:

```bash
# 1. 커버리지와 함께 테스트 실행
flutter test --coverage

# 2. HTML 보고서 생성 (genhtml 필요)
genhtml coverage/lcov.info -o coverage/html

# 3. 브라우저에서 열기
open coverage/html/index.html
```

---

## 🎯 베스트 프랙티스

### 1. 정기적인 테스트 실행
- 매일 또는 매주 전체 E2E 테스트 실행
- PR 생성 시 자동 테스트 실행

### 2. 보고서 보관
- 각 릴리스마다 테스트 보고서 저장
- 버전별 품질 추적

### 3. 실패 분석
- 실패한 테스트는 즉시 분석
- 재현 가능한지 확인
- 버그 티켓 생성

### 4. 성능 모니터링
- 테스트 실행 시간 추적
- 느린 테스트 최적화

---

## 📞 문의

테스트 관련 문제나 질문이 있으시면:
1. `integration_test/README.md` 참조
2. 로그 파일 확인 (`test_reports/*.txt`)
3. Flutter 공식 문서 참조

---

**작성일:** 2025-12-27
**버전:** 1.0.0
