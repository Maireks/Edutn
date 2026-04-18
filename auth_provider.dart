// ============================================================
// providers/auth_provider.dart - إدارة حالة المصادقة
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _adminRole;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get adminRole => _adminRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isSuperAdmin => _adminRole == 'superAdmin';
  bool get isAdmin => _adminRole == 'admin' || _adminRole == 'superAdmin';
  bool get isEditor => _adminRole == 'editor' || isAdmin;

  AuthProvider() {
    // الاستماع لتغييرات حالة المصادقة
    _authService.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        _loadAdminRole(user.uid);
      } else {
        _adminRole = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadAdminRole(String uid) async {
    _adminRole = await _authService.getCurrentAdminRole();
    notifyListeners();
  }

  // تسجيل الدخول
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.signInAdmin(email, password);

    _isLoading = false;
    if (result.success) {
      _adminRole = result.role;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _adminRole = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
