import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class AddressProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;
  Address? _selectedAddress;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Address? get selectedAddress => _selectedAddress;

  // 기본 배송지
  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  // 주소 목록 로드
  Future<void> fetchAddresses(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getAddresses(userId);

      if (response['success'] == true && response['data'] != null) {
        final addressesData = response['data'] as List;
        _addresses = addressesData
            .map((addr) => Address.fromJson(addr))
            .toList();

        // 기본 배송지가 선택되어 있지 않으면 자동 선택
        if (_selectedAddress == null && defaultAddress != null) {
          _selectedAddress = defaultAddress;
        }
      }
    } catch (e) {
      _error = e.toString();
      print('주소 목록 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 주소 추가
  Future<bool> createAddress(String userId, Map<String, dynamic> addressData) async {
    try {
      final response = await _apiService.createAddress(
        userId: userId,
        addressData: addressData,
      );

      if (response['success'] == true) {
        // 목록 다시 로드
        await fetchAddresses(userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      print('주소 추가 실패: $e');
      return false;
    }
  }

  // 주소 수정
  Future<bool> updateAddress(
    String userId,
    String addressId,
    Map<String, dynamic> addressData,
  ) async {
    try {
      final response = await _apiService.updateAddress(
        userId: userId,
        addressId: addressId,
        addressData: addressData,
      );

      if (response['success'] == true) {
        // 목록 다시 로드
        await fetchAddresses(userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      print('주소 수정 실패: $e');
      return false;
    }
  }

  // 주소 삭제
  Future<bool> deleteAddress(String userId, String addressId) async {
    try {
      final response = await _apiService.deleteAddress(
        userId: userId,
        addressId: addressId,
      );

      if (response['success'] == true) {
        // 로컬에서 제거
        _addresses.removeWhere((addr) => addr.id == addressId);

        // 선택된 주소가 삭제되면 초기화
        if (_selectedAddress?.id == addressId) {
          _selectedAddress = defaultAddress;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      print('주소 삭제 실패: $e');
      return false;
    }
  }

  // 주소 선택
  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }
}
