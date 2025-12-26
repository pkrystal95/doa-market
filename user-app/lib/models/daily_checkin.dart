/// 출석 체크 기록 모델
class DailyCheckin {
  final String id;
  final String userId;
  final DateTime checkinDate;
  final int pointsEarned;
  final int consecutiveDays;
  final bool isBonus;
  final DateTime createdAt;

  DailyCheckin({
    required this.id,
    required this.userId,
    required this.checkinDate,
    required this.pointsEarned,
    required this.consecutiveDays,
    required this.isBonus,
    required this.createdAt,
  });

  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      checkinDate: json['checkinDate'] != null
          ? DateTime.parse(json['checkinDate'])
          : DateTime.now(),
      pointsEarned: json['pointsEarned'] ?? 10,
      consecutiveDays: json['consecutiveDays'] ?? 1,
      isBonus: json['isBonus'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'checkinDate': checkinDate.toIso8601String().split('T')[0],
      'pointsEarned': pointsEarned,
      'consecutiveDays': consecutiveDays,
      'isBonus': isBonus,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 출석 체크 결과
class CheckinResult {
  final DailyCheckin checkin;
  final int pointsEarned;
  final int consecutiveDays;
  final int bonusPoints;
  final int totalPoints;
  final String message;

  CheckinResult({
    required this.checkin,
    required this.pointsEarned,
    required this.consecutiveDays,
    required this.bonusPoints,
    required this.totalPoints,
    required this.message,
  });

  factory CheckinResult.fromJson(Map<String, dynamic> json) {
    return CheckinResult(
      checkin: DailyCheckin.fromJson(json['checkin'] ?? {}),
      pointsEarned: json['pointsEarned'] ?? 10,
      consecutiveDays: json['consecutiveDays'] ?? 1,
      bonusPoints: json['bonusPoints'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      message: json['message'] ?? '출석 완료!',
    );
  }

  bool get hasBonus => bonusPoints > 0;
}

/// 출석 현황
class CheckinStatus {
  final bool isCheckedInToday;
  final int consecutiveDays;
  final int thisMonthCount;
  final int totalPoints;
  final int nextBonusDays;
  final int nextBonusPoints;
  final DateTime? lastCheckinDate;

  CheckinStatus({
    required this.isCheckedInToday,
    required this.consecutiveDays,
    required this.thisMonthCount,
    required this.totalPoints,
    this.nextBonusDays = 0,
    this.nextBonusPoints = 0,
    this.lastCheckinDate,
  });

  factory CheckinStatus.fromJson(Map<String, dynamic> json) {
    return CheckinStatus(
      isCheckedInToday: json['isCheckedInToday'] ?? false,
      consecutiveDays: json['consecutiveDays'] ?? 0,
      thisMonthCount: json['thisMonthCount'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      nextBonusDays: json['nextBonusDays'] ?? 0,
      nextBonusPoints: json['nextBonusPoints'] ?? 0,
      lastCheckinDate: json['lastCheckinDate'] != null
          ? DateTime.parse(json['lastCheckinDate'])
          : null,
    );
  }

  bool get canCheckIn => !isCheckedInToday;
  bool get hasNextBonus => nextBonusDays > 0 && nextBonusPoints > 0;
}

/// 출석 달력
class CheckinCalendar {
  final int year;
  final int month;
  final Map<String, CheckinDay> checkins;
  final int totalDays;

  CheckinCalendar({
    required this.year,
    required this.month,
    required this.checkins,
    required this.totalDays,
  });

  factory CheckinCalendar.fromJson(Map<String, dynamic> json) {
    final checkinsMap = <String, CheckinDay>{};
    if (json['checkins'] is Map) {
      (json['checkins'] as Map).forEach((key, value) {
        checkinsMap[key] = CheckinDay.fromJson(value);
      });
    }

    return CheckinCalendar(
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      checkins: checkinsMap,
      totalDays: json['totalDays'] ?? 0,
    );
  }

  bool isCheckedIn(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return checkins.containsKey(dateStr);
  }

  CheckinDay? getCheckinDay(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return checkins[dateStr];
  }
}

/// 출석 일자 정보
class CheckinDay {
  final int pointsEarned;
  final int consecutiveDays;
  final bool isBonus;

  CheckinDay({
    required this.pointsEarned,
    required this.consecutiveDays,
    this.isBonus = false,
  });

  factory CheckinDay.fromJson(Map<String, dynamic> json) {
    return CheckinDay(
      pointsEarned: json['pointsEarned'] ?? 10,
      consecutiveDays: json['consecutiveDays'] ?? 1,
      isBonus: json['isBonus'] ?? false,
    );
  }
}

/// 출석 통계
class CheckinStats {
  final int totalCheckins;
  final int totalPointsEarned;
  final int bonusCount;
  final int maxConsecutiveDays;

  CheckinStats({
    required this.totalCheckins,
    required this.totalPointsEarned,
    required this.bonusCount,
    required this.maxConsecutiveDays,
  });

  factory CheckinStats.fromJson(Map<String, dynamic> json) {
    return CheckinStats(
      totalCheckins: json['totalCheckins'] ?? 0,
      totalPointsEarned: json['totalPointsEarned'] ?? 0,
      bonusCount: json['bonusCount'] ?? 0,
      maxConsecutiveDays: json['maxConsecutiveDays'] ?? 0,
    );
  }
}
