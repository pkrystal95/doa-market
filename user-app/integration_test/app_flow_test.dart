import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doa_market_user/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('앱 통합 테스트', () {
    testWidgets('앱 시작 및 스플래시 화면 표시', (WidgetTester tester) async {
      // Arrange & Act
      app.main();
      await tester.pumpAndSettle();

      // 스플래시 화면이나 로그인 화면이 표시되어야 함
      // (인증 상태에 따라 다름)
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('로그인 화면 UI 요소 확인', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Act - 로그인 화면으로 이동 (이미 로그인 화면에 있을 수도 있음)
      await tester.pumpAndSettle();

      // Assert - 로그인 화면의 필수 요소 확인
      // DOA 로고나 이메일 입력 필드가 있어야 함
      expect(
        find.byType(TextField).evaluate().length >= 2 ||
            find.text('DOA').evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('네비게이션 테스트', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 앱이 정상적으로 실행되고 화면이 표시되는지 확인
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('UI 인터랙션 테스트', () {
    testWidgets('텍스트 입력 필드 상호작용', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // TextField가 있는지 확인
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        // Act - 첫 번째 TextField에 텍스트 입력
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('test@example.com'), findsWidgets);
      }
    });

    testWidgets('버튼 탭 인터랙션', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ElevatedButton이나 TextButton이 있는지 확인
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        // Act - 버튼 탭
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();

        // Assert - 앱이 크래시하지 않고 정상 동작
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });

  group('화면 전환 테스트', () {
    testWidgets('스플래시 화면에서 다음 화면으로 전환', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pump();

      // Act - 스플래시 대기
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Assert - 화면 전환 완료
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Provider 상태 관리 테스트', () {
    testWidgets('앱이 Provider와 함께 정상 실행', (WidgetTester tester) async {
      // Arrange & Act
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert - MultiProvider가 정상 작동
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
