import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Actualiza el perfil del usuario en Firestore
  Future<void> updateUserProfile({
    String? photoURL,
    String? alias,
    String? nivel,
    String? area,
  }) async {
    if (_firebaseUser == null || _userModel == null) return;

    try {
      final updates = <String, dynamic>{
        'ultima_sesion': Timestamp.now(),
      };

      if (photoURL != null) updates['photoURL'] = photoURL;
      if (alias != null) updates['alias'] = alias;
      if (nivel != null) updates['nivel'] = nivel;
      if (area != null) updates['area'] = area;

      // 1. Actualizar Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .update(updates);

      // 2. Actualizar Firebase Auth si hay photoURL
      if (photoURL != null) {
        await _firebaseUser!.updatePhotoURL(photoURL);
        // Recargar usuario para obtener cambios
        await _firebaseUser!.reload();
        _firebaseUser = FirebaseAuth.instance.currentUser;
      }

      // 3. Actualizar modelo local
      _userModel = _userModel!.copyWith(
        photoURL: photoURL ?? _userModel!.photoURL,
        alias: alias ?? _userModel!.alias,
        nivel: nivel ?? _userModel!.nivel,
        area: area ?? _userModel!.area,
        ultimaSesion: DateTime.now(),
      );

      // 4. Notificar cambios a todos los listeners
      notifyListeners();

      debugPrint('✅ Perfil actualizado: photoURL=$photoURL, alias=$alias');
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      rethrow;
    }
  }

  /// Recargar datos del usuario desde Firestore
  Future<void> reloadUserData() async {
    if (_firebaseUser == null) return;

    try {
      _userModel = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error reloading user data: $e');
    }
  }
}
