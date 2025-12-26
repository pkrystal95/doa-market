import 'package:flutter/foundation.dart';
import '../models/point.dart';
import '../services/api_service.dart';

class PointProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  PointSummary? _pointSummary;
  List<Point> _pointHistory = [];
  bool _isLoading = false;
  String? _error;

  PointSummary? get pointSummary => _pointSummary;
  List<Point> get pointHistory => _pointHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPoints => _pointSummary?.currentBalance ?? 0;

  /// 포인트 요약 정보 조회
  Future<void> fetchPointSummary(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getPointSummary(userId);

      if (response['success'] == true) {
        _pointSummary = PointSummary.fromJson(response['data'] ?? {});
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching point summary: $e');

      // 개발 중: 목 데이터 사용
      _pointSummary = PointSummary(
        currentBalance: 12500,
        pendingPoints: 500,
        expiringPoints: 1000,
        nextExpiringDate: DateTime.now().add(const Duration(days: 30)),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 포인트 사용 내역 조회
  Future<void> fetchPointHistory(String userId, {int page = 1}) async {
    if (page == 1) {
      _pointHistory = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getPointHistory(
        userId,
        page: page,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final points = data.map((json) => Point.fromJson(json)).toList();

        if (page == 1) {
          _pointHistory = points;
        } else {
          _pointHistory.addAll(points);
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching point history: $e');

      // 개발 중: 목 데이터 사용
      if (page == 1) {
        _pointHistory = _getMockPointHistory();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 포인트 사용 (결제 시)
  Future<bool> usePoints({
    required String userId,
    required int amount,
    required String orderId,
  }) async {
    try {
      final response = await _apiService.usePoints(
        userId: userId,
        amount: amount,
        orderId: orderId,
      );

      if (response['success'] == true) {
        // 포인트 요약 정보 갱신
        await fetchPointSummary(userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error using points: $e');
      return false;
    }
  }

  /// 포인트 적립 (주문 완료 시)
  Future<bool> earnPoints({
    required String userId,
    required int amount,
    required String orderId,
    String? description,
  }) async {
    try {
      final response = await _apiService.earnPoints(
        userId: userId,
        amount: amount,
        orderId: orderId,
        description: description ?? '구매 적립',
      );

      if (response['success'] == true) {
        // 포인트 요약 정보 갱신
        await fetchPointSummary(userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error earning points: $e');
      return false;
    }
  }

  /// 사용 가능한 최대 포인트 계산
  int getMaxUsablePoints(int orderAmount) {
    final availablePoints = totalPoints;
    // 주문 금액의 최대 50%까지만 사용 가능
    final maxByOrder = (orderAmount * 0.5).floor();
    return availablePoints < maxByOrder ? availablePoints : maxByOrder;
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 목 데이터 (개발 중)
  List<Point> _getMockPointHistory() {
    final now = DateTime.now();
    return [
      Point(
        id: '1',
        userId: 'user1',
        amount: 500,
        type: 'earn',
        source: 'purchase',
        orderId: 'order123',
        description: '구매 적립 (주문번호: ORD-20231217-001)',
        balance: 13000,
        createdAt: now.subtract(const Duration(days: 1)),
        expiresAt: now.add(const Duration(days: 364)),
      ),
      Point(
        id: '2',
        userId: 'user1',
        amount: -2000,
        type: 'use',
        source: 'purchase',
        orderId: 'order122',
        description: '포인트 사용 (주문번호: ORD-20231216-002)',
        balance: 12500,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Point(
        id: '3',
        userId: 'user1',
        amount: 1000,
        type: 'earn',
        source: 'event',
        description: '이벤트 적립',
        balance: 14500,
        createdAt: now.subtract(const Duration(days: 5)),
        expiresAt: now.add(const Duration(days: 359)),
      ),
      Point(
        id: '4',
        userId: 'user1',
        amount: 3000,
        type: 'earn',
        source: 'purchase',
        orderId: 'order120',
        description: '구매 적립 (주문번호: ORD-20231210-003)',
        balance: 13500,
        createdAt: now.subtract(const Duration(days: 7)),
        expiresAt: now.add(const Duration(days: 357)),
      ),
      Point(
        id: '5',
        userId: 'user1',
        amount: 10000,
        type: 'earn',
        source: 'admin',
        description: '회원가입 축하 적립',
        balance: 10500,
        createdAt: now.subtract(const Duration(days: 30)),
        expiresAt: now.add(const Duration(days: 334)),
      ),
    ];
  }
}
