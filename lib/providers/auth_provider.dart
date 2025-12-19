import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  AuthStatus _status = AuthStatus.initial;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthStatus get status => _status;
  bool get isAuthenticated => _firebaseUser != null;
  String get userName => _userModel?.nombre ?? _firebaseUser?.displayName ?? '';
  String get userEmail => _userModel?.email ?? _firebaseUser?.email ?? '';

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _userModel = await _authService.getCurrentUserData();
      _status = AuthStatus.authenticated;
    } else {
      _userModel = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String profesion,
    String? nivel,
    String? area,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.registerWithEmail(
      email: email,
      password: password,
      nombre: nombre,
      profesion: profesion,
      nivel: nivel,
      area: area,
    );

    _setLoading(false);

    if (result.isSuccess) {
      _userModel = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.loginWithEmail(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    _setLoading(false);

    if (result.isSuccess) {
      _userModel = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.resetPassword(email);

    _setLoading(false);

    if (!result.isSuccess) {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _firebaseUser = null;
    _userModel = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _setLoading(false);
    notifyListeners();
  }

  Future<String?> getLastEmail() async {
    return await _authService.getLastEmail();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
