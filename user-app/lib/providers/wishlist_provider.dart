import 'package:flutter/foundation.dart';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  List<Product> _wishlistItems = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get wishlistItems => _wishlistItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _wishlistItems.length;

  // 찜 목록 조회 (스텁 구현)
  Future<void> fetchWishlist(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: 나중에 실제 API 연동 필요
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 찜 추가 (스텁 구현)
  Future<bool> addToWishlist(String userId, String productId) async {
    try {
      // TODO: 나중에 실제 API 연동 필요
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding to wishlist: $e');
      notifyListeners();
      return false;
    }
  }

  // 찜 제거 (스텁 구현)
  Future<bool> removeFromWishlist(String userId, String productId) async {
    try {
      // TODO: 나중에 실제 API 연동 필요
      _wishlistItems.removeWhere((product) => product.id == productId);
      notifyListeners();
      return true;
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

  // 찜 토글
  Future<bool> toggleWishlist(String userId, String productId) async {
    if (isInWishlist(productId)) {
      return await removeFromWishlist(userId, productId);
    } else {
      return await addToWishlist(userId, productId);
    }
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
