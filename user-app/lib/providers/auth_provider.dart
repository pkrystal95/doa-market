import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _token;
  String? _userEmail;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get token => _token;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  // API Gateway를 사용하지 않고 auth service에 직접 연결 (임시)
  static const String authDirectUrl = 'http://localhost:3001/api/v1';
  static const String apiGatewayUrl = ApiService.baseUrl;

  AuthProvider() {
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.client.post(
        Uri.parse('$authDirectUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final accessToken = data['data']['accessToken'];
          final user = data['data']['user'];

          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', accessToken);
          await prefs.setString('userId', user['id']); // 'userId' -> 'id'로 수정
          await prefs.setString('userEmail', user['email']);
          await prefs.setString('userName', user['name'] ?? user['email']);

          _token = accessToken;
          _userId = user['id']; // 'userId' -> 'id'로 수정
          _userEmail = user['email'];
          _userName = user['name'] ?? user['email'];
          _isAuthenticated = true;
          notifyListeners();
        } else {
          throw Exception('로그인 실패: 잘못된 응답 형식');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '로그인에 실패했습니다');
      }
    } catch (e) {
      throw Exception('로그인 오류: $e');
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      final response = await ApiService.client.post(
        Uri.parse('$authDirectUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 회원가입 성공 후 자동 로그인
        await login(email, password);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? '회원가입에 실패했습니다');
      }
    } catch (e) {
      throw Exception('회원가입 오류: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');

    _token = null;
    _userId = null;
    _userEmail = null;
    _userName = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
