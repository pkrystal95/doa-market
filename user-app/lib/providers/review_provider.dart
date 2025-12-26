import 'package:flutter/foundation.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Review> _productReviews = [];
  List<Review> _myReviews = [];
  ReviewStats? _reviewStats;
  bool _isLoading = false;
  String? _error;

  List<Review> get productReviews => _productReviews;
  List<Review> get myReviews => _myReviews;
  ReviewStats? get reviewStats => _reviewStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 특정 상품의 리뷰 조회
  Future<void> fetchProductReviews(
    String productId, {
    int page = 1,
  }) async {
    if (page == 1) {
      _productReviews = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getProductReviews(
        productId,
        page: page,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final reviews = data.map((json) => Review.fromJson(json)).toList();

        if (page == 1) {
          _productReviews = reviews;
        } else {
          _productReviews.addAll(reviews);
        }

        // 리뷰 통계 계산 (실제로는 API에서 받아와야 함)
        _calculateReviewStats(_productReviews);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching product reviews: $e');

      // 개발 중: 목 데이터 사용
      if (page == 1) {
        _productReviews = _getMockProductReviews(productId);
        _calculateReviewStats(_productReviews);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 내 리뷰 목록 조회
  Future<void> fetchMyReviews(
    String userId, {
    int page = 1,
  }) async {
    if (page == 1) {
      _myReviews = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMyReviews(
        userId,
        page: page,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final reviews = data.map((json) => Review.fromJson(json)).toList();

        if (page == 1) {
          _myReviews = reviews;
        } else {
          _myReviews.addAll(reviews);
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching my reviews: $e');

      // 개발 중: 목 데이터 사용
      if (page == 1) {
        _myReviews = _getMockMyReviews(userId);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 리뷰 작성
  Future<bool> createReview({
    required String userId,
    required String productId,
    required String orderId,
    required int rating,
    required String content,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _apiService.createReview(
        userId: userId,
        productId: productId,
        orderId: orderId,
        rating: rating,
        content: content,
        imageUrls: imageUrls,
      );

      if (response['success'] == true) {
        // 리뷰 목록 갱신
        await fetchMyReviews(userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating review: $e');
      return false;
    }
  }

  /// 리뷰 수정
  Future<bool> updateReview({
    required String userId,
    required String reviewId,
    required int rating,
    required String content,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _apiService.updateReview(
        userId: userId,
        reviewId: reviewId,
        rating: rating,
        content: content,
        imageUrls: imageUrls,
      );

      if (response['success'] == true) {
        // 리뷰 목록 갱신
        await fetchMyReviews(userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating review: $e');
      return false;
    }
  }

  /// 리뷰 삭제
  Future<bool> deleteReview({
    required String userId,
    required String reviewId,
  }) async {
    try {
      final response = await _apiService.deleteReview(
        userId: userId,
        reviewId: reviewId,
      );

      if (response['success'] == true) {
        // 리뷰 목록 갱신
        await fetchMyReviews(userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting review: $e');
      return false;
    }
  }

  /// 리뷰 통계 계산
  void _calculateReviewStats(List<Review> reviews) {
    if (reviews.isEmpty) {
      _reviewStats = ReviewStats(
        averageRating: 0.0,
        totalCount: 0,
        ratingDistribution: {},
      );
      return;
    }

    final ratingDistribution = <int, int>{
      5: 0,
      4: 0,
      3: 0,
      2: 0,
      1: 0,
    };

    double totalRating = 0.0;
    for (final review in reviews) {
      totalRating += review.rating;
      ratingDistribution[review.rating] =
          (ratingDistribution[review.rating] ?? 0) + 1;
    }

    _reviewStats = ReviewStats(
      averageRating: totalRating / reviews.length,
      totalCount: reviews.length,
      ratingDistribution: ratingDistribution,
    );
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 목 데이터 - 상품 리뷰 (개발 중)
  List<Review> _getMockProductReviews(String productId) {
    final now = DateTime.now();
    return [
      Review(
        id: '1',
        userId: 'user1',
        userName: '김**',
        productId: productId,
        productName: '테스트 상품',
        orderId: 'order123',
        rating: 5,
        content: '정말 좋은 상품입니다! 배송도 빠르고 품질도 만족스럽습니다. 강력 추천합니다!',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 3)),
        helpfulCount: 42,
      ),
      Review(
        id: '2',
        userId: 'user2',
        userName: '이**',
        productId: productId,
        productName: '테스트 상품',
        orderId: 'order124',
        rating: 4,
        content: '가격 대비 괜찮은 상품입니다. 다만 배송이 조금 늦었어요.',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 5)),
        helpfulCount: 28,
      ),
      Review(
        id: '3',
        userId: 'user3',
        userName: '박**',
        productId: productId,
        productName: '테스트 상품',
        orderId: 'order125',
        rating: 5,
        content: '만족스러운 구매였습니다. 재구매 의사 있습니다.',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 7)),
        helpfulCount: 15,
      ),
      Review(
        id: '4',
        userId: 'user4',
        userName: '최**',
        productId: productId,
        productName: '테스트 상품',
        orderId: 'order126',
        rating: 3,
        content: '보통입니다. 가격만큼의 품질인 것 같아요.',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 10)),
        helpfulCount: 8,
      ),
      Review(
        id: '5',
        userId: 'user5',
        userName: '정**',
        productId: productId,
        productName: '테스트 상품',
        orderId: 'order127',
        rating: 5,
        content: '대만족! 친구들에게도 추천했어요.',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 15)),
        helpfulCount: 35,
      ),
    ];
  }

  /// 목 데이터 - 내 리뷰 (개발 중)
  List<Review> _getMockMyReviews(String userId) {
    final now = DateTime.now();
    return [
      Review(
        id: '1',
        userId: userId,
        userName: '나',
        productId: 'product1',
        productName: '구매한 상품 1',
        orderId: 'order123',
        rating: 5,
        content: '정말 만족스러운 구매였습니다!',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 3)),
        helpfulCount: 5,
      ),
      Review(
        id: '2',
        userId: userId,
        userName: '나',
        productId: 'product2',
        productName: '구매한 상품 2',
        orderId: 'order124',
        rating: 4,
        content: '가격 대비 괜찮은 상품입니다.',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 10)),
        helpfulCount: 3,
      ),
    ];
  }
}
