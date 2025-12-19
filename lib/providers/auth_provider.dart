import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  bool _isLoading = false;
  bool _initialized = false;
  String? _lastError;

  AuthProvider() {
    print('[AuthProvider] initializing and loading prefs');
    // Delay loading prefs so notifyListeners() is not called synchronously
    // during widget build (avoids "setState/markNeedsBuild called during build" errors).
    Future.delayed(Duration.zero, () => _loadFromPrefs());
  }

  bool get isInitialized => _initialized;
  String? get lastError => _lastError;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    print('[AuthProvider] login requested for $username');
    _lastError = null;
    try {
      _currentUser = await _apiService.login(username, password);
    } catch (e) {
      _lastError = 'Error during login: $e';
      print('[AuthProvider] $_lastError');
    }
    print('[AuthProvider] login result: ${_currentUser != null}');

    if (_currentUser != null) {
      await _saveToPrefs(_currentUser!);
      _lastError = null;
    }

    _isLoading = false;
    notifyListeners();
    if (_currentUser == null) {
      _lastError ??= 'Login gagal: cek username/password atau koneksi.';
    }
    return _currentUser != null;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  Future<void> _saveToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('user');
    if (s != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(s) as Map<String, dynamic>);
        notifyListeners();
      } catch (_) {}
    }
    _initialized = true;
    notifyListeners();
  }
}