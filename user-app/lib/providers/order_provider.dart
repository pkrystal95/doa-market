import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // 주문 목록 로드
  Future<void> fetchOrders(String userId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _orders = [];
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMyOrders(userId, page: _currentPage);

      if (response['success'] == true && response['data'] != null) {
        final ordersData = response['data'] as List;
        final newOrders = ordersData
            .map((order) => Order.fromJson(order))
            .toList();

        if (refresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        // 페이지네이션 체크
        final totalPages = response['pagination']?['totalPages'] ?? 1;
        _hasMore = _currentPage < totalPages;
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
      print('주문 목록 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 주문 상세 조회
  Future<bool> fetchOrderDetail(String userId, String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getOrder(userId, orderId);

      if (response['success'] == true && response['data'] != null) {
        _selectedOrder = Order.fromJson(response['data']);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      print('주문 상세 조회 실패: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 주문 선택
  void selectOrder(Order order) {
    _selectedOrder = order;
    notifyListeners();
  }

  // 주문 상태별 필터링
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // 주문 상태별 개수
  int getOrderCountByStatus(String status) {
    return _orders.where((order) => order.status == status).length;
  }
}

