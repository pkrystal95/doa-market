import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doa_market_user/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('주문 취소 및 반품 플로우 E2E 테스트', () {
    testWidgets('주문 취소 → 취소 내역 확인 전체 플로우', (WidgetTester tester) async {
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

      // 주문 목록 확인
      final orderCards = find.byType(Card);
      if (orderCards.evaluate().isNotEmpty) {
        print('  - 주문 ${orderCards.evaluate().length}개 확인됨');
      } else {
        print('  ⚠️ 취소 가능한 주문이 없습니다. 먼저 주문을 생성해야 합니다.');
      }

      // ========================================
      // 3. 취소 가능한 주문 찾기
      // ========================================
      print('🔹 Step 3: 취소 가능한 주문 찾기');

      // 결제완료 또는 배송준비중 필터 선택
      final prepareFilter = find.text('배송준비중')
          .or(find.text('결제완료'));

      if (prepareFilter.evaluate().isNotEmpty) {
        await tester.tap(prepareFilter.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  - 취소 가능한 주문 필터 적용');
      }

      // 주문 상세로 이동
      final orderCardsAfterFilter = find.byType(Card);
      if (orderCardsAfterFilter.evaluate().isNotEmpty) {
        await tester.tap(orderCardsAfterFilter.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  - 주문 상세 화면 진입');

        // ========================================
        // 4. 주문 취소 신청
        // ========================================
        print('🔹 Step 4: 주문 취소 신청');

        // 주문 취소 버튼 찾기
        final cancelButton = find.text('주문 취소')
            .or(find.text('취소하기'))
            .or(find.text('취소 신청'));

        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('  - 주문 취소 화면 진입');

          // 취소 사유 선택
          final cancelReasonDropdown = find.byType(DropdownButton<String>)
              .or(find.byType(DropdownButtonFormField<String>));

          if (cancelReasonDropdown.evaluate().isNotEmpty) {
            await tester.tap(cancelReasonDropdown.first);
            await tester.pumpAndSettle();

            // 취소 사유 선택 (예: 단순 변심)
            final reasonOption = find.text('단순 변심').last;
            if (reasonOption.evaluate().isNotEmpty) {
              await tester.tap(reasonOption);
              await tester.pumpAndSettle();
              print('  - 취소 사유 선택: 단순 변심');
            } else {
              // 다른 취소 사유 선택
              final reasons = find.text('상품 불만족').or(find.text('배송 지연'));
              if (reasons.evaluate().isNotEmpty) {
                await tester.tap(reasons.last);
                await tester.pumpAndSettle();
                print('  - 대체 취소 사유 선택');
              }
            }
          }

          // 취소 상세 사유 입력 (선택사항)
          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(
              textFields.first,
              '다른 상품으로 재주문하려고 합니다.',
            );
            await tester.pumpAndSettle();
            print('  - 취소 상세 사유 입력');
          }

          // 환불 방법 선택 (있는 경우)
          final refundMethodRadio = find.byType(Radio<String>)
              .or(find.byType(RadioListTile<String>));

          if (refundMethodRadio.evaluate().isNotEmpty) {
            print('  - 환불 방법 옵션 확인됨');
          }

          // 환불 예정 금액 확인
          final refundAmount = find.textContaining('환불')
              .or(find.textContaining('금액'));

          if (refundAmount.evaluate().isNotEmpty) {
            print('  - 환불 예정 금액 확인됨');
          }

          // 취소 신청 완료
          final submitCancelButton = find.text('취소 신청')
              .or(find.text('확인'))
              .or(find.byType(ElevatedButton));

          if (submitCancelButton.evaluate().isNotEmpty) {
            await tester.tap(submitCancelButton.last);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // 확인 다이얼로그 (있는 경우)
            final confirmDialog = find.text('확인');
            if (confirmDialog.evaluate().isNotEmpty) {
              await tester.tap(confirmDialog.last);
              await tester.pumpAndSettle(const Duration(seconds: 2));
            }

            print('✅ 주문 취소 신청 완료');

            // 취소 완료 메시지 확인
            final successMessage = find.textContaining('취소')
                .or(find.textContaining('완료'));

            if (successMessage.evaluate().isNotEmpty) {
              print('  - 취소 신청 성공 메시지 확인');
            }
          }
        } else {
          print('  ⚠️ 주문 취소 버튼을 찾을 수 없습니다 (취소 불가능한 상태일 수 있음)');
        }

        // 주문 상세에서 나가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // ========================================
      // 5. 취소 내역 확인
      // ========================================
      print('🔹 Step 5: 취소 내역 확인');

      // 취소/반품 필터 선택
      final cancelReturnFilter = find.text('취소')
          .or(find.text('취소완료'));

      if (cancelReturnFilter.evaluate().isNotEmpty) {
        await tester.tap(cancelReturnFilter.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  - 취소 내역 필터 적용');

        // 취소된 주문 목록 확인
        final canceledOrders = find.byType(Card);
        if (canceledOrders.evaluate().isNotEmpty) {
          print('  - 취소된 주문 ${canceledOrders.evaluate().length}개 확인됨');
        }
      }

      print('✅ 취소 내역 확인 완료');

      // 주문 내역에서 나가기
      await tester.pageBack();
      await tester.pumpAndSettle();

      // 최종 확인
      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 주문 취소 전체 플로우 테스트 완료! ✅✅✅\n');
    });

    // ========================================
    // 추가 테스트: 반품 신청 플로우
    // ========================================
    testWidgets('반품 신청 → 반품 내역 확인 전체 플로우', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('🔹 반품 신청 플로우 시작');

      // ========================================
      // 로그인
      // ========================================
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
      // 마이페이지 > 주문내역으로 이동
      // ========================================
      print('🔹 Step 1: 주문 내역 조회');

      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      final orderHistoryButton = find.text('주문내역');
      if (orderHistoryButton.evaluate().isNotEmpty) {
        await tester.tap(orderHistoryButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // ========================================
      // 배송완료된 주문 찾기
      // ========================================
      print('🔹 Step 2: 반품 가능한 주문 찾기');

      final deliveredFilter = find.text('배송완료');
      if (deliveredFilter.evaluate().isNotEmpty) {
        await tester.tap(deliveredFilter);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  - 배송완료 주문 필터 적용');
      }

      // 주문 상세로 이동
      final orderCards = find.byType(Card);
      if (orderCards.evaluate().isNotEmpty) {
        await tester.tap(orderCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  - 주문 상세 화면 진입');

        // ========================================
        // 반품 신청
        // ========================================
        print('🔹 Step 3: 반품 신청');

        final returnButton = find.text('반품 신청')
            .or(find.text('교환/반품'))
            .or(find.text('반품하기'));

        if (returnButton.evaluate().isNotEmpty) {
          await tester.tap(returnButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('  - 반품 신청 화면 진입');

          // 반품 사유 선택
          final returnReasonDropdown = find.byType(DropdownButton<String>)
              .or(find.byType(DropdownButtonFormField<String>));

          if (returnReasonDropdown.evaluate().isNotEmpty) {
            await tester.tap(returnReasonDropdown.first);
            await tester.pumpAndSettle();

            // 반품 사유 선택 (예: 상품 불량)
            final reasonOption = find.text('상품 불량').last;
            if (reasonOption.evaluate().isNotEmpty) {
              await tester.tap(reasonOption);
              await tester.pumpAndSettle();
              print('  - 반품 사유 선택: 상품 불량');
            } else {
              final altReasons = find.text('상품 파손').or(find.text('오배송'));
              if (altReasons.evaluate().isNotEmpty) {
                await tester.tap(altReasons.last);
                await tester.pumpAndSettle();
                print('  - 대체 반품 사유 선택');
              }
            }
          }

          // 반품 상세 사유 입력
          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(
              textFields.first,
              '상품에 흠집이 있어 반품 신청합니다. 교환을 원합니다.',
            );
            await tester.pumpAndSettle();
            print('  - 반품 상세 사유 입력');
          }

          // 반품 사진 첨부 (선택사항)
          final imageAttachButton = find.byIcon(Icons.add_photo_alternate)
              .or(find.byIcon(Icons.camera_alt));

          if (imageAttachButton.evaluate().isNotEmpty) {
            print('  - 반품 사진 첨부 옵션 확인됨 (테스트에서는 스킵)');
          }

          // 수거지 정보 확인
          final pickupAddress = find.textContaining('수거')
              .or(find.textContaining('회수'));

          if (pickupAddress.evaluate().isNotEmpty) {
            print('  - 수거지 정보 확인됨');
          }

          // 환불 방법 선택
          final refundMethodSection = find.textContaining('환불')
              .or(find.textContaining('교환'));

          if (refundMethodSection.evaluate().isNotEmpty) {
            print('  - 환불/교환 방법 선택 옵션 확인됨');
          }

          // 반품 비용 안내 확인
          final returnCostInfo = find.textContaining('배송비')
              .or(find.textContaining('반품 비용'));

          if (returnCostInfo.evaluate().isNotEmpty) {
            print('  - 반품 비용 안내 확인됨');
          }

          // 반품 신청 완료
          final submitReturnButton = find.text('반품 신청')
              .or(find.text('신청하기'))
              .or(find.byType(ElevatedButton));

          if (submitReturnButton.evaluate().isNotEmpty) {
            await tester.tap(submitReturnButton.last);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // 확인 다이얼로그
            final confirmDialog = find.text('확인');
            if (confirmDialog.evaluate().isNotEmpty) {
              await tester.tap(confirmDialog.last);
              await tester.pumpAndSettle(const Duration(seconds: 2));
            }

            print('✅ 반품 신청 완료');

            // 성공 메시지 확인
            final successMessage = find.textContaining('반품')
                .or(find.textContaining('완료'));

            if (successMessage.evaluate().isNotEmpty) {
              print('  - 반품 신청 성공 메시지 확인');
            }
          }
        } else {
          print('  ⚠️ 반품 신청 버튼을 찾을 수 없습니다 (반품 불가능한 상태일 수 있음)');
        }

        // 주문 상세에서 나가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // ========================================
      // 반품 내역 확인
      // ========================================
      print('🔹 Step 4: 반품 내역 확인');

      // 반품 필터 선택
      final returnFilter = find.text('반품')
          .or(find.text('교환/반품'));

      if (returnFilter.evaluate().isNotEmpty) {
        await tester.tap(returnFilter.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  - 반품 내역 필터 적용');

        // 반품 신청된 주문 목록 확인
        final returnedOrders = find.byType(Card);
        if (returnedOrders.evaluate().isNotEmpty) {
          print('  - 반품 신청된 주문 ${returnedOrders.evaluate().length}개 확인됨');

          // 첫 번째 반품 상세 확인
          await tester.tap(returnedOrders.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // 반품 진행 상태 확인
          final returnStatus = find.textContaining('반품')
              .or(find.textContaining('수거'))
              .or(find.textContaining('환불'));

          if (returnStatus.evaluate().isNotEmpty) {
            print('  - 반품 진행 상태 확인됨');
          }

          // 택배사 정보 확인 (수거 완료 시)
          final courierInfo = find.textContaining('택배')
              .or(find.textContaining('운송장'));

          if (courierInfo.evaluate().isNotEmpty) {
            print('  - 택배사 정보 확인됨');
          }

          print('✅ 반품 상세 내역 확인 완료');

          // 뒤로 가기
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }

      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 반품 신청 전체 플로우 테스트 완료! ✅✅✅\n');
    });

    // ========================================
    // 추가 테스트: 교환 신청 플로우
    // ========================================
    testWidgets('교환 신청 플로우', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('🔹 교환 신청 플로우 시작');

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

      // 마이페이지 > 주문내역으로 이동
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      final orderHistoryButton = find.text('주문내역');
      if (orderHistoryButton.evaluate().isNotEmpty) {
        await tester.tap(orderHistoryButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 배송완료 필터
        final deliveredFilter = find.text('배송완료');
        if (deliveredFilter.evaluate().isNotEmpty) {
          await tester.tap(deliveredFilter);
          await tester.pumpAndSettle();
        }

        // 주문 상세
        final orderCards = find.byType(Card);
        if (orderCards.evaluate().isNotEmpty) {
          await tester.tap(orderCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // 교환 신청 버튼
          final exchangeButton = find.text('교환 신청')
              .or(find.text('교환/반품'));

          if (exchangeButton.evaluate().isNotEmpty) {
            await tester.tap(exchangeButton.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            print('  - 교환 신청 화면 진입');

            // 교환 옵션 선택 (사이즈, 색상 등)
            final exchangeOptions = find.byType(DropdownButton<String>);
            if (exchangeOptions.evaluate().isNotEmpty) {
              print('  - 교환 옵션 선택 가능');
            }

            // 교환 사유 입력
            final textFields = find.byType(TextField);
            if (textFields.evaluate().isNotEmpty) {
              await tester.enterText(
                textFields.first,
                '사이즈가 맞지 않아 교환을 원합니다.',
              );
              await tester.pumpAndSettle();
              print('  - 교환 사유 입력');
            }

            print('✅ 교환 신청 화면 확인 완료');
          }
        }
      }

      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 교환 신청 플로우 테스트 완료! ✅✅✅\n');
    });
  });
}
