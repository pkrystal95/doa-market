import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class ApiService {
  // HTTPS 통합 엔드포인트 (nginx 리버스 프록시 사용)
  static const String hostIp = '192.168.0.19';
  static const String baseUrl = 'https://$hostIp/api/v1';

  // HTTP Client that accepts self-signed certificates (for development/testing)
  static http.Client? _client;

  static http.Client get client {
    if (_client == null) {
      final ioClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      _client = IOClient(ioClient);
    }
    return _client!;
  }

  // Individual service URLs (unified through nginx reverse proxy)
  static const String authServiceUrl = '$baseUrl/auth';
  static const String userServiceUrl = '$baseUrl/users';
  static const String productServiceUrl = '$baseUrl/products';
  static const String categoryServiceUrl = '$baseUrl/categories';
  static const String orderServiceUrl = '$baseUrl/orders';
  static const String paymentServiceUrl = '$baseUrl/payments';
  static const String cartServiceUrl = '$baseUrl/carts';
  static const String wishlistServiceUrl = '$baseUrl/wishlists';
  static const String addressServiceUrl = '$baseUrl/addresses';
  static const String sellerServiceUrl = '$baseUrl/sellers';

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // 상품 목록 조회
  Future<Map<String, dynamic>> getProducts({int page = 1, int limit = 20}) async {
    try {
      final response = await client.get(
        Uri.parse('$productServiceUrl?page=$page&limit=$limit'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('상품 목록을 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 상품 상세 조회
  Future<Map<String, dynamic>> getProduct(String productId) async {
    try {
      final response = await client.get(
        Uri.parse('$productServiceUrl/$productId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('상품 정보를 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 장바구니 조회 (새로운 cart-service 사용)
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/cart'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('장바구니를 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 장바구니에 상품 추가 (새로운 cart-service 사용)
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/cart'),
        headers: _getHeaders(),
        body: json.encode({
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('장바구니에 추가하는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 장바구니 아이템 수량 변경
  Future<Map<String, dynamic>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/cart/$cartItemId'),
        headers: _getHeaders(),
        body: json.encode({
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('수량 변경에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 장바구니 아이템 삭제
  Future<Map<String, dynamic>> removeCartItem(String cartItemId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/cart/$cartItemId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('삭제에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 장바구니 전체 비우기
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/cart'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('장바구니 비우기에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 주문 생성
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$orderServiceUrl/orders'),
        headers: _getHeaders(),
        body: json.encode({
          'userId': userId,
          'items': items,
          'shippingAddress': shippingAddress,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('주문 생성에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 내 주문 목록 조회
  Future<Map<String, dynamic>> getMyOrders(String userId, {int page = 1}) async {
    try {
      final response = await client.get(
        Uri.parse('$orderServiceUrl/orders/user/$userId?page=$page&limit=20'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('주문 목록을 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 주문 상세 조회
  Future<Map<String, dynamic>> getOrder(String userId, String orderId) async {
    try {
      final response = await client.get(
        Uri.parse('$orderServiceUrl/orders/$orderId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('주문 상세를 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 결제 준비 (KG Inicis)
  Future<Map<String, dynamic>> preparePayment({
    required String orderId,
    required String userId,
    required double amount,
    required String productName,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$paymentServiceUrl/payments/prepare'),
        headers: _getHeaders(),
        body: json.encode({
          'orderId': orderId,
          'userId': userId,
          'amount': amount,
          'productName': productName,
          'method': 'inicis',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('결제 준비에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 결제 완료 처리
  Future<Map<String, dynamic>> completePayment({
    required String paymentId,
    required String transactionId,
    required String status,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$paymentServiceUrl/payments/$paymentId/complete'),
        headers: _getHeaders(),
        body: json.encode({
          'transactionId': transactionId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('결제 완료 처리에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 결제 조회
  Future<Map<String, dynamic>> getPayment(String paymentId) async {
    try {
      final response = await client.get(
        Uri.parse('$paymentServiceUrl/payments/$paymentId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('결제 정보를 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // ===== 주소 관리 API =====

  // 주소 목록 조회
  Future<Map<String, dynamic>> getAddresses(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users/$userId/addresses'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('주소 목록을 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 주소 추가
  Future<Map<String, dynamic>> createAddress({
    required String userId,
    required Map<String, dynamic> addressData,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users/$userId/addresses'),
        headers: _getHeaders(),
        body: json.encode(addressData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('주소 추가에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 주소 수정
  Future<Map<String, dynamic>> updateAddress({
    required String userId,
    required String addressId,
    required Map<String, dynamic> addressData,
  }) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/users/$userId/addresses/$addressId'),
        headers: _getHeaders(),
        body: json.encode(addressData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('주소 수정에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 주소 삭제
  Future<Map<String, dynamic>> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/users/$userId/addresses/$addressId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('주소 삭제에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // ===== 카테고리 API =====

  // 카테고리 목록 조회
  Future<Map<String, dynamic>> getCategories({String? parentId}) async {
    try {
      String url = categoryServiceUrl;
      if (parentId != null) {
        url += '?parentId=$parentId';
      }

      final response = await client.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('카테고리 목록을 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 카테고리별 상품 조회
  Future<Map<String, dynamic>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('$productServiceUrl?categoryId=$categoryId&page=$page&limit=$limit'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('상품 목록을 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // ===== 검색 API =====

  // 상품 검색
  Future<Map<String, dynamic>> searchProducts({
    required String keyword,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/search?keyword=$keyword'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('검색에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 인기 검색어 조회
  Future<Map<String, dynamic>> getPopularKeywords({int limit = 10}) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/search/popular?limit=$limit'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('인기 검색어를 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 검색 기록 조회
  Future<Map<String, dynamic>> getSearchHistory(String userId, {int limit = 20}) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/search/history/$userId?limit=$limit'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('검색 기록을 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // ===== 위시리스트 API =====

  // 위시리스트에 추가
  Future<Map<String, dynamic>> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/wishlist'),
        headers: _getHeaders(),
        body: json.encode({
          'userId': userId,
          'productId': productId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('위시리스트에 추가하는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 위시리스트에서 제거
  Future<Map<String, dynamic>> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/wishlist/$userId/$productId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('위시리스트에서 제거하는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 사용자 위시리스트 조회
  Future<Map<String, dynamic>> getUserWishlist(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/wishlist/user/$userId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('위시리스트를 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 위시리스트 확인
  Future<bool> checkInWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/wishlist/check/$userId/$productId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['inWishlist'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 위시리스트 개수 조회
  Future<int> getWishlistCount(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/wishlist/count/$userId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  // ===== 사용자 프로필 API =====

  // 프로필 조회
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('프로필을 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 프로필 업데이트
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: _getHeaders(),
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('프로필 업데이트에 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // ============================================
  // Point (포인트) APIs
  // ============================================

  /// 포인트 요약 정보 조회
  Future<Map<String, dynamic>> getPointSummary(String userId) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/points/summary');
      final response = await client.get(url, headers: _getHeaders());

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 포인트 내역 조회
  Future<Map<String, dynamic>> getPointHistory(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/points?page=$page&limit=$limit');
      final response = await client.get(url, headers: _getHeaders());

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 포인트 사용
  Future<Map<String, dynamic>> usePoints({
    required String userId,
    required int amount,
    required String orderId,
  }) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/points/use');
      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'amount': amount,
          'orderId': orderId,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 포인트 적립
  Future<Map<String, dynamic>> earnPoints({
    required String userId,
    required int amount,
    required String orderId,
    required String description,
  }) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/points/earn');
      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'amount': amount,
          'orderId': orderId,
          'description': description,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // ============================================
  // Notice (공지사항) APIs
  // ============================================

  /// 공지사항 목록 조회
  Future<Map<String, dynamic>> getNotices({
    int page = 1,
    int limit = 20,
    String? category,
    String? priority,
  }) async {
    try {
      String url = '$baseUrl/notices?page=$page&limit=$limit';
      if (category != null) {
        url += '&category=$category';
      }
      if (priority != null) {
        url += '&priority=$priority';
      }
      final response = await client.get(Uri.parse(url), headers: _getHeaders());

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 공지사항 상세 조회
  Future<Map<String, dynamic>> getNotice(String noticeId) async {
    try {
      final url = Uri.parse('$baseUrl/notices/$noticeId');
      final response = await client.get(url, headers: _getHeaders());

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // ============================================
  // Review (리뷰) APIs
  // ============================================

  /// 상품 리뷰 목록 조회
  Future<Map<String, dynamic>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$productServiceUrl/$productId/reviews?page=$page&limit=$limit');
      final response = await client.get(url, headers: _getHeaders());

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 내 리뷰 목록 조회
  Future<Map<String, dynamic>> getMyReviews(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/reviews?page=$page&limit=$limit');
      final response = await client.get(url, headers: _getHeaders());

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 리뷰 작성
  Future<Map<String, dynamic>> createReview({
    required String userId,
    required String productId,
    required String orderId,
    required int rating,
    required String content,
    List<String>? imageUrls,
  }) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/reviews');
      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'productId': productId,
          'orderId': orderId,
          'rating': rating,
          'content': content,
          'imageUrls': imageUrls,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 리뷰 수정
  Future<Map<String, dynamic>> updateReview({
    required String userId,
    required String reviewId,
    required int rating,
    required String content,
    List<String>? imageUrls,
  }) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/reviews/$reviewId');
      final response = await client.put(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'rating': rating,
          'content': content,
          'imageUrls': imageUrls,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 리뷰 삭제
  Future<Map<String, dynamic>> deleteReview({
    required String userId,
    required String reviewId,
  }) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/reviews/$reviewId');
      final response = await client.delete(url, headers: _getHeaders());

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // ============================================
  // Inquiry (1:1 문의) APIs
  // ============================================

  /// 문의 목록 조회
  Future<Map<String, dynamic>> getInquiries(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/inquiries?page=$page&limit=$limit');
      final response = await client.get(url, headers: _getHeaders());

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 문의 상세 조회
  Future<Map<String, dynamic>> getInquiry(String userId, String inquiryId) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/inquiries/$inquiryId');
      final response = await client.get(url, headers: _getHeaders());

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 문의 작성
  Future<Map<String, dynamic>> createInquiry({
    required String userId,
    required String title,
    required String content,
    required String category,
    List<String>? imageUrls,
  }) async {
    try {
      final url = Uri.parse('$userServiceUrl/$userId/inquiries');
      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'title': title,
          'content': content,
          'category': category,
          'imageUrls': imageUrls,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // ============================================
  // Order Cancellation/Return (주문 취소/반품) APIs
  // ============================================

  /// 주문 취소
  Future<Map<String, dynamic>> cancelOrder({
    required String userId,
    required String orderId,
    required String reason,
  }) async {
    try {
      final url = Uri.parse('$orderServiceUrl/$orderId/cancel');
      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'userId': userId,
          'reason': reason,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 반품 신청
  Future<Map<String, dynamic>> requestReturn({
    required String userId,
    required String orderId,
    required String reason,
    List<String>? imageUrls,
  }) async {
    try {
      final url = Uri.parse('$orderServiceUrl/$orderId/return');
      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'userId': userId,
          'reason': reason,
          'imageUrls': imageUrls,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 교환 신청
  Future<Map<String, dynamic>> requestExchange({
    required String userId,
    required String orderId,
    required String reason,
    List<String>? imageUrls,
  }) async {
    try {
      final url = Uri.parse('$orderServiceUrl/$orderId/exchange');
      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'userId': userId,
          'reason': reason,
          'imageUrls': imageUrls,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }


  // ==================== 출석체크 API ====================

  /// 출석 체크
  Future<Map<String, dynamic>> checkIn(String userId) async {
    try {
      final response = await client.post(
        Uri.parse('$userServiceUrl/$userId/checkin'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '출석체크에 실패했습니다');
      }
    } catch (e) {
      if (e.toString().contains('이미 출석')) {
        rethrow;
      }
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 출석 현황 조회
  Future<Map<String, dynamic>> getCheckinStatus(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$userServiceUrl/$userId/checkin/status'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('출석 현황을 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 출석 달력 조회
  Future<Map<String, dynamic>> getCheckinCalendar({
    required String userId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('$userServiceUrl/$userId/checkin/calendar?year=$year&month=$month'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('출석 달력을 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 출석 통계 조회
  Future<Map<String, dynamic>> getCheckinStats(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$userServiceUrl/$userId/checkin/stats'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('출석 통계를 불러오는데 실패했습니다');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}
