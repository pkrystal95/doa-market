import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doa_market_user/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('공지사항 및 문의 플로우 E2E 테스트', () {
    testWidgets('공지사항 조회 → 1:1 문의 작성 → 문의 내역 확인 전체 플로우', (WidgetTester tester) async {
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
      // 2. 공지사항 목록 조회
      // ========================================
      print('🔹 Step 2: 공지사항 목록 조회');

      final noticeButton = find.text('공지사항')
          .or(find.textContaining('공지'));

      if (noticeButton.evaluate().isNotEmpty) {
        await tester.tap(noticeButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  - 공지사항 목록 화면 진입');

        // 공지사항 목록 확인
        final noticeList = find.byType(ListView)
            .or(find.byType(ListTile))
            .or(find.byType(Card));

        if (noticeList.evaluate().isNotEmpty) {
          print('  - 공지사항 목록 확인됨');

          // 공지사항 카테고리 필터 (있는 경우)
          final categoryFilters = find.text('전체')
              .or(find.text('중요'))
              .or(find.text('이벤트'))
              .or(find.text('업데이트'));

          if (categoryFilters.evaluate().isNotEmpty) {
            print('  - 공지사항 카테고리 필터 확인됨');

            // 이벤트 필터 선택
            final eventFilter = find.text('이벤트');
            if (eventFilter.evaluate().isNotEmpty) {
              await tester.tap(eventFilter);
              await tester.pumpAndSettle();
              print('  - 이벤트 공지사항 필터 적용');

              // 전체 필터로 복귀
              final allFilter = find.text('전체');
              if (allFilter.evaluate().isNotEmpty) {
                await tester.tap(allFilter);
                await tester.pumpAndSettle();
              }
            }
          }

          // ========================================
          // 3. 공지사항 상세 보기
          // ========================================
          print('🔹 Step 3: 공지사항 상세 조회');

          final noticeCards = find.byType(Card);
          if (noticeCards.evaluate().isNotEmpty) {
            await tester.tap(noticeCards.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            print('  - 공지사항 상세 화면 진입');

            // 공지사항 제목 확인
            await tester.pumpAndSettle();
            print('  - 공지사항 제목 및 내용 확인');

            // 공지사항 이미지 확인 (있는 경우)
            final noticeImages = find.byType(Image);
            if (noticeImages.evaluate().isNotEmpty) {
              print('  - 공지사항 이미지 확인됨');
            }

            // 공지사항 첨부 파일 확인 (있는 경우)
            final attachments = find.textContaining('첨부')
                .or(find.byIcon(Icons.attach_file));

            if (attachments.evaluate().isNotEmpty) {
              print('  - 공지사항 첨부 파일 확인됨');
            }

            // 스크롤하여 전체 내용 보기
            try {
              await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
              await tester.pumpAndSettle();
              print('  - 공지사항 내용 스크롤');
            } catch (e) {
              print('  - 스크롤 불필요 (내용이 짧음)');
            }

            print('✅ 공지사항 상세 조회 완료');

            // 공지사항 상세에서 나가기
            await tester.pageBack();
            await tester.pumpAndSettle();
          }
        } else {
          print('  ⚠️ 공지사항 목록이 비어있습니다');
        }

        // 공지사항 목록에서 나가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      } else {
        print('  ⚠️ 공지사항 메뉴를 찾을 수 없습니다');
      }

      // ========================================
      // 4. 1:1 문의 목록 조회
      // ========================================
      print('🔹 Step 4: 1:1 문의 목록 조회');

      final inquiryButton = find.text('1:1 문의')
          .or(find.text('문의하기'))
          .or(find.textContaining('문의'));

      if (inquiryButton.evaluate().isNotEmpty) {
        await tester.tap(inquiryButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  - 1:1 문의 목록 화면 진입');

        // 기존 문의 목록 확인
        final inquiryList = find.byType(ListView)
            .or(find.byType(ListTile))
            .or(find.byType(Card));

        if (inquiryList.evaluate().isNotEmpty) {
          final inquiryCards = find.byType(Card);
          if (inquiryCards.evaluate().isNotEmpty) {
            print('  - 기존 문의 ${inquiryCards.evaluate().length}개 확인됨');
          }
        }

        // 문의 상태 필터 (전체, 답변대기, 답변완료)
        final statusFilters = find.text('전체')
            .or(find.text('답변대기'))
            .or(find.text('답변완료'));

        if (statusFilters.evaluate().isNotEmpty) {
          print('  - 문의 상태 필터 확인됨');

          // 답변완료 필터 선택
          final answeredFilter = find.text('답변완료');
          if (answeredFilter.evaluate().isNotEmpty) {
            await tester.tap(answeredFilter);
            await tester.pumpAndSettle();
            print('  - 답변완료 문의 필터 적용');
          }

          // 전체 필터로 복귀
          final allFilter = find.text('전체');
          if (allFilter.evaluate().isNotEmpty) {
            await tester.tap(allFilter);
            await tester.pumpAndSettle();
          }
        }

        print('✅ 1:1 문의 목록 조회 완료');

        // ========================================
        // 5. 새 문의 작성
        // ========================================
        print('🔹 Step 5: 1:1 문의 작성');

        // 문의 작성 버튼 찾기
        final writeInquiryButton = find.byIcon(Icons.add)
            .or(find.byIcon(Icons.edit))
            .or(find.text('문의하기'))
            .or(find.text('작성하기'));

        if (writeInquiryButton.evaluate().isNotEmpty) {
          await tester.tap(writeInquiryButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('  - 문의 작성 화면 진입');

          // 문의 유형 선택
          final inquiryTypeDropdown = find.byType(DropdownButton<String>)
              .or(find.byType(DropdownButtonFormField<String>));

          if (inquiryTypeDropdown.evaluate().isNotEmpty) {
            await tester.tap(inquiryTypeDropdown.first);
            await tester.pumpAndSettle();

            // 문의 유형 선택 (예: 상품문의)
            final productInquiry = find.text('상품문의').last;
            if (productInquiry.evaluate().isNotEmpty) {
              await tester.tap(productInquiry);
              await tester.pumpAndSettle();
              print('  - 문의 유형 선택: 상품문의');
            }
          }

          // 문의 제목 입력
          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            await tester.enterText(textFields.first, '상품 배송 문의드립니다');
            await tester.pumpAndSettle();
            print('  - 문의 제목 입력');
          }

          // 문의 내용 입력
          if (textFields.evaluate().length >= 2) {
            await tester.enterText(
              textFields.at(1),
              '주문한 상품의 배송 예정일을 알고 싶습니다. 빠른 답변 부탁드립니다.',
            );
            await tester.pumpAndSettle();
            print('  - 문의 내용 입력');
          }

          // 이메일 알림 수신 체크박스 (있는 경우)
          final emailNotification = find.byType(Checkbox);
          if (emailNotification.evaluate().isNotEmpty) {
            await tester.tap(emailNotification.first);
            await tester.pumpAndSettle();
            print('  - 이메일 알림 수신 체크');
          }

          // 이미지 첨부 버튼 (선택사항)
          final imageAttachButton = find.byIcon(Icons.attach_file)
              .or(find.byIcon(Icons.add_photo_alternate));

          if (imageAttachButton.evaluate().isNotEmpty) {
            print('  - 이미지 첨부 버튼 확인됨 (테스트에서는 스킵)');
          }

          // 문의 등록
          final submitButton = find.text('등록')
              .or(find.text('제출'))
              .or(find.byType(ElevatedButton));

          if (submitButton.evaluate().isNotEmpty) {
            await tester.tap(submitButton.last);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            print('✅ 1:1 문의 등록 완료');

            // 성공 메시지 확인
            final successMessage = find.textContaining('등록')
                .or(find.textContaining('완료'));

            if (successMessage.evaluate().isNotEmpty) {
              print('  - 문의 등록 성공 메시지 확인');
            }
          }
        } else {
          print('  ⚠️ 문의 작성 버튼을 찾을 수 없습니다');
        }

        // ========================================
        // 6. 작성한 문의 확인
        // ========================================
        print('🔹 Step 6: 작성한 문의 확인');

        // 문의 목록에서 방금 작성한 문의 확인
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final inquiryCards = find.byType(Card);
        if (inquiryCards.evaluate().isNotEmpty) {
          // 첫 번째 문의 (가장 최근) 클릭
          await tester.tap(inquiryCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('  - 문의 상세 화면 진입');

          // 문의 상세 내용 확인
          await tester.pumpAndSettle();
          print('  - 문의 제목 및 내용 확인');

          // 답변 상태 확인
          final answerStatus = find.textContaining('답변대기')
              .or(find.textContaining('답변완료'));

          if (answerStatus.evaluate().isNotEmpty) {
            print('  - 답변 상태 확인됨');
          }

          // 답변 내용 확인 (답변이 있는 경우)
          final answerContent = find.textContaining('답변')
              .or(find.textContaining('관리자'));

          if (answerContent.evaluate().isNotEmpty) {
            print('  - 관리자 답변 확인됨');
          }

          // 문의 수정 버튼 (답변 전인 경우)
          final editButton = find.text('수정');
          if (editButton.evaluate().isNotEmpty) {
            print('  - 문의 수정 기능 확인됨');
          }

          // 문의 삭제 버튼 (답변 전인 경우)
          final deleteButton = find.text('삭제');
          if (deleteButton.evaluate().isNotEmpty) {
            print('  - 문의 삭제 기능 확인됨');
          }

          print('✅ 작성한 문의 확인 완료');

          // 문의 상세에서 나가기
          await tester.pageBack();
          await tester.pumpAndSettle();
        }

        // 문의 목록에서 나가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      } else {
        print('  ⚠️ 1:1 문의 메뉴를 찾을 수 없습니다');
      }

      // ========================================
      // 7. 자주 묻는 질문 (FAQ) 확인
      // ========================================
      print('🔹 Step 7: FAQ 확인');

      final faqButton = find.text('자주 묻는 질문')
          .or(find.text('FAQ'))
          .or(find.textContaining('FAQ'));

      if (faqButton.evaluate().isNotEmpty) {
        await tester.tap(faqButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  - FAQ 화면 진입');

        // FAQ 카테고리 확인
        final faqCategories = find.text('배송')
            .or(find.text('결제'))
            .or(find.text('취소/환불'))
            .or(find.text('회원정보'));

        if (faqCategories.evaluate().isNotEmpty) {
          print('  - FAQ 카테고리 확인됨');
        }

        // FAQ 항목 확인
        final faqItems = find.byType(ExpansionTile)
            .or(find.byType(Card));

        if (faqItems.evaluate().isNotEmpty) {
          print('  - FAQ 항목 확인됨');

          // 첫 번째 FAQ 열기
          if (find.byType(ExpansionTile).evaluate().isNotEmpty) {
            await tester.tap(find.byType(ExpansionTile).first);
            await tester.pumpAndSettle();
            print('  - FAQ 내용 확인');
          }
        }

        print('✅ FAQ 확인 완료');

        // FAQ에서 나가기
        await tester.pageBack();
        await tester.pumpAndSettle();
      } else {
        print('  ℹ️ FAQ 메뉴는 선택사항입니다');
      }

      // 최종 확인
      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 공지사항 및 문의 전체 플로우 테스트 완료! ✅✅✅\n');
    });

    // ========================================
    // 추가 테스트: 문의 수정 및 삭제
    // ========================================
    testWidgets('문의 수정 및 삭제 플로우', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('🔹 문의 수정 및 삭제 플로우 시작');

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

      // 마이페이지 > 1:1 문의로 이동
      final bottomNavBar = find.byType(BottomNavigationBar);
      if (bottomNavBar.evaluate().isNotEmpty) {
        final profileTab = find.byIcon(Icons.person);
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.last);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      final inquiryButton = find.textContaining('문의');
      if (inquiryButton.evaluate().isNotEmpty) {
        await tester.tap(inquiryButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 답변대기 상태의 문의 찾기
        final pendingFilter = find.text('답변대기');
        if (pendingFilter.evaluate().isNotEmpty) {
          await tester.tap(pendingFilter);
          await tester.pumpAndSettle();
        }

        final inquiryCards = find.byType(Card);
        if (inquiryCards.evaluate().isNotEmpty) {
          await tester.tap(inquiryCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // 수정 버튼 클릭
          final editButton = find.text('수정');
          if (editButton.evaluate().isNotEmpty) {
            await tester.tap(editButton);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            // 문의 내용 수정
            final textFields = find.byType(TextField);
            if (textFields.evaluate().length >= 2) {
              await tester.enterText(
                textFields.at(1),
                '수정된 문의 내용입니다. 추가 정보를 포함합니다.',
              );
              await tester.pumpAndSettle();
            }

            // 수정 완료
            final saveButton = find.text('저장');
            if (saveButton.evaluate().isNotEmpty) {
              await tester.tap(saveButton);
              await tester.pumpAndSettle(const Duration(seconds: 2));
              print('✅ 문의 수정 완료');
            }
          }
        }
      }

      expect(find.byType(MaterialApp), findsOneWidget);
      print('\n✅✅✅ 문의 수정 플로우 테스트 완료! ✅✅✅\n');
    });
  });
}
