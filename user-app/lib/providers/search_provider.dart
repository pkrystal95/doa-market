import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class SearchProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _searchResults = [];
  List<String> _popularKeywords = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;
  String? _error;
  String _currentKeyword = '';

  List<Product> get searchResults => _searchResults;
  List<String> get popularKeywords => _popularKeywords;
  List<String> get searchHistory => _searchHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentKeyword => _currentKeyword;

  // 상품 검색
  Future<void> searchProducts(String keyword) async {
    if (keyword.trim().isEmpty) {
      _searchResults = [];
      _currentKeyword = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _currentKeyword = keyword;
    notifyListeners();

    try {
      final response = await _apiService.searchProducts(keyword: keyword);

      if (response['success'] == true) {
        // Handle product-service response format
        final List<dynamic> products = response['data'] is List
            ? response['data']
            : (response['data']['products'] ?? []);
        _searchResults = products.map((p) => Product.fromJson(p)).toList();
      } else {
        _searchResults = [];
      }
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
      debugPrint('Error searching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 인기 검색어 조회
  Future<void> fetchPopularKeywords() async {
    try {
      final response = await _apiService.getPopularKeywords();

      if (response['success'] == true) {
        final List<dynamic> keywords = response['data'] ?? [];
        _popularKeywords = keywords
            .map((k) => k['keyword']?.toString() ?? '')
            .where((k) => k.isNotEmpty)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching popular keywords: $e');
    }
  }

  // 검색 기록 조회
  Future<void> fetchSearchHistory(String userId) async {
    try {
      final response = await _apiService.getSearchHistory(userId);

      if (response['success'] == true) {
        final List<dynamic> history = response['data'] ?? [];
        _searchHistory = history
            .map((h) => h['keyword']?.toString() ?? '')
            .where((k) => k.isNotEmpty)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching search history: $e');
    }
  }

  // 검색 결과 초기화
  void clearSearchResults() {
    _searchResults = [];
    _currentKeyword = '';
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
