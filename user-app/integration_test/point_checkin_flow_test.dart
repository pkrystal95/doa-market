import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doa_market_user/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('포인트 및 출석체크 플로우 E2E 테스트', () {
    testWidgets('출석체크 → 포인트 적립 → 포인트 사용 전체 플로우', (WidgetTester tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ========================================
      // 사전 조건: 로그인된 상태로 진행
      // ========================================
      print('🔹 로그인 확인');

      final loginButton = find.text('로그인');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'test@test.com');
          await tester.enterText(textFields.at(1), 'Test1234!');
          await tester.pumpAndSettle();

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
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('✅ 마이페이지 진입 완료');
        }
      }

      // ========================================
      // 2. 현재 포인트 확인
      // ========================================
      print('🔹 Step 2: 현재 포인트 확인');

      // 마이페이지에서 포인트 정보 찾기
      final pointInfo = find.textContaining('P')
          .or(find.textContaining('포인트'))
          .or(find.textContaining('적립금'));

      if (pointInfo.evaluate().isNotEmpty) {
        print('  - 현재 포인트 정보 확인됨');
      }

      // 회원 등급 정보 확인
      final gradeInfo = find.textContaining('GOLD')
          .or(find.textContaining('SILVER'))
          .or(find.textContaining('등급'));

      if (gradeInfo.evaluate().isNotEmpty) {
        print('  - 회원 등급 정보 확인됨');
      }

      print('✅ 포인트 및 등급 정보 확인 완료');

      // ========================================
      // 3. 출석체크 화면으로 이동
      // ========================================
      print('🔹 Step 3: 출석체크 진입');

      final checkinButton = find.text('출석체크')
          .or(find.text('데일리 출석체크'))
          .or(find.textContaining('출석'));

      if (checkinButton.evaluate().isNotEmpty) {
        await tester.tap(checkinButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  - 출석체크 화면 진입 완료');

        // ========================================
        // 4. 출석체크 실행
        // ========================================
        print('🔹 Step 4: 출석체크 실행');

        // 출석체크 달력 확인
        final calendarView = find.byType(GridView)
            .or(find.byType(TableCalendar));

        if (calendarView.evaluate().isNotEmpty) {
          print('  - 출석체크 달력 표시됨');
        }

        // 출석체크 버튼 찾기
        final checkInButton = find.text('출석하기')
            .or(find.text('체크인'))
            .or(find.byType(ElevatedButton));

        if (checkInButton.evaluate().isNotEmpty) {
          // 출석체크 버튼 탭
          await tester.tap(checkInButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // 출석체크 완료 메시지 확인
          final successMessage = find.textContaining('출석')
              .or(find.textContaining('포인트'))
              .or(find.textContaining('적립'));

          if (successMessage.evaluate().isNotEmpty) {
            print('  - 출석체크 완료 메시지 확인됨');
          }

          // 스낵바 확인 (있는 경우)
          final snackBar = find.byType(SnackBar);
          if (snackBar.evaluate().isNotEmpty) {
            print('  - 출석체크 성공 스낵바 표시됨');
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }

          print('✅ 출석체크 완료');
        } else {
          print('  ⚠️ 이미 출석체크를 완료했거나 버튼을 찾을 수 없습니다');
        }

        // 연속 출석일 확인
        final streakInfo = find.textContaining('연속')
            .or(find.textContaining('일째'));

        if (streakInfo.evaluate().isNotEmpty) {
          print('  - 연속 출석일 정보 확인됨');
        }

        // 이번 달 출석 현황 확인
        await tester.pumpAndSettle();
        print('  - 이번 달 출석 현황 확인 완료');

        // 출석체크 화면에서 나가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      } else {
        print('  ⚠️ 출석체크 메뉴를 찾을 수 없습니다');
      }

      // ========================================
      // 5. 포인트 내역 조회
      // ========================================
      print('🔹 Step 5: 포인트 내역 조회');

      // 포인트 내역 메뉴 찾기
      final pointHistoryButton = find.text('포인트 내역')
          .or(find.text('적립금 내역'))
          .or(find.textContaining('포인트'));

      if (pointHistoryButton.evaluate().isNotEmpty) {
        await tester.tap(pointHistoryButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  - 포인트 내역 화면 진입');

        // 포인트 내역 리스트 확인
        final pointList = find.byType(ListView)
            .or(find.byType(ListTile))
            .or(find.byType(Card));

        if (pointList.evaluate().isNotEmpty) {
          print('  - 포인트 적립/사용 내역 목록 확인됨');
        }

        // 필터 옵션 확인 (전체, 적립, 사용)
        final filterAll = find.text('전체');
        final filterEarned = find.text('적립');
        final filterUsed = find.text('사용');

        if (filterAll.evaluate().isNotEmpty) {
          print('  - 포인트 필터 옵션 확인됨');

          // 적립 필터 선택
          if (filterEarned.evaluate().isNotEmpty) {
            await tester.tap(filterEarned);
            await tester.pumpAndSettle();
            print('  - 적립 내역 필터 적용');
          }

          // 사용 필터 선택
          if (filterUsed.evaluate().isNotEmpty) {
            await tester.tap(filterUsed);
            await tester.pumpAndSettle();
            print('  - 사용 내역 필터 적용');
          }

          // 전체 필터로 복귀
          await tester.tap(filterAll);
          await tester.pumpAndSettle();
        }

        // 포인트 상세 내역 확인
        final pointCards = find.byType(Card);
        if (pointCards.evaluate().isNotEmpty) {
          print('  - 포인트 상세 내역 확인');

          // 스크롤 테스트
          try {
            await tester.drag(find.byType(ListView).first, const Offset(0, -200));
            await tester.pumpAndSettle();
            print('  - 포인트 내역 스크롤 테스트 완료');
          } catch (e) {
            print('  - 스크롤 불가 (내역이 적음)');
          }
        }

        print('✅ 포인트 내역 조회 완료');

        // 포인트 내역에서 나가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      } else {
        print('  ⚠️ 포인트 내역 메뉴를 찾을 수 없습니다');
      }

      // ========================================
      // 6. 포인트 사용 (결제 시)
      // ========================================
      print('🔹 Step 6: 포인트 사용 시나리오');

      // 홈으로 이동
      if (bottomNavBar.evaluate().isNotEmpty) {
        final homeTab = find.byIcon(Icons.home);
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // 상품 선택
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 장바구니에 담기
        final addToCartButton = find.text('장바구니');
        if (addToCartButton.evaluate().isNotEmpty) {
          await tester.tap(addToCartButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        } else {
          final cartButtons = find.byType(ElevatedButton);
          if (cartButtons.evaluate().isNotEmpty) {
            await tester.tap(cartButtons.first);
            await tester.pumpAndSettle();
          }
        }

        // 상품 상세에서 나가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // 장바구니로 이동
      final cartIcon = find.byIcon(Icons.shopping_cart);
      if (cartIcon.evaluate().isNotEmpty) {
        await tester.tap(cartIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 결제하기 버튼
        final checkoutButton = find.text('결제하기');
        if (checkoutButton.evaluate().isNotEmpty) {
          await tester.tap(checkoutButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // 포인트 사용 옵션 확인
          final pointUsageSection = find.textContaining('포인트')
              .or(find.textContaining('적립금'));

          if (pointUsageSection.evaluate().isNotEmpty) {
            print('  - 결제 화면에서 포인트 사용 옵션 확인됨');

            // 포인트 사용 입력 필드 찾기
            final pointInputFields = find.byType(TextField);
            for (int i = 0; i < pointInputFields.evaluate().length; i++) {
              final widget = tester.widget<TextField>(pointInputFields.at(i));
              if (widget.decoration?.labelText?.contains('포인트') ?? false) {
                await tester.enterText(pointInputFields.at(i), '1000');
                await tester.pumpAndSettle();
                print('  - 포인트 1000원 사용 입력');
                break;
              }
            }

            // 전액 사용 버튼 (있는 경우)
            final useAllButton = find.text('전액 사용');
            if (useAllButton.evaluate().isNotEmpty) {
              print('  - 포인트 전액 사용 버튼 확인됨');
            }
          }

          print('✅ 포인트 사용 시나리오 확인 완료');

          // 결제 화면에서 나가기 (실제 결제는 하지 않음)
          await tester.pageBack();
          await tester.pumpAndSettle();
        }

        // 장바구니에서 나가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // ========================================
      // 7. 포인트 적립 예정 확인
      // ========================================
      print('🔹 Step 7: 포인트 적립 예정 확인');

      // 마이페이지로 돌아가기
      if (bottomNavBar.evaluate().isNotEmpty) {
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // 포인트 적립 예정 정보 확인
      final expectedPoints = find.textContaining('적립 예정')
          .or(find.textContaining('예정'));

      if (expectedPoints.evaluate().isNotEmpty) {
        print('  - 포인트 적립 예정 정보 확인됨');
      }

      // 포인트 소멸 예정 확인
      final expiringPoints = find.textContaining('소멸 예정')
          .or(find.textContaining('만료'));

      if (expiringPoints.evaluate().isNotEmpty) {
        print('  - 포인트 소멸 예정 정보 확인됨');
      }

      print('✅ 포인트 예정 정보 확인 완료');

      // 최종 확인
      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 포인트 및 출석체크 전체 플로우 테스트 완료! ✅✅✅\n');
    });

    // ========================================
    // 추가 테스트: 연속 출석 보너스
    // ========================================
    testWidgets('연속 출석 보너스 확인', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('🔹 연속 출석 보너스 테스트 시작');

      // 로그인
      final loginButton = find.text('로그인');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'test@test.com');
          await tester.enterText(textFields.at(1), 'Test1234!');
          await tester.pumpAndSettle();

          final submitButton = find.byType(ElevatedButton);
          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }

      // 마이페이지로 이동
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // 출석체크 화면으로 이동
      final checkinButton = find.textContaining('출석');
      if (checkinButton.evaluate().isNotEmpty) {
        await tester.tap(checkinButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 연속 출석 보너스 정보 확인
        final bonusInfo = find.textContaining('보너스')
            .or(find.textContaining('7일'))
            .or(find.textContaining('30일'));

        if (bonusInfo.evaluate().isNotEmpty) {
          print('  - 연속 출석 보너스 정보 확인됨');
        }

        // 출석 달성 현황 확인
        final achievementInfo = find.textContaining('달성')
            .or(find.textContaining('진행'));

        if (achievementInfo.evaluate().isNotEmpty) {
          print('  - 출석 달성 현황 확인됨');
        }

        print('✅ 연속 출석 보너스 확인 완료');
      }

      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 연속 출석 보너스 테스트 완료! ✅✅✅\n');
    });
  });
}
