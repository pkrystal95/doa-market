import 'package:flutter/foundation.dart';
import '../models/notice.dart';
import '../services/api_service.dart';

class NoticeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Notice> _notices = [];
  List<Notice> _pinnedNotices = [];
  List<Notice> _urgentNotices = [];
  Notice? _currentNotice;
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  String? _selectedPriority;

  List<Notice> get notices => _notices;
  List<Notice> get pinnedNotices => _pinnedNotices;
  List<Notice> get urgentNotices => _urgentNotices;
  Notice? get currentNotice => _currentNotice;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  String? get selectedPriority => _selectedPriority;

  /// 공지사항 목록 조회
  Future<void> fetchNotices({int page = 1, String? category, String? priority}) async {
    if (page == 1) {
      _notices = [];
    }

    _isLoading = true;
    _error = null;
    _selectedCategory = category;
    _selectedPriority = priority;
    notifyListeners();

    try {
      final response = await _apiService.getNotices(
        page: page,
        limit: 20,
        category: category,
        priority: priority,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final notices = data.map((json) => Notice.fromJson(json)).toList();

        if (page == 1) {
          _notices = notices;
          _pinnedNotices = notices.where((n) => n.isPinned).toList();
          _urgentNotices = notices.where((n) => n.isUrgent).toList();
        } else {
          _notices.addAll(notices);
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching notices: $e');

      // 개발 중: 목 데이터 사용
      if (page == 1) {
        _notices = _getMockNotices();
        _pinnedNotices = _notices.where((n) => n.isPinned).toList();
        _urgentNotices = _notices.where((n) => n.isUrgent).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 공지사항 상세 조회
  Future<void> fetchNotice(String noticeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getNotice(noticeId);

      if (response['success'] == true) {
        _currentNotice = Notice.fromJson(response['data'] ?? {});
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching notice: $e');

      // 개발 중: 목 데이터 사용
      _currentNotice = _notices.firstWhere(
        (n) => n.id == noticeId,
        orElse: () => _getMockNotices().first,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 카테고리별 필터링
  void filterByCategory(String? category) {
    _selectedCategory = category;
    fetchNotices(category: category, priority: _selectedPriority);
  }

  /// 우선순위별 필터링
  void filterByPriority(String? priority) {
    _selectedPriority = priority;
    fetchNotices(category: _selectedCategory, priority: priority);
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 현재 공지사항 초기화
  void clearCurrentNotice() {
    _currentNotice = null;
    notifyListeners();
  }

  /// 목 데이터 (개발 중)
  List<Notice> _getMockNotices() {
    final now = DateTime.now();
    return [
      Notice(
        id: '1',
        title: '[긴급] DOA Market 서비스 이용약관 변경 안내',
        content: '''
안녕하세요, DOA Market입니다.

2025년 1월 1일부로 서비스 이용약관이 변경됩니다.

주요 변경 사항:
1. 개인정보 처리방침 업데이트
2. 배송 정책 개선
3. 포인트 적립 정책 변경

자세한 내용은 고객센터를 통해 확인하실 수 있습니다.

감사합니다.
''',
        category: '공지',
        status: 'published',
        priority: 'urgent',
        isPinned: true,
        views: 1250,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Notice(
        id: '2',
        title: '[이벤트] 신규 회원 가입 이벤트 - 10,000P 적립!',
        content: '''
DOA Market 신규 회원 가입 이벤트를 진행합니다!

이벤트 기간:
2025년 1월 1일 ~ 1월 31일

혜택:
- 회원 가입 시 10,000P 즉시 적립
- 첫 구매 시 추가 5,000P 적립
- 친구 추천 시 추천인/피추천인 각 3,000P 적립

이벤트 참여 방법:
1. DOA Market 회원 가입
2. 본인 인증 완료
3. 포인트 자동 지급

많은 참여 부탁드립니다!
''',
        category: 'event',
        isPinned: true,
        createdAt: now.subtract(const Duration(days: 1)),
        views: 3421,
      ),
      Notice(
        id: '3',
        title: '[점검] 정기 시스템 점검 안내',
        content: '''
서비스 품질 향상을 위한 정기 시스템 점검을 진행합니다.

점검 일시:
2025년 1월 15일 (수) 02:00 ~ 06:00 (4시간)

점검 내용:
- 서버 안정화 작업
- 보안 업데이트
- 성능 개선

점검 시간 동안 서비스 이용이 불가능합니다.
양해 부탁드립니다.

감사합니다.
''',
        category: 'maintenance',
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 5)),
        views: 856,
      ),
      Notice(
        id: '4',
        title: '[업데이트] 새로운 기능이 추가되었습니다',
        content: '''
DOA Market 앱이 업데이트되었습니다!

새로운 기능:
1. 포인트 적립/사용 기능
2. 상품 리뷰 작성
3. 1:1 문의 기능
4. 주문 취소/반품 기능

개선 사항:
- 결제 프로세스 개선
- UI/UX 개선
- 성능 최적화

업데이트 방법:
App Store / Google Play에서 앱 업데이트를 진행해주세요.

감사합니다.
''',
        category: 'update',
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 7)),
        views: 2103,
      ),
      Notice(
        id: '5',
        title: '[공지] 배송 지연 안내',
        content: '''
안녕하세요, DOA Market입니다.

최근 물량 증가로 인해 일부 지역에서 배송이 지연되고 있습니다.

영향 지역:
- 제주도
- 도서 산간 지역

예상 지연 시간:
1-2일 추가 소요 예정

빠른 시일 내에 정상화될 수 있도록 최선을 다하겠습니다.
불편을 드려 죄송합니다.

감사합니다.
''',
        category: 'announcement',
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 10)),
        views: 645,
      ),
      Notice(
        id: '6',
        title: '[이벤트] 설날 특별 할인 이벤트',
        content: '''
설날을 맞아 특별 할인 이벤트를 진행합니다!

이벤트 기간:
2025년 1월 20일 ~ 2월 10일

할인 내용:
- 전 품목 최대 50% 할인
- 무료 배송 (3만원 이상 구매 시)
- 추가 포인트 적립 (구매 금액의 10%)

이 기회를 놓치지 마세요!
''',
        category: 'event',
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 12)),
        views: 5234,
      ),
      Notice(
        id: '7',
        title: '[공지] 고객센터 운영 시간 변경 안내',
        content: '''
고객센터 운영 시간이 변경됩니다.

변경 전:
평일 09:00 ~ 18:00

변경 후:
평일 09:00 ~ 20:00
주말 10:00 ~ 17:00

더 나은 서비스로 보답하겠습니다.
감사합니다.
''',
        category: 'announcement',
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 15)),
        views: 432,
      ),
    ];
  }
}
