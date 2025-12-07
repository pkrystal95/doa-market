import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get token => _token;

  AuthProvider() {
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // TODO: API 호출하여 로그인
    // 임시로 로컬 스토리지에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', 'temp_token');
    await prefs.setString('userId', 'temp_user_id');

    _token = 'temp_token';
    _userId = 'temp_user_id';
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');

    _token = null;
    _userId = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
