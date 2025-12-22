// lib/services/developer_mode_service.dart

import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el Modo Desarrollador Premium.
/// Permite activar/desactivar acceso Premium para testing sin RevenueCat.
/// Este modo solo debe usarse en desarrollo y no afecta datos en Firestore.
class DeveloperModeService {
  static const String _developerPremiumKey = 'developer_premium_mode';

  /// Singleton pattern
  static final DeveloperModeService _instance = DeveloperModeService._internal();
  factory DeveloperModeService() => _instance;
  DeveloperModeService._internal();

  /// Verifica si el Modo Desarrollador Premium está activo.
  /// Retorna `true` si está activo, `false` en caso contrario.
  Future<bool> isDeveloperPremiumActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_developerPremiumKey) ?? false;
  }

  /// Activa o desactiva el Modo Desarrollador Premium.
  /// [value] - `true` para activar, `false` para desactivar.
  Future<void> setDeveloperPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_developerPremiumKey, value);
  }

  /// Alterna el estado actual del Modo Desarrollador Premium.
  /// Retorna el nuevo estado después de alternar.
  Future<bool> toggleDeveloperPremium() async {
    final currentState = await isDeveloperPremiumActive();
    final newState = !currentState;
    await setDeveloperPremium(newState);
    return newState;
  }
}
