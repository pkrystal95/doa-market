import 'package:flutter_test/flutter_test.dart';
import 'package:doa_market_user/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() async {
      // SharedPreferences 초기화
      SharedPreferences.setMockInitialValues({});
      authProvider = AuthProvider();
      // 초기화 대기
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('초기 상태는 인증되지 않은 상태여야 함', () {
      // Assert
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, isNull);
      expect(authProvider.userId, isNull);
      expect(authProvider.userEmail, isNull);
      expect(authProvider.userName, isNull);
    });

    test('로그아웃 시 모든 인증 정보가 삭제되어야 함', () async {
      // Arrange - 먼저 SharedPreferences에 데이터 설정
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'test-token');
      await prefs.setString('userId', 'user-123');
      await prefs.setString('userEmail', 'test@example.com');
      await prefs.setString('userName', '테스트 사용자');

      // 새로운 AuthProvider 인스턴스 생성하여 데이터 로드
      final authProviderWithData = AuthProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await authProviderWithData.logout();

      // Assert
      expect(authProviderWithData.isAuthenticated, false);
      expect(authProviderWithData.token, isNull);
      expect(authProviderWithData.userId, isNull);
      expect(authProviderWithData.userEmail, isNull);
      expect(authProviderWithData.userName, isNull);

      // SharedPreferences에서도 삭제되었는지 확인
      final clearedPrefs = await SharedPreferences.getInstance();
      expect(clearedPrefs.getString('token'), isNull);
      expect(clearedPrefs.getString('userId'), isNull);
    });

    test('저장된 인증 정보가 있으면 로드되어야 함', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'token': 'saved-token',
        'userId': 'user-456',
        'userEmail': 'saved@example.com',
        'userName': '저장된 사용자',
      });

      // Act
      final newAuthProvider = AuthProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(newAuthProvider.isAuthenticated, true);
      expect(newAuthProvider.token, 'saved-token');
      expect(newAuthProvider.userId, 'user-456');
      expect(newAuthProvider.userEmail, 'saved@example.com');
      expect(newAuthProvider.userName, '저장된 사용자');
    });

    test('API Gateway URL이 올바르게 설정되어야 함', () {
      // Assert
      expect(AuthProvider.apiGatewayUrl, 'http://localhost:3000/api/v1');
    });
  });
}
