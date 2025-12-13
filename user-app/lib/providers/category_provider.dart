import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  List<Product> _categoryProducts = [];
  bool _isLoading = false;
  bool _isLoadingProducts = false;
  String? _error;
  Category? _selectedCategory;

  List<Category> get categories => _categories;
  List<Product> get categoryProducts => _categoryProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get error => _error;
  Category? get selectedCategory => _selectedCategory;

  // 카테고리 목록 로드
  Future<void> fetchCategories({String? parentId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCategories(parentId: parentId);

      if (response['success'] == true && response['data'] != null) {
        final categoriesData = response['data'] as List;
        _categories = categoriesData
            .map((cat) => Category.fromJson(cat))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      print('카테고리 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 카테고리별 상품 조회
  Future<void> fetchProductsByCategory(String categoryId,
      {int page = 1}) async {
    _isLoadingProducts = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getProductsByCategory(
        categoryId: categoryId,
        page: page,
      );

      if (response['success'] == true && response['data'] != null) {
        final productsData = response['data'] as List;
        _categoryProducts = productsData
            .map((product) => Product.fromJson(product))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
      print('카테고리 상품 로드 실패: $e');
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // 카테고리 선택
  void selectCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();

    if (category != null) {
      fetchProductsByCategory(category.id);
    }
  }

  // 최상위 카테고리만 필터링
  List<Category> get rootCategories {
    return _categories.where((cat) => cat.parentId == null).toList();
  }

  // 특정 카테고리의 하위 카테고리 조회
  List<Category> getSubcategories(String parentId) {
    return _categories.where((cat) => cat.parentId == parentId).toList();
  }
}
