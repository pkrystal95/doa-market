import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 마이크로서비스 엔드포인트
  static const String authServiceUrl = 'http://localhost:3001/api/v1';
  static const String userServiceUrl = 'http://localhost:3002/api/v1';
  static const String productServiceUrl = 'http://localhost:3003/api/v1';
  static const String orderServiceUrl = 'http://localhost:3004/api/v1';
  static const String paymentServiceUrl = 'http://localhost:3006/api/v1';
  static const String cartServiceUrl = 'http://localhost:3005/api/v1';
  static const String sellerServiceUrl = 'http://localhost:3007/api/v1';

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
      final response = await http.get(
        Uri.parse('$productServiceUrl/products?page=$page&limit=$limit'),
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
      final response = await http.get(
        Uri.parse('$productServiceUrl/products/$productId'),
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

  // 장바구니 조회
  Future<Map<String, dynamic>> getCart(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$cartServiceUrl/carts/$userId'),
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

  // 장바구니에 상품 추가
  Future<Map<String, dynamic>> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$cartServiceUrl/carts/$userId/items'),
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

  // 주문 생성
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
  }) async {
    try {
      final response = await http.post(
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
      final response = await http.get(
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

  // 결제 준비 (KG Inicis)
  Future<Map<String, dynamic>> preparePayment({
    required String orderId,
    required String userId,
    required double amount,
    required String productName,
  }) async {
    try {
      final response = await http.post(
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
      final response = await http.post(
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
      final response = await http.get(
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
}
