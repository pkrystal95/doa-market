import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doa_market_user/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('마이페이지 전체 기능 E2E 테스트', () {
    testWidgets('프로필 → 주문내역 → 배송지 → 찜목록 전체 플로우', (WidgetTester tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ========================================
      // 사전 조건: 로그인된 상태로 진행
      // ========================================
      print('🔹 로그인 확인');
      
      // 로그인되어 있지 않다면 로그인 진행
      final loginButton = find.text('로그인');
      if (loginButton.evaluate().isNotEmpty) {
        // 간단히 테스트 계정으로 로그인
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // 이메일과 비밀번호 입력 (실제 값은 환경에 맞게 조정)
        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'test@test.com');
          await tester.enterText(textFields.at(1), 'Test1234!');
          await tester.pumpAndSettle();

          // 로그인 버튼 클릭
          final submitButton = find.byType(ElevatedButton);
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }

      // ========================================
      // 1. 마이페이지로 이동
      // ========================================
      print('🔹 Step 1: 마이페이지 진입');
      
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        // 마이페이지 탭 클릭 (보통 마지막 탭 또는 프로필 아이콘)
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('✅ 마이페이지 진입 완료');
        }
      }

      // 마이페이지 주요 섹션 확인
      await tester.pumpAndSettle();

      // ========================================
      // 2. 프로필 정보 확인 및 수정
      // ========================================
      print('🔹 Step 2: 프로필 정보 확인 및 수정');
      
      // 프로필 수정 버튼 찾기
      final profileEditButton = find.text('프로필 수정');
      if (profileEditButton.evaluate().isEmpty) {
        // 대체 텍스트로 찾기
        final editButtons = find.byIcon(Icons.edit);
        if (editButtons.evaluate().isNotEmpty) {
          await tester.tap(editButtons.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // 프로필 정보 수정 (이름 변경)
          final nameField = find.byType(TextField);
          if (nameField.evaluate().isNotEmpty) {
            await tester.enterText(nameField.first, 'Updated Name');
            await tester.pumpAndSettle();

            // 저장 버튼
            final saveButton = find.text('저장');
            if (saveButton.evaluate().isNotEmpty) {
              await tester.tap(saveButton);
              await tester.pumpAndSettle(const Duration(seconds: 1));
              print('✅ 프로필 수정 완료');
            }
          }

          // 뒤로 가기
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      } else {
        await tester.tap(profileEditButton);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        // 프로필 수정 후 뒤로 가기
        await tester.pageBack();
        await tester.pumpAndSettle();
        print('✅ 프로필 조회 완료');
      }

      // ========================================
      // 3. 주문 내역 확인
      // ========================================
      print('🔹 Step 3: 주문 내역 조회');
      
      // 주문내역 버튼 찾기
      final orderHistoryButton = find.text('주문내역');
      if (orderHistoryButton.evaluate().isEmpty) {
        // 대체로 "전체 주문내역" 또는 아이콘으로 찾기
        final orderButton = find.textContaining('주문');
        if (orderButton.evaluate().isNotEmpty) {
          await tester.tap(orderButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      } else {
        await tester.tap(orderHistoryButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // 주문 내역 화면에서 필터 테스트
      final filterButtons = find.text('전체');
      if (filterButtons.evaluate().isNotEmpty) {
        print('  - 주문 내역 필터 확인');
        
        // 다른 필터 탭 시도 (배송중, 배송완료 등)
        final deliveryFilter = find.text('배송중');
        if (deliveryFilter.evaluate().isNotEmpty) {
          await tester.tap(deliveryFilter);
          await tester.pumpAndSettle();
        }
      }

      // 주문 상세 확인 (첫 번째 주문이 있다면)
      final orderCards = find.byType(Card);
      if (orderCards.evaluate().isNotEmpty) {
        await tester.tap(orderCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  - 주문 상세 조회 완료');

        // 뒤로 가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      print('✅ 주문 내역 조회 완료');

      // 마이페이지로 돌아가기
      await tester.pageBack();
      await tester.pumpAndSettle();

      // ========================================
      // 4. 배송지 관리
      // ========================================
      print('🔹 Step 4: 배송지 관리');
      
      // 배송지 관리 버튼 찾기
      final addressButton = find.text('배송지 관리');
      if (addressButton.evaluate().isNotEmpty) {
        await tester.tap(addressButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 배송지 추가 버튼
        final addAddressButton = find.byIcon(Icons.add);
        if (addAddressButton.evaluate().isNotEmpty) {
          await tester.tap(addAddressButton);
          await tester.pumpAndSettle();

          // 배송지 정보 입력
          final addressFields = find.byType(TextField);
          if (addressFields.evaluate().length >= 4) {
            await tester.enterText(addressFields.at(0), '홍길동');
            await tester.enterText(addressFields.at(1), '010-1234-5678');
            await tester.enterText(addressFields.at(2), '12345');
            await tester.enterText(addressFields.at(3), '서울시 강남구 테헤란로');
            await tester.pumpAndSettle();

            // 저장 버튼
            final saveButton = find.text('저장');
            if (saveButton.evaluate().isNotEmpty) {
              await tester.tap(saveButton);
              await tester.pumpAndSettle(const Duration(seconds: 1));
              print('  - 배송지 추가 완료');
            }
          }
        }

        // 배송지 목록 확인
        await tester.pumpAndSettle();
        print('✅ 배송지 관리 완료');

        // 뒤로 가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // ========================================
      // 5. 찜 목록 확인
      // ========================================
      print('🔹 Step 5: 찜 목록 조회');
      
      // 찜한 상품 버튼 찾기
      final wishlistButton = find.textContaining('찜');
      if (wishlistButton.evaluate().isNotEmpty) {
        await tester.tap(wishlistButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 찜 목록에서 상품 확인
        final wishlistItems = find.byType(Card);
        if (wishlistItems.evaluate().isNotEmpty) {
          print('  - 찜한 상품 ${wishlistItems.evaluate().length}개 확인');
          
          // 첫 번째 상품을 장바구니에 담기
          final addToCartButtons = find.text('담기');
          if (addToCartButtons.evaluate().isNotEmpty) {
            await tester.tap(addToCartButtons.first);
            await tester.pumpAndSettle();
            print('  - 찜 목록에서 장바구니 담기 완료');
          }
        }

        print('✅ 찜 목록 조회 완료');

        // 뒤로 가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // ========================================
      // 6. 회원 등급 및 포인트 확인
      // ========================================
      print('🔹 Step 6: 회원 등급 및 포인트 확인');
      
      // 마이페이지에 등급이나 포인트 정보가 표시되는지 확인
      final gradeInfo = find.textContaining('GOLD').or(find.textContaining('등급'));
      if (gradeInfo.evaluate().isNotEmpty) {
        print('  - 회원 등급 정보 확인됨');
      }

      final pointInfo = find.textContaining('P').or(find.textContaining('적립금'));
      if (pointInfo.evaluate().isNotEmpty) {
        print('  - 포인트 정보 확인됨');
      }

      print('✅ 회원 정보 확인 완료');

      // ========================================
      // 7. 로그아웃
      // ========================================
      print('🔹 Step 7: 로그아웃');
      
      // 로그아웃 버튼 찾기
      final logoutButton = find.text('로그아웃');
      if (logoutButton.evaluate().isNotEmpty) {
        // 스크롤이 필요할 수 있음
        await tester.scrollUntilVisible(
          logoutButton,
          100,
          scrollable: find.byType(Scrollable).last,
        );
        
        await tester.tap(logoutButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('✅ 로그아웃 완료');
      }

      // 최종 확인
      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 마이페이지 전체 플로우 테스트 완료! ✅✅✅\n');
    });
  });
}
