import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // 장바구니 로드 (서버에서)
  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCart();

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final itemsData = data['items'] as List? ?? [];

        _items = itemsData.map((item) {
          // 백엔드에서 product 정보를 포함해서 반환
          final product = Product.fromJson(item['product']);
          return CartItem(
            id: item['cartItemId'],
            product: product,
            quantity: item['quantity'],
          );
        }).toList();
      }
    } catch (e) {
      _error = e.toString();
      print('장바구니 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 장바구니에 상품 추가 (서버와 동기화)
  Future<void> addItem(Product product, {int quantity = 1}) async {
    try {
      await _apiService.addToCart(
        productId: product.id,
        quantity: quantity,
      );

      // 성공하면 로컬 상태 업데이트
      final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

      if (existingIndex >= 0) {
        _items[existingIndex].quantity += quantity;
      } else {
        _items.add(CartItem(
          id: DateTime.now().toString(), // 임시 ID, 서버에서 실제 ID 받아야 함
          product: product,
          quantity: quantity,
        ));
      }

      notifyListeners();

      // 장바구니 다시 로드해서 서버 데이터와 동기화
      await fetchCart();
    } catch (e) {
      _error = e.toString();
      print('장바구니 추가 실패: $e');
      rethrow;
    }
  }

  // 장바구니 아이템 삭제
  Future<void> removeItem(String cartItemId) async {
    try {
      await _apiService.removeCartItem(cartItemId);

      // 로컬 상태 업데이트
      _items.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('장바구니 삭제 실패: $e');
      rethrow;
    }
  }

  // 수량 변경
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      await _apiService.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      // 로컬 상태 업데이트
      final index = _items.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        if (quantity <= 0) {
          _items.removeAt(index);
        } else {
          _items[index].quantity = quantity;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      print('수량 변경 실패: $e');
      rethrow;
    }
  }

  // 장바구니 비우기
  Future<void> clear() async {
    try {
      await _apiService.clearCart();
      _items.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('장바구니 비우기 실패: $e');
      rethrow;
    }
  }

  // 로컬 전용 메서드 (오프라인 지원)
  void addItemLocally(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: DateTime.now().toString(),
        product: product,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void clearLocally() {
    _items.clear();
    notifyListeners();
  }
}
