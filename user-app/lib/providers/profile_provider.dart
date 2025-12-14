import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 프로필 조회
  Future<void> fetchProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getUserProfile(userId);

      if (response['success'] == true) {
        _profile = response['data'];
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 프로필 업데이트
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> profileData = {};

      if (name != null) profileData['name'] = name;
      if (email != null) profileData['email'] = email;
      if (phone != null) profileData['phone'] = phone;
      if (bio != null) profileData['bio'] = bio;

      final response = await _apiService.updateUserProfile(
        userId: userId,
        profileData: profileData,
      );

      if (response['success'] == true) {
        _profile = response['data'];
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error updating profile: $e');
      notifyListeners();
      return false;
    }
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
