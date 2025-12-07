import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getProducts();

      if (response['success'] == true) {
        final List<dynamic> productsData = response['data'] ?? [];
        _products = productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        _error = '상품 목록을 불러오는데 실패했습니다';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> fetchProduct(String productId) async {
    try {
      final response = await _apiService.getProduct(productId);

      if (response['success'] == true) {
        return Product.fromJson(response['data']);
      }
    } catch (e) {
      _error = e.toString();
    }
    return null;
  }
}
