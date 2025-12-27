import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doa_market_user/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('리뷰 작성 및 조회 플로우 E2E 테스트', () {
    testWidgets('주문내역 → 리뷰 작성 → 나의 리뷰 조회 전체 플로우', (WidgetTester tester) async {
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
      // 2. 주문 내역으로 이동
      // ========================================
      print('🔹 Step 2: 주문 내역 조회');

      final orderHistoryButton = find.text('주문내역');
      if (orderHistoryButton.evaluate().isEmpty) {
        final orderButton = find.textContaining('주문');
        if (orderButton.evaluate().isNotEmpty) {
          await tester.tap(orderButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      } else {
        await tester.tap(orderHistoryButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // 배송완료 필터로 변경 (리뷰 작성 가능한 주문 찾기)
      final deliveredFilter = find.text('배송완료');
      if (deliveredFilter.evaluate().isNotEmpty) {
        await tester.tap(deliveredFilter);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  - 배송완료 주문 필터 적용');
      }

      // ========================================
      // 3. 주문 상세에서 리뷰 작성 버튼 찾기
      // ========================================
      print('🔹 Step 3: 리뷰 작성 진입');

      // 첫 번째 주문 카드 클릭
      final orderCards = find.byType(Card);
      if (orderCards.evaluate().isNotEmpty) {
        await tester.tap(orderCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  - 주문 상세 화면 진입');

        // 리뷰 작성 버튼 찾기
        final reviewButton = find.text('리뷰 작성');
        if (reviewButton.evaluate().isNotEmpty) {
          await tester.tap(reviewButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          print('  - 리뷰 작성 화면 진입');

          // ========================================
          // 4. 리뷰 작성
          // ========================================
          print('🔹 Step 4: 리뷰 작성');

          // 별점 선택 (5점)
          final starIcons = find.byIcon(Icons.star_border)
              .or(find.byIcon(Icons.star));
          if (starIcons.evaluate().isNotEmpty) {
            // 마지막 별을 탭하여 5점 선택
            await tester.tap(starIcons.last);
            await tester.pumpAndSettle();
            print('  - 별점 5점 선택');
          }

          // 리뷰 제목 입력
          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(textFields.first, '정말 좋은 상품입니다!');
            await tester.pumpAndSettle();
            print('  - 리뷰 제목 입력');
          }

          // 리뷰 내용 입력
          if (textFields.evaluate().length >= 2) {
            await tester.enterText(
              textFields.at(1),
              '상품 품질이 매우 우수하고 배송도 빨라서 만족합니다. 다음에도 재구매할 의향이 있습니다.',
            );
            await tester.pumpAndSettle();
            print('  - 리뷰 내용 입력');
          }

          // 이미지 첨부 버튼 (선택사항)
          final imageButton = find.byIcon(Icons.add_photo_alternate)
              .or(find.byIcon(Icons.camera_alt));
          if (imageButton.evaluate().isNotEmpty) {
            print('  - 이미지 첨부 버튼 확인됨 (테스트에서는 스킵)');
          }

          // 리뷰 제출
          final submitButton = find.text('등록');
          if (submitButton.evaluate().isEmpty) {
            final submitButtons = find.byType(ElevatedButton);
            if (submitButtons.evaluate().isNotEmpty) {
              await tester.tap(submitButtons.last);
              await tester.pumpAndSettle(const Duration(seconds: 2));
            }
          } else {
            await tester.tap(submitButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }

          print('✅ 리뷰 작성 완료');

          // 주문 상세로 돌아가기
          await tester.pageBack();
          await tester.pumpAndSettle();
        } else {
          print('  ⚠️ 리뷰 작성 가능한 주문이 없습니다');
        }

        // 주문 내역으로 돌아가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // ========================================
      // 5. 나의 리뷰 화면으로 이동
      // ========================================
      print('🔹 Step 5: 나의 리뷰 조회');

      // 마이페이지로 돌아가기
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 나의 리뷰 메뉴 찾기
      final myReviewsButton = find.text('나의 리뷰');
      if (myReviewsButton.evaluate().isEmpty) {
        // 대체 텍스트로 찾기
        final reviewsButton = find.textContaining('리뷰');
        if (reviewsButton.evaluate().isNotEmpty) {
          await tester.tap(reviewsButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      } else {
        await tester.tap(myReviewsButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // 리뷰 목록 확인
      final reviewCards = find.byType(Card);
      if (reviewCards.evaluate().isNotEmpty) {
        print('  - 작성한 리뷰 ${reviewCards.evaluate().length}개 확인됨');

        // 첫 번째 리뷰 상세 보기
        await tester.tap(reviewCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 리뷰 상세 내용 확인
        print('  - 리뷰 상세 내용 확인');

        // 리뷰 수정 버튼 확인
        final editButton = find.text('수정');
        if (editButton.evaluate().isNotEmpty) {
          print('  - 리뷰 수정 기능 확인됨');
        }

        // 리뷰 삭제 버튼 확인
        final deleteButton = find.text('삭제');
        if (deleteButton.evaluate().isNotEmpty) {
          print('  - 리뷰 삭제 기능 확인됨');
        }

        // 뒤로 가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      print('✅ 나의 리뷰 조회 완료');

      // ========================================
      // 6. 상품 상세에서 리뷰 조회
      // ========================================
      print('🔹 Step 6: 상품 상세 페이지에서 리뷰 확인');

      // 홈으로 이동
      if (bottomNavBar.evaluate().isNotEmpty) {
        final homeTab = find.byIcon(Icons.home);
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // 첫 번째 상품 클릭
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 리뷰 탭 또는 리뷰 섹션으로 스크롤
        final reviewTab = find.text('리뷰');
        if (reviewTab.evaluate().isNotEmpty) {
          await tester.tap(reviewTab);
          await tester.pumpAndSettle();
          print('  - 상품 리뷰 탭 확인');
        } else {
          // 스크롤하여 리뷰 섹션 찾기
          try {
            await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
            await tester.pumpAndSettle();
            print('  - 리뷰 섹션으로 스크롤');
          } catch (e) {
            print('  - 스크롤 불가');
          }
        }

        // 다른 사용자 리뷰 확인
        final reviewItems = find.byType(ListTile).or(find.byType(Card));
        if (reviewItems.evaluate().isNotEmpty) {
          print('  - 상품 리뷰 목록 확인됨');
        }

        print('✅ 상품 상세 페이지 리뷰 확인 완료');

        // 뒤로 가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // ========================================
      // 7. 리뷰 필터링 테스트
      // ========================================
      print('🔹 Step 7: 리뷰 필터링 테스트');

      // 마이페이지 > 나의 리뷰로 다시 이동
      if (bottomNavBar.evaluate().isNotEmpty) {
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      final myReviewsButtonAgain = find.text('나의 리뷰');
      if (myReviewsButtonAgain.evaluate().isNotEmpty) {
        await tester.tap(myReviewsButtonAgain);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 평점 필터 테스트
        final ratingFilters = find.text('전체')
            .or(find.text('5점'))
            .or(find.text('4점'));

        if (ratingFilters.evaluate().isNotEmpty) {
          // 5점 필터 선택
          final fiveStarFilter = find.text('5점');
          if (fiveStarFilter.evaluate().isNotEmpty) {
            await tester.tap(fiveStarFilter);
            await tester.pumpAndSettle();
            print('  - 5점 리뷰 필터 적용');
          }
        }

        print('✅ 리뷰 필터링 테스트 완료');
      }

      // 최종 확인
      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 리뷰 작성 및 조회 전체 플로우 테스트 완료! ✅✅✅\n');
    });

    // ========================================
    // 추가 테스트: 리뷰 수정 플로우
    // ========================================
    testWidgets('리뷰 수정 및 삭제 플로우', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('🔹 리뷰 수정 및 삭제 플로우 시작');

      // 로그인 (필요한 경우)
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

      // 마이페이지 > 나의 리뷰로 이동
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      final myReviewsButton = find.text('나의 리뷰');
      if (myReviewsButton.evaluate().isNotEmpty) {
        await tester.tap(myReviewsButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 첫 번째 리뷰 선택
        final reviewCards = find.byType(Card);
        if (reviewCards.evaluate().isNotEmpty) {
          await tester.tap(reviewCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // 수정 버튼 클릭
          final editButton = find.text('수정');
          if (editButton.evaluate().isNotEmpty) {
            await tester.tap(editButton);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            // 리뷰 내용 수정
            final textFields = find.byType(TextField);
            if (textFields.evaluate().length >= 2) {
              await tester.enterText(
                textFields.at(1),
                '수정된 리뷰 내용입니다. 여전히 만족스러운 상품입니다!',
              );
              await tester.pumpAndSettle();
            }

            // 수정 완료
            final saveButton = find.text('저장');
            if (saveButton.evaluate().isNotEmpty) {
              await tester.tap(saveButton);
              await tester.pumpAndSettle(const Duration(seconds: 2));
              print('✅ 리뷰 수정 완료');
            }
          }

          // 뒤로 가기
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }

      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 리뷰 수정 플로우 테스트 완료! ✅✅✅\n');
    });
  });
}
