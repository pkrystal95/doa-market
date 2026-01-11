import 'package:flutter/foundation.dart';
import '../models/inquiry.dart';
import '../services/api_service.dart';

class InquiryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Inquiry> _inquiries = [];
  Inquiry? _currentInquiry;
  bool _isLoading = false;
  String? _error;

  List<Inquiry> get inquiries => _inquiries;
  Inquiry? get currentInquiry => _currentInquiry;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendingCount =>
      _inquiries.where((i) => i.status == 'pending').length;
  int get answeredCount =>
      _inquiries.where((i) => i.status == 'answered').length;

  /// 문의 목록 조회
  Future<void> fetchInquiries(String userId, {int page = 1}) async {
    if (page == 1) {
      _inquiries = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getInquiries(
        userId,
        page: page,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final inquiries = data.map((json) => Inquiry.fromJson(json)).toList();

        if (page == 1) {
          _inquiries = inquiries;
        } else {
          _inquiries.addAll(inquiries);
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching inquiries: $e');

      // 개발 중: 목 데이터 사용
      if (page == 1) {
        _inquiries = _getMockInquiries(userId);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 문의 상세 조회
  Future<void> fetchInquiry(String userId, String inquiryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getInquiry(userId, inquiryId);

      if (response['success'] == true) {
        _currentInquiry = Inquiry.fromJson(response['data'] ?? {});
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching inquiry: $e');

      // 개발 중: 목 데이터 사용
      _currentInquiry = _inquiries.firstWhere(
        (i) => i.id == inquiryId,
        orElse: () => _getMockInquiries(userId).first,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 문의 작성
  Future<bool> createInquiry({
    required String userId,
    required String title,
    required String content,
    required String category,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _apiService.createInquiry(
        userId: userId,
        title: title,
        content: content,
        category: category,
        imageUrls: imageUrls,
      );

      if (response['success'] == true) {
        // 문의 목록 갱신
        await fetchInquiries(userId);
        return true;
      }
      // If success is false, throw error with message from response
      throw Exception(response['message'] ?? '문의 등록에 실패했습니다');
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating inquiry: $e');
      rethrow; // Re-throw to show error message in UI
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 현재 문의 초기화
  void clearCurrentInquiry() {
    _currentInquiry = null;
    notifyListeners();
  }

  /// 목 데이터 (개발 중)
  List<Inquiry> _getMockInquiries(String userId) {
    final now = DateTime.now();
    return [
      Inquiry(
        id: '1',
        userId: userId,
        title: '배송이 지연되고 있어요',
        content: '''
주문번호: ORD-20231217-001

배송 예정일이 지났는데 아직 배송이 안 왔어요.
언제쯤 받을 수 있을까요?
''',
        category: 'delivery',
        status: 'answered',
        createdAt: now.subtract(const Duration(days: 2)),
        reply: InquiryReply(
          id: 'reply1',
          inquiryId: '1',
          content: '''
안녕하세요, 고객님.

확인 결과 일부 지역의 기상 악화로 인해 배송이 지연되고 있습니다.
오늘 중으로 발송될 예정이며, 내일 오전 중 수령하실 수 있습니다.

불편을 드려 죄송합니다.
감사합니다.
''',
          adminName: '김관리',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ),
      Inquiry(
        id: '2',
        userId: userId,
        title: '상품이 설명과 달라요',
        content: '''
주문번호: ORD-20231216-002

상품 설명에는 블루 색상이라고 했는데
실제로는 그린 색상이 왔어요.

교환 가능한가요?
''',
        category: 'product',
        status: 'answered',
        createdAt: now.subtract(const Duration(days: 5)),
        reply: InquiryReply(
          id: 'reply2',
          inquiryId: '2',
          content: '''
안녕하세요, 고객님.

상품 설명과 다른 색상이 배송된 점 죄송합니다.
교환 또는 환불 처리 도와드리겠습니다.

마이페이지 > 주문내역에서 교환 신청을 해주시면
빠르게 처리해드리겠습니다.

감사합니다.
''',
          adminName: '이관리',
          createdAt: now.subtract(const Duration(days: 4)),
        ),
      ),
      Inquiry(
        id: '3',
        userId: userId,
        title: '포인트가 적립되지 않았어요',
        content: '''
주문번호: ORD-20231210-003

상품을 구매했는데 포인트가 적립되지 않았습니다.
확인 부탁드립니다.
''',
        category: 'payment',
        status: 'pending',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Inquiry(
        id: '4',
        userId: userId,
        title: '회원 탈퇴 문의',
        content: '''
회원 탈퇴를 하고 싶은데 어떻게 하나요?
탈퇴 시 포인트는 어떻게 되나요?
''',
        category: 'etc',
        status: 'answered',
        createdAt: now.subtract(const Duration(days: 10)),
        reply: InquiryReply(
          id: 'reply3',
          inquiryId: '4',
          content: '''
안녕하세요, 고객님.

회원 탈퇴는 마이페이지 > 설정 > 회원정보 수정에서 가능합니다.
탈퇴 시 보유 포인트는 모두 소멸되며, 복구가 불가능합니다.

탈퇴 전 포인트를 모두 사용하시는 것을 권장드립니다.

감사합니다.
''',
          adminName: '박관리',
          createdAt: now.subtract(const Duration(days: 9)),
        ),
      ),
    ];
  }
}
