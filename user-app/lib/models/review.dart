/// 리뷰 모델
class Review {
  final String id;
  final String userId;
  final String userName;
  final String productId;
  final String productName;
  final String? orderId;
  final int rating; // 1-5
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int helpfulCount; // 도움이 돼요 수

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productId,
    required this.productName,
    this.orderId,
    required this.rating,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.updatedAt,
    this.helpfulCount = 0,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? json['reviewId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '익명',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      orderId: json['orderId'],
      rating: json['rating'] ?? 5,
      content: json['content'] ?? '',
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      helpfulCount: json['helpfulCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'productId': productId,
      'productName': productName,
      'orderId': orderId,
      'rating': rating,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'helpfulCount': helpfulCount,
    };
  }

  bool get hasImages => imageUrls.isNotEmpty;
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 30; // 30일 이내면 최근 리뷰
  }
}

/// 리뷰 통계
class ReviewStats {
  final double averageRating;
  final int totalCount;
  final Map<int, int> ratingDistribution; // {5: 100, 4: 50, 3: 20, 2: 5, 1: 2}

  ReviewStats({
    required this.averageRating,
    required this.totalCount,
    required this.ratingDistribution,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalCount: json['totalCount'] ?? 0,
      ratingDistribution: json['ratingDistribution'] != null
          ? Map<int, int>.from(json['ratingDistribution'])
          : {},
    );
  }

  int getRatingCount(int rating) => ratingDistribution[rating] ?? 0;

  double getRatingPercentage(int rating) {
    if (totalCount == 0) return 0.0;
    return (getRatingCount(rating) / totalCount) * 100;
  }
}
