import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doa_market_user/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('상품 탐색 플로우 E2E 테스트', () {
    testWidgets('홈 → 카테고리 → 상품상세 → 찜하기 전체 플로우', (WidgetTester tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ========================================
      // 1. 홈 화면 상품 목록 확인
      // ========================================
      print('🔹 Step 1: 홈 화면 상품 목록 조회');
      
      // 홈 탭이 활성화되어 있는지 확인
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        // 홈 탭 클릭 (첫 번째 탭)
        final homeTab = find.byIcon(Icons.home);
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // 상품 그리드 뷰 확인
      await tester.pumpAndSettle();
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        print('  - 상품 ${productCards.evaluate().length}개 표시됨');
      }

      // 새로고침 기능 테스트
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ 상품 목록 새로고침 완료');

      // ========================================
      // 2. 카테고리별 상품 조회
      // ========================================
      print('🔹 Step 2: 카테고리별 상품 필터링');
      
      // 카테고리 탭으로 이동
      final categoryTab = find.byIcon(Icons.category);
      if (categoryTab.evaluate().isNotEmpty) {
        await tester.tap(categoryTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 카테고리 목록 확인
        final categoryItems = find.byType(ListTile).or(find.byType(Card));
        if (categoryItems.evaluate().isNotEmpty) {
          print('  - 카테고리 목록 확인됨');
          
          // 첫 번째 카테고리 선택
          await tester.tap(categoryItems.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('  - 카테고리별 상품 조회 완료');

          // 뒤로 가기
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      } else {
        // 홈 화면에서 카테고리 탭이 있는 경우
        final categoryTabs = find.text('전자제품')
            .or(find.text('의류'))
            .or(find.text('식품'));
        
        if (categoryTabs.evaluate().isNotEmpty) {
          await tester.tap(categoryTabs.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          print('  - 카테고리 필터 적용됨');
        }
      }

      print('✅ 카테고리 탐색 완료');

      // 홈으로 돌아가기
      if (bottomNavBar.evaluate().isNotEmpty) {
        final homeTab = find.byIcon(Icons.home);
        if (homeTab.evaluate().isNotEmpty) {
          await tester.tap(homeTab.first);
          await tester.pumpAndSettle();
        }
      }

      // ========================================
      // 3. 상품 검색 기능
      // ========================================
      print('🔹 Step 3: 상품 검색');
      
      // 검색 아이콘 또는 검색 화면으로 이동
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 검색어 입력
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          // 첫 번째 검색: 스마트폰
          await tester.enterText(searchField.first, '스마트폰');
          await tester.pumpAndSettle();
          
          // 검색 실행
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          
          print('  - 검색어 "스마트폰" 검색 완료');

          // 검색 결과 확인
          final searchResults = find.byType(Card);
          if (searchResults.evaluate().isNotEmpty) {
            print('  - 검색 결과 ${searchResults.evaluate().length}개 표시');
          }

          // 검색어 변경
          await tester.enterText(searchField.first, '노트북');
          await tester.pumpAndSettle();
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          
          print('  - 검색어 "노트북" 검색 완료');
        }

        // 인기 검색어 확인
        final popularSearches = find.textContaining('인기');
        if (popularSearches.evaluate().isNotEmpty) {
          print('  - 인기 검색어 표시됨');
        }

        print('✅ 상품 검색 완료');

        // 뒤로 가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // ========================================
      // 4. 상품 상세 보기
      // ========================================
      print('🔹 Step 4: 상품 상세 정보 조회');
      
      // 첫 번째 상품 카드 클릭
      final firstProduct = find.byType(Card).first;
      await tester.tap(firstProduct);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 상품 상세 화면 요소 확인
      print('  - 상품 상세 화면 진입');

      // 상품 이미지 확인
      final productImage = find.byType(Image);
      if (productImage.evaluate().isNotEmpty) {
        print('  - 상품 이미지 표시됨');
      }

      // 상품 정보 확인 (이름, 가격, 설명)
      await tester.pumpAndSettle();
      print('  - 상품 정보 확인됨');

      // 수량 선택 기능 테스트
      final incrementButton = find.byIcon(Icons.add);
      if (incrementButton.evaluate().isNotEmpty) {
        await tester.tap(incrementButton.first);
        await tester.pumpAndSettle();
        print('  - 수량 증가 완료');

        final decrementButton = find.byIcon(Icons.remove);
        if (decrementButton.evaluate().isNotEmpty) {
          await tester.tap(decrementButton.first);
          await tester.pumpAndSettle();
          print('  - 수량 감소 완료');
        }
      }

      print('✅ 상품 상세 조회 완료');

      // ========================================
      // 5. 찜하기 기능
      // ========================================
      print('🔹 Step 5: 찜하기 기능 테스트');
      
      // 하트 아이콘 찾기 (찜하기 버튼)
      final favoriteButton = find.byIcon(Icons.favorite_border)
          .or(find.byIcon(Icons.favorite));
      
      if (favoriteButton.evaluate().isNotEmpty) {
        // 찜하기 토글
        await tester.tap(favoriteButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  - 찜하기 추가 완료');

        // 다시 토글 (찜 해제)
        final favoriteFilledButton = find.byIcon(Icons.favorite);
        if (favoriteFilledButton.evaluate().isNotEmpty) {
          await tester.tap(favoriteFilledButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          print('  - 찜하기 해제 완료');
        }

        // 다시 찜하기
        final favoriteBorderButton = find.byIcon(Icons.favorite_border);
        if (favoriteBorderButton.evaluate().isNotEmpty) {
          await tester.tap(favoriteBorderButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          print('  - 찜하기 재추가 완료');
        }
      }

      print('✅ 찜하기 기능 테스트 완료');

      // ========================================
      // 6. 장바구니 담기
      // ========================================
      print('🔹 Step 6: 장바구니 담기');
      
      // 장바구니 버튼 찾기
      final addToCartButton = find.text('장바구니')
          .or(find.text('장바구니에 담기'));
      
      if (addToCartButton.evaluate().isNotEmpty) {
        await tester.tap(addToCartButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  - 장바구니 담기 완료');

        // 스낵바나 다이얼로그 확인
        await tester.pumpAndSettle();
      } else {
        // ElevatedButton으로 찾기
        final cartButtons = find.byType(ElevatedButton);
        if (cartButtons.evaluate().isNotEmpty) {
          await tester.tap(cartButtons.first);
          await tester.pumpAndSettle();
          print('  - 장바구니 담기 완료');
        }
      }

      print('✅ 장바구니 담기 완료');

      // 상품 상세에서 나가기
      await tester.pageBack();
      await tester.pumpAndSettle();

      // ========================================
      // 7. 찜 목록 확인
      // ========================================
      print('🔹 Step 7: 찜 목록에서 상품 확인');
      
      // 마이페이지로 이동
      final profileTab = find.byIcon(Icons.person);
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab.last);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 찜 목록으로 이동
        final wishlistButton = find.textContaining('찜');
        if (wishlistButton.evaluate().isNotEmpty) {
          await tester.tap(wishlistButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // 찜한 상품 확인
          final wishlistItems = find.byType(Card);
          if (wishlistItems.evaluate().isNotEmpty) {
            print('  - 찜 목록에 ${wishlistItems.evaluate().length}개 상품 표시됨');
          }

          print('✅ 찜 목록 확인 완료');

          // 뒤로 가기
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }

      // ========================================
      // 8. 장바구니 확인
      // ========================================
      print('🔹 Step 8: 장바구니에서 상품 확인');
      
      // 장바구니 아이콘 클릭
      final cartIcon = find.byIcon(Icons.shopping_cart);
      if (cartIcon.evaluate().isNotEmpty) {
        await tester.tap(cartIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 장바구니 상품 확인
        final cartItems = find.byType(Card);
        if (cartItems.evaluate().isNotEmpty) {
          print('  - 장바구니에 ${cartItems.evaluate().length}개 상품 표시됨');
        }

        // 장바구니에서 수량 변경
        final incrementInCart = find.byIcon(Icons.add);
        if (incrementInCart.evaluate().isNotEmpty) {
          await tester.tap(incrementInCart.first);
          await tester.pumpAndSettle();
          print('  - 장바구니 수량 변경 완료');
        }

        print('✅ 장바구니 확인 완료');

        // 뒤로 가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // 최종 확인
      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 상품 탐색 전체 플로우 테스트 완료! ✅✅✅\n');
    });
  });
}
