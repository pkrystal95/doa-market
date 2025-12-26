import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doa_market_user/screens/login_screen.dart';
import 'package:doa_market_user/providers/auth_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createLoginScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('화면에 필수 요소들이 표시되어야 함', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('DOA'), findsOneWidget);
      expect(find.text('이메일을 입력해주세요.'), findsOneWidget);
      expect(find.text('비밀번호를 입력해 주세요.'), findsOneWidget);
      expect(find.text('로그인'), findsOneWidget);
      expect(find.text('자동 로그인'), findsOneWidget);
      expect(find.text('아이디 찾기'), findsOneWidget);
      expect(find.text('비밀번호 재설정'), findsOneWidget);
      expect(find.text('회원가입'), findsOneWidget);
    });

    testWidgets('이메일과 비밀번호 입력 필드가 있어야 함', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Assert
      final emailField = find.widgetWithText(TextField, '이메일을 입력해주세요.');
      final passwordField = find.widgetWithText(TextField, '비밀번호를 입력해 주세요.');

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
    });

    testWidgets('이메일 입력이 가능해야 함', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.widgetWithText(TextField, '이메일을 입력해주세요.'),
        'test@example.com',
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('비밀번호 입력이 가능해야 함', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.widgetWithText(TextField, '비밀번호를 입력해 주세요.'),
        'password123',
      );
      await tester.pumpAndSettle();

      // Assert - 비밀번호는 obscureText로 숨겨져야 함
      final passwordField = tester.widget<TextField>(
        find.widgetWithText(TextField, '비밀번호를 입력해 주세요.'),
      );
      expect(passwordField.obscureText, true);
    });

    testWidgets('비밀번호 표시/숨김 토글이 동작해야 함', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // 초기 상태: 비밀번호 숨김
      var passwordField = tester.widget<TextField>(
        find.widgetWithText(TextField, '비밀번호를 입력해 주세요.'),
      );
      expect(passwordField.obscureText, true);

      // Act: 비밀번호 표시 아이콘 클릭
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      // Assert: 비밀번호 표시됨
      passwordField = tester.widget<TextField>(
        find.widgetWithText(TextField, '비밀번호를 입력해 주세요.'),
      );
      expect(passwordField.obscureText, false);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Act: 다시 숨김 아이콘 클릭
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      // Assert: 비밀번호 다시 숨김
      passwordField = tester.widget<TextField>(
        find.widgetWithText(TextField, '비밀번호를 입력해 주세요.'),
      );
      expect(passwordField.obscureText, true);
    });

    testWidgets('자동 로그인 체크박스가 동작해야 함', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // 초기 상태: 체크됨
      var checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);

      // Act: 체크박스 클릭
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Assert: 체크 해제됨
      checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('빈 입력으로 로그인 시도 시 에러 메시지가 표시되어야 함', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Act: 로그인 버튼 클릭 (빈 입력)
      await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
      await tester.pumpAndSettle();

      // Assert: 에러 메시지 표시
      expect(find.text('아이디 또는 비밀번호를 잘못 입력 하였습니다.'), findsOneWidget);
    });

    testWidgets('회원가입 버튼 클릭 시 페이지 이동', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/signup': (context) => const Scaffold(
                    body: Center(child: Text('회원가입 페이지')),
                  ),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: 회원가입 버튼 클릭
      await tester.tap(find.text('회원가입'));
      await tester.pumpAndSettle();

      // Assert: 회원가입 페이지로 이동
      expect(find.text('회원가입 페이지'), findsOneWidget);
    });

    testWidgets('로그인 버튼이 비활성화되지 않아야 함 (초기 상태)', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Assert
      final loginButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '로그인'),
      );
      expect(loginButton.enabled, true);
    });
  });
}
