import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class WishlistProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _wishlistItems = [];
  bool _isLoading = false;
  String? _error;
  int _count = 0;

  List<Product> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _count;

  // 찜 목록 조회
  Future<void> fetchWishlist(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getUserWishlist(userId);

      if (response['success'] == true) {
        final List<dynamic> wishlistData = response['data'] ?? [];
        _wishlistItems = wishlistData
            .map((item) => Product.fromJson(item['product'] ?? item))
            .toList();
        _count = _wishlistItems.length;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 찜 추가
  Future<bool> addToWishlist(String userId, String productId) async {
    try {
      final response = await _apiService.addToWishlist(
        userId: userId,
        productId: productId,
      );

      if (response['success'] == true) {
        // 카운트 증가
        _count++;
        // 목록 다시 불러오기
        await fetchWishlist(userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding to wishlist: $e');
      notifyListeners();
      return false;
    }
  }

  // 찜 제거
  Future<bool> removeFromWishlist(String userId, String productId) async {
    try {
      final response = await _apiService.removeFromWishlist(
        userId: userId,
        productId: productId,
      );

      if (response['success'] == true) {
        _wishlistItems.removeWhere((product) => product.id == productId);
        _count = _wishlistItems.length;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error removing from wishlist: $e');
      notifyListeners();
      return false;
    }
  }

  // 찜 여부 확인
  bool isInWishlist(String productId) {
    return _wishlistItems.any((product) => product.id == productId);
  }

  // 찜 여부 확인 (API)
  Future<bool> checkInWishlist(String userId, String productId) async {
    try {
      return await _apiService.checkInWishlist(
        userId: userId,
        productId: productId,
      );
    } catch (e) {
      debugPrint('Error checking wishlist: $e');
      return false;
    }
  }

  // 찜 토글
  Future<bool> toggleWishlist(String userId, String productId) async {
    if (isInWishlist(productId)) {
      return await removeFromWishlist(userId, productId);
    } else {
      return await addToWishlist(userId, productId);
    }
  }

  // 위시리스트 개수 조회
  Future<void> fetchWishlistCount(String userId) async {
    try {
      _count = await _apiService.getWishlistCount(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching wishlist count: $e');
    }
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
