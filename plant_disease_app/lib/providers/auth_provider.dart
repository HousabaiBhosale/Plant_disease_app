import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  String? _error;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  
  AuthProvider() {
    checkAuthStatus();
  }
  
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _isAuthenticated = await AuthService.isLoggedIn();
      if (_isAuthenticated) {
        _user = await AuthService.getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await AuthService.login(email: email, password: password);
      _isAuthenticated = true;
      _user = result['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString().contains('Invalid credentials') || e.toString().contains('401')) {
        _error = 'Invalid email or password. Please try again.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
        _error = 'Cannot connect to server. Make sure backend is running.';
      } else if (e.toString().contains('Exception: ')) {
        _error = e.toString().replaceAll('Exception: ', '');
      } else {
        _error = 'An error occurred. Please try again later.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _user = result['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
        _error = 'Cannot connect to server. Make sure backend is running.';
      } else if (e.toString().contains('Exception: ')) {
        _error = e.toString().replaceAll('Exception: ', '');
      } else {
        _error = 'An error occurred during registration. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await AuthService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
