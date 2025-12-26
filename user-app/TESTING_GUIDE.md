# DOA Market User App - 테스트 가이드

## 목차
1. [테스트 환경 설정](#테스트-환경-설정)
2. [테스트 실행 방법](#테스트-실행-방법)
3. [테스트 종류](#테스트-종류)
4. [테스트 시나리오](#테스트-시나리오)
5. [CI/CD 통합](#cicd-통합)

## 테스트 환경 설정

### 1. 필수 패키지 설치

테스트에 필요한 패키지들이 이미 `pubspec.yaml`에 포함되어 있습니다:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
  integration_test:
    sdk: flutter
  http_mock_adapter: ^0.6.1
```

패키지 설치:
```bash
cd user-app
flutter pub get
```

### 2. Flutter 환경 확인

```bash
flutter doctor
```

모든 항목이 체크되어야 정상적으로 테스트를 실행할 수 있습니다.

## 테스트 실행 방법

### 1. 전체 테스트 실행

```bash
# 모든 단위 테스트 및 위젯 테스트 실행
flutter test

# 상세한 출력과 함께 실행
flutter test --reporter expanded
```

### 2. 특정 테스트 파일 실행

```bash
# 특정 테스트 파일 실행
flutter test test/models/product_test.dart

# 특정 그룹만 실행
flutter test test/providers/auth_provider_test.dart
```

### 3. 통합 테스트 실행

통합 테스트는 실제 디바이스나 에뮬레이터에서 실행됩니다.

```bash
# 에뮬레이터/시뮬레이터 시작
flutter emulators --launch <emulator_id>

# 또는 연결된 디바이스 확인
flutter devices

# 통합 테스트 실행
flutter test integration_test/app_flow_test.dart

# 또는 드라이버를 사용한 통합 테스트
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart
```

### 4. 코드 커버리지 확인

```bash
# 커버리지 리포트 생성
flutter test --coverage

# 커버리지 HTML 리포트 생성 (lcov 필요)
genhtml coverage/lcov.info -o coverage/html

# 브라우저에서 확인
open coverage/html/index.html
```

## 테스트 종류

### 1. 단위 테스트 (Unit Tests)

**위치**: `test/models/`, `test/providers/`

**목적**: 개별 클래스와 메서드의 로직 검증

**작성된 테스트**:
- `test/models/product_test.dart` - Product 모델 테스트
- `test/models/cart_item_test.dart` - CartItem 모델 테스트
- `test/providers/auth_provider_test.dart` - 인증 Provider 테스트

**실행 방법**:
```bash
flutter test test/models/
flutter test test/providers/
```

### 2. 위젯 테스트 (Widget Tests)

**위치**: `test/widgets/`

**목적**: UI 컴포넌트의 렌더링과 상호작용 검증

**작성된 테스트**:
- `test/widgets/login_screen_test.dart` - 로그인 화면 테스트

**실행 방법**:
```bash
flutter test test/widgets/
```

### 3. 통합 테스트 (Integration Tests)

**위치**: `integration_test/`

**목적**: 전체 앱 플로우와 사용자 시나리오 검증

**작성된 테스트**:
- `integration_test/app_flow_test.dart` - 앱 전체 플로우 테스트

**실행 방법**:
```bash
flutter test integration_test/
```

## 테스트 시나리오

### 단위 테스트 시나리오

#### Product Model
- ✅ JSON에서 Product 객체 생성
- ✅ 필수 필드 누락 시 기본값 처리
- ✅ 잘못된 가격 형식 처리
- ✅ Product를 JSON으로 변환
- ✅ 대체 필드명 처리 (imageUrl vs thumbnail)

#### CartItem Model
- ✅ CartItem 객체 생성
- ✅ 총 가격 계산
- ✅ 수량 변경
- ✅ JSON 직렬화/역직렬화
- ✅ 기본값 처리

#### AuthProvider
- ✅ 초기 인증 상태 확인
- ✅ 로그아웃 기능
- ✅ 저장된 인증 정보 로드
- ✅ SharedPreferences 동기화

### 위젯 테스트 시나리오

#### LoginScreen
- ✅ 필수 UI 요소 렌더링
- ✅ 이메일/비밀번호 입력 필드
- ✅ 텍스트 입력 기능
- ✅ 비밀번호 표시/숨김 토글
- ✅ 자동 로그인 체크박스
- ✅ 빈 입력 시 에러 메시지
- ✅ 회원가입 페이지 이동

### 통합 테스트 시나리오

#### 앱 플로우
- ✅ 앱 시작 및 스플래시 화면
- ✅ 로그인 화면 UI 확인
- ✅ 네비게이션 테스트
- ✅ TextField 상호작용
- ✅ 버튼 탭 인터랙션
- ✅ 화면 전환
- ✅ Provider 상태 관리

## 추가 테스트 작성 가이드

### 단위 테스트 작성 예시

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyClass Tests', () {
    test('should do something', () {
      // Arrange
      final myClass = MyClass();

      // Act
      final result = myClass.doSomething();

      // Assert
      expect(result, expectedValue);
    });
  });
}
```

### 위젯 테스트 작성 예시

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyWidget has a title', (WidgetTester tester) async {
    // Arrange & Act
    await tester.pumpWidget(
      MaterialApp(home: MyWidget()),
    );

    // Assert
    expect(find.text('Title'), findsOneWidget);
  });
}
```

### 통합 테스트 작성 예시

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete user flow', (WidgetTester tester) async {
    // 앱 시작
    app.main();
    await tester.pumpAndSettle();

    // 사용자 시나리오 테스트
  });
}
```

## CI/CD 통합

### GitHub Actions 예시

```yaml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: cd user-app && flutter pub get
      - run: cd user-app && flutter test
      - run: cd user-app && flutter test --coverage
```

## 베스트 프랙티스

1. **테스트 격리**: 각 테스트는 독립적으로 실행되어야 합니다
2. **AAA 패턴**: Arrange(준비), Act(실행), Assert(검증) 패턴 사용
3. **명확한 테스트명**: 테스트가 무엇을 검증하는지 명확히 작성
4. **Mock 사용**: 외부 의존성은 Mock으로 대체
5. **커버리지 목표**: 최소 70% 이상의 코드 커버리지 유지

## 문제 해결

### 일반적인 문제들

1. **SharedPreferences 에러**
   ```dart
   setUp(() {
     SharedPreferences.setMockInitialValues({});
   });
   ```

2. **Provider 에러**
   ```dart
   await tester.pumpWidget(
     MultiProvider(
       providers: [/* providers */],
       child: MyApp(),
     ),
   );
   ```

3. **비동기 테스트**
   ```dart
   await tester.pumpAndSettle(); // 모든 애니메이션 완료 대기
   ```

## 다음 단계

1. 추가 Provider 테스트 작성 (CartProvider, ProductProvider 등)
2. 더 많은 화면 위젯 테스트 작성
3. E2E 테스트 시나리오 확장
4. Mock 서버를 사용한 API 테스트
5. 성능 테스트 추가

## 참고 자료

- [Flutter Testing 공식 문서](https://flutter.dev/docs/testing)
- [Mockito 문서](https://pub.dev/packages/mockito)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)
