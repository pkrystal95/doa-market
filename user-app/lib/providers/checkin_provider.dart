import 'package:flutter/foundation.dart';
import '../models/daily_checkin.dart';
import '../services/api_service.dart';

class CheckinProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  CheckinStatus? _checkinStatus;
  CheckinCalendar? _checkinCalendar;
  CheckinStats? _checkinStats;
  bool _isLoading = false;
  bool _isCheckingIn = false;
  String? _error;
  String? _successMessage;

  CheckinStatus? get checkinStatus => _checkinStatus;
  CheckinCalendar? get checkinCalendar => _checkinCalendar;
  CheckinStats? get checkinStats => _checkinStats;
  bool get isLoading => _isLoading;
  bool get isCheckingIn => _isCheckingIn;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // 편의 getters
  bool get isCheckedInToday => _checkinStatus?.isCheckedInToday ?? false;
  int get consecutiveDays => _checkinStatus?.consecutiveDays ?? 0;
  int get totalPoints => _checkinStatus?.totalPoints ?? 0;
  bool get canCheckIn => _checkinStatus?.canCheckIn ?? true;

  /// 출석 체크
  Future<CheckinResult?> checkIn(String userId) async {
    if (_isCheckingIn) return null;

    _isCheckingIn = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.checkIn(userId);

      if (response['success'] == true) {
        final result = CheckinResult.fromJson(response['data']);
        _successMessage = result.message;

        // 출석 현황 갱신
        await fetchCheckinStatus(userId);

        _isCheckingIn = false;
        notifyListeners();

        return result;
      }

      _isCheckingIn = false;
      notifyListeners();
      return null;
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // "Already checked in" is not an error, just silently update status
      if (errorMessage.contains('이미 출석')) {
        await fetchCheckinStatus(userId);
        _isCheckingIn = false;
        notifyListeners();
        return null;
      }

      _error = errorMessage;
      _isCheckingIn = false;
      notifyListeners();
      debugPrint('Error checking in: $e');
      return null;
    }
  }

  /// 출석 현황 조회
  Future<void> fetchCheckinStatus(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCheckinStatus(userId);

      if (response['success'] == true) {
        _checkinStatus = CheckinStatus.fromJson(response['data'] ?? {});
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching checkin status: $e');

      // 개발 중: 목 데이터
      _checkinStatus = CheckinStatus(
        isCheckedInToday: false,
        consecutiveDays: 0,
        thisMonthCount: 0,
        totalPoints: 0,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 출석 달력 조회
  Future<void> fetchCheckinCalendar(String userId, int year, int month) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCheckinCalendar(
        userId: userId,
        year: year,
        month: month,
      );

      if (response['success'] == true) {
        _checkinCalendar = CheckinCalendar.fromJson(response['data'] ?? {});
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching checkin calendar: $e');

      // 개발 중: 목 데이터
      _checkinCalendar = CheckinCalendar(
        year: year,
        month: month,
        checkins: {},
        totalDays: 0,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 출석 통계 조회
  Future<void> fetchCheckinStats(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCheckinStats(userId);

      if (response['success'] == true) {
        _checkinStats = CheckinStats.fromJson(response['data'] ?? {});
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching checkin stats: $e');

      // 개발 중: 목 데이터
      _checkinStats = CheckinStats(
        totalCheckins: 0,
        totalPointsEarned: 0,
        bonusCount: 0,
        maxConsecutiveDays: 0,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 날짜에 출석했는지 확인
  bool isCheckedIn(DateTime date) {
    return _checkinCalendar?.isCheckedIn(date) ?? false;
  }

  /// 특정 날짜의 출석 정보 가져오기
  CheckinDay? getCheckinDay(DateTime date) {
    return _checkinCalendar?.getCheckinDay(date);
  }

  /// 현재 달력 표시 중인 연월 가져오기
  DateTime get currentCalendarMonth {
    if (_checkinCalendar != null) {
      return DateTime(_checkinCalendar!.year, _checkinCalendar!.month);
    }
    return DateTime.now();
  }

  /// 다음 보너스까지 남은 일수 메시지
  String get nextBonusMessage {
    if (_checkinStatus == null || !_checkinStatus!.hasNextBonus) {
      return '';
    }

    final days = _checkinStatus!.nextBonusDays;
    final points = _checkinStatus!.nextBonusPoints;

    if (days <= 0) {
      return '';
    }

    return '$days일 더 출석하면 보너스 $points포인트 획득!';
  }

  /// 출석 현황 요약 메시지
  String get statusSummary {
    if (_checkinStatus == null) {
      return '출석 정보를 불러오는 중...';
    }

    if (_checkinStatus!.isCheckedInToday) {
      return '오늘 출석 완료! 🎉';
    }

    return '오늘 출석하고 10포인트 받으세요!';
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 성공 메시지 초기화
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  /// 전체 데이터 초기화
  void clear() {
    _checkinStatus = null;
    _checkinCalendar = null;
    _checkinStats = null;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// 초기 데이터 로드 (한 번에)
  Future<void> initialize(String userId) async {
    await Future.wait([
      fetchCheckinStatus(userId),
      fetchCheckinCalendar(
        userId,
        DateTime.now().year,
        DateTime.now().month,
      ),
      fetchCheckinStats(userId),
    ]);
  }
}
