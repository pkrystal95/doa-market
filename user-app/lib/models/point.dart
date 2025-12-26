/// 포인트 적립/사용 내역 모델
class Point {
  final String id;
  final String userId;
  final int amount; // 양수: 적립, 음수: 사용
  final String type; // 'earn', 'use', 'expire'
  final String source; // 'daily_checkin', 'purchase', 'review', 'admin', 'refund', 'event'
  final String? orderId; // 관련 주문 ID
  final String description; // 적립/사용 사유
  final int balance; // 거래 후 잔액
  final DateTime createdAt;
  final DateTime? expiresAt; // 포인트 만료일

  Point({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.source,
    this.orderId,
    required this.description,
    required this.balance,
    required this.createdAt,
    this.expiresAt,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      id: json['id'] ?? json['pointId'] ?? '',
      userId: json['userId'] ?? '',
      amount: json['amount'] ?? 0,
      type: json['type'] ?? 'earn',
      source: json['source'] ?? 'purchase',
      orderId: json['orderId'],
      description: json['description'] ?? '',
      balance: json['balance'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'source': source,
      'orderId': orderId,
      'description': description,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  bool get isEarned => type == 'earn' && amount > 0;
  bool get isUsed => type == 'use' && amount < 0;
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isDailyCheckin => source == 'daily_checkin';
  bool get isPurchase => source == 'purchase';
  bool get isReview => source == 'review';

  String get sourceLabel {
    switch (source) {
      case 'daily_checkin':
        return '출석체크';
      case 'purchase':
        return '구매';
      case 'review':
        return '리뷰';
      case 'admin':
        return '관리자 지급';
      case 'refund':
        return '환불';
      case 'event':
        return '이벤트';
      default:
        return '기타';
    }
  }
}

/// 포인트 요약 정보
class PointSummary {
  final int currentBalance; // 현재 보유 포인트
  final int pendingPoints; // 적립 예정 포인트
  final int expiringPoints; // 곧 만료될 포인트 (30일 이내)
  final DateTime? nextExpiringDate; // 다음 만료 예정일

  PointSummary({
    required this.currentBalance,
    this.pendingPoints = 0,
    this.expiringPoints = 0,
    this.nextExpiringDate,
  });

  factory PointSummary.fromJson(Map<String, dynamic> json) {
    return PointSummary(
      currentBalance: json['currentBalance'] ?? 0,
      pendingPoints: json['pendingPoints'] ?? 0,
      expiringPoints: json['expiringPoints'] ?? 0,
      nextExpiringDate: json['nextExpiringDate'] != null
          ? DateTime.parse(json['nextExpiringDate'])
          : null,
    );
  }
}
