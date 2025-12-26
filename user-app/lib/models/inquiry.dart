/// 1:1 문의 모델
class Inquiry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category; // 'order', 'product', 'delivery', 'payment', 'etc'
  final List<String> imageUrls;
  final String status; // 'pending', 'answered', 'resolved'
  final DateTime createdAt;
  final InquiryReply? reply;

  Inquiry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrls = const [],
    required this.status,
    required this.createdAt,
    this.reply,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['id'] ?? json['inquiryId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'etc',
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      reply: json['reply'] != null
          ? InquiryReply.fromJson(json['reply'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'category': category,
      'imageUrls': imageUrls,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'reply': reply?.toJson(),
    };
  }

  String get categoryName {
    switch (category) {
      case 'order':
        return '주문/결제';
      case 'product':
        return '상품';
      case 'delivery':
        return '배송';
      case 'payment':
        return '결제';
      case 'etc':
        return '기타';
      default:
        return '문의';
    }
  }

  String get statusName {
    switch (status) {
      case 'pending':
        return '답변대기';
      case 'answered':
        return '답변완료';
      case 'resolved':
        return '해결완료';
      default:
        return '확인중';
    }
  }

  bool get hasReply => reply != null;
  bool get isPending => status == 'pending';
  bool get isAnswered => status == 'answered' || status == 'resolved';
  bool get hasImages => imageUrls.isNotEmpty;
}

/// 문의 답변 모델
class InquiryReply {
  final String id;
  final String inquiryId;
  final String content;
  final String adminName;
  final DateTime createdAt;

  InquiryReply({
    required this.id,
    required this.inquiryId,
    required this.content,
    required this.adminName,
    required this.createdAt,
  });

  factory InquiryReply.fromJson(Map<String, dynamic> json) {
    return InquiryReply(
      id: json['id'] ?? json['replyId'] ?? '',
      inquiryId: json['inquiryId'] ?? '',
      content: json['content'] ?? '',
      adminName: json['adminName'] ?? '관리자',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inquiryId': inquiryId,
      'content': content,
      'adminName': adminName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
