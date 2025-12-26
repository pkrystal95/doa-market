/// 공지사항 모델
class Notice {
  final String id;
  final String title;
  final String content;
  final String category; // '공지', '이벤트', '업데이트', '점검'
  final String status; // 'draft', 'published', 'archived'
  final String priority; // 'normal', 'urgent'
  final bool isPinned; // 상단 고정 여부
  final int views; // 조회수
  final List<String>? attachments; // 첨부파일 URL 배열
  final DateTime? startDate; // 게시 시작일
  final DateTime? endDate; // 게시 종료일
  final DateTime createdAt;
  final DateTime? updatedAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.status = 'published',
    this.priority = 'normal',
    this.isPinned = false,
    this.views = 0,
    this.attachments,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] ?? json['noticeId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '공지',
      status: json['status'] ?? 'published',
      priority: json['priority'] ?? 'normal',
      isPinned: json['isPinned'] ?? false,
      views: json['views'] ?? json['viewCount'] ?? 0,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'status': status,
      'priority': priority,
      'isPinned': isPinned,
      'views': views,
      'attachments': attachments,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get categoryName => category;

  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 7; // 7일 이내면 새 공지
  }

  bool get isUrgent => priority == 'urgent';

  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;
}
