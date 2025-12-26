# 빠른 테스트 시작 가이드

## 1분 안에 테스트 시작하기

### 1단계: 패키지 설치
```bash
cd user-app
flutter pub get
```

### 2단계: 테스트 실행
```bash
# 모든 테스트 실행
flutter test

# 상세 출력과 함께
flutter test --reporter expanded
```

### 3단계: 개별 테스트 실행

#### 모델 테스트
```bash
flutter test test/models/product_test.dart
flutter test test/models/cart_item_test.dart
```

#### Provider 테스트
```bash
flutter test test/providers/auth_provider_test.dart
```

#### 위젯 테스트
```bash
flutter test test/widgets/login_screen_test.dart
```

#### 통합 테스트
```bash
flutter test integration_test/app_flow_test.dart
```

## 테스트 결과 확인

테스트 실행 후 다음과 같은 결과를 볼 수 있습니다:

```
00:01 +5: All tests passed!
```

## 커버리지 확인

```bash
# 커버리지 생성
flutter test --coverage

# HTML 리포트 생성 (macOS/Linux)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# HTML 리포트 생성 (Windows)
perl C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html
```

## 문제 해결

### 에러: "No pubspec.yaml file found"
```bash
# user-app 디렉토리로 이동했는지 확인
cd user-app
```

### 에러: "MissingPluginException"
```bash
# 패키지 재설치
flutter clean
flutter pub get
```

### 에러: SharedPreferences 관련
테스트 파일에 다음 코드가 있는지 확인:
```dart
setUp(() {
  SharedPreferences.setMockInitialValues({});
});
```

## 다음 단계

1. 📖 자세한 가이드: `TESTING_GUIDE.md` 읽기
2. 📋 테스트 시나리오: `TEST_SCENARIOS.md` 확인
3. ✍️ 새로운 테스트 작성하기
4. 🚀 CI/CD 통합하기

## 유용한 명령어

```bash
# 특정 테스트만 실행
flutter test test/models/

# 테스트 파일 감시 모드 (파일 변경 시 자동 실행)
flutter test --watch

# 특정 그룹만 실행
flutter test --name "Product Model"

# 병렬 실행 (더 빠름)
flutter test --concurrency=4
```

## 테스트 작성 템플릿

### 단위 테스트
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('테스트 그룹명', () {
    test('테스트 설명', () {
      // Arrange (준비)

      // Act (실행)

      // Assert (검증)
      expect(actual, expected);
    });
  });
}
```

### 위젯 테스트
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('위젯 테스트 설명', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(MyWidget());

    // Act
    await tester.tap(find.byType(Button));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('결과'), findsOneWidget);
  });
}
```

## 도움말

문제가 발생하면:
1. `flutter doctor` 실행
2. `flutter clean && flutter pub get` 실행
3. 에러 메시지 확인
4. 문서 참조: `TESTING_GUIDE.md`
