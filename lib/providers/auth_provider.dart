import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/developer_mode_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DeveloperModeService _devModeService = DeveloperModeService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  AuthStatus _status = AuthStatus.initial;
  bool _isDeveloperPremiumActive = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthStatus get status => _status;
  bool get isAuthenticated => _firebaseUser != null;
  String get userName => _userModel?.nombre ?? _firebaseUser?.displayName ?? '';
  String get userEmail => _userModel?.email ?? _firebaseUser?.email ?? '';

  /// Indica si el modo desarrollador premium está activo (para testing)
  bool get isDeveloperPremiumActive => _isDeveloperPremiumActive;

  /// Verifica si el usuario tiene acceso Premium.
  /// Considera: 1) Developer Mode, 2) Trial activo, 3) Suscripción real
  /// En el futuro se agregará RevenueCat aquí.
  bool get isPremium {
    // 1. Developer Mode para testing (solo en debug)
    if (_isDeveloperPremiumActive) {
      return true;
    }
    // 2. Verificar Trial activo (7 días)
    if (_userModel?.isTrialActive == true) {
      return true;
    }
    // 3. Verificar suscripción activa en UserModel
    if (_userModel?.isPremium == true) {
      return true;
    }
    // 4. Por defecto, usuario Free
    return false;
  }

  // === TRIAL GETTERS ===

  /// Indica si el trial está activo
  bool get isTrialActive => _userModel?.isTrialActive ?? false;

  /// Días restantes del trial
  int get trialDaysRemaining => _userModel?.trialDaysRemaining ?? 0;

  /// Indica si el trial está por expirar (≤2 días)
  bool get isTrialExpiring => _userModel?.isTrialExpiring ?? false;

  /// Indica si el usuario ya usó su trial
  bool get hasUsedTrial => _userModel?.hasUsedTrial ?? false;

  /// Indica si el trial ya expiró
  bool get isTrialExpired => _userModel?.isTrialExpired ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
    _loadDeveloperModeState();
  }

  /// Carga el estado del Developer Mode desde SharedPreferences
  Future<void> _loadDeveloperModeState() async {
    _isDeveloperPremiumActive = await _devModeService.isDeveloperPremiumActive();
    notifyListeners();
  }

  /// Activa o desactiva el Developer Mode Premium
  Future<void> setDeveloperPremium(bool value) async {
    await _devModeService.setDeveloperPremium(value);
    _isDeveloperPremiumActive = value;
    notifyListeners();
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

  // ==========================================
  // TRIAL DE 7 DÍAS
  // ==========================================

  /// Activa el trial de 7 días para el usuario actual.
  /// Solo se puede activar UNA VEZ por usuario.
  /// Retorna true si se activó exitosamente, false si ya lo usó o hubo error.
  Future<bool> activateTrial() async {
    if (_firebaseUser == null) {
      debugPrint('❌ No hay usuario autenticado para activar trial');
      return false;
    }

    // Verificar si ya usó el trial
    if (_userModel?.hasUsedTrial == true) {
      debugPrint('❌ Usuario ya usó su trial gratuito');
      return false;
    }

    try {
      final now = DateTime.now();
      final trialEnd = now.add(const Duration(days: 7));

      // Actualizar Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .update({
        'trial_start_date': Timestamp.fromDate(now),
        'trial_end_date': Timestamp.fromDate(trialEnd),
        'has_used_trial': true,
      });

      // Actualizar modelo local
      _userModel = _userModel?.copyWith(
        trialStartDate: now,
        trialEndDate: trialEnd,
        hasUsedTrial: true,
      );

      notifyListeners();
      debugPrint('✅ Trial activado exitosamente. Expira: $trialEnd');
      return true;
    } catch (e) {
      debugPrint('❌ Error activando trial: $e');
      return false;
    }
  }
}
