// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  // ============================================================
  // GETTERS
  // ============================================================

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  ThemeProvider() {
    _loadTheme();
  }

  // ============================================================
  // MÉTODOS PRIVADOS
  // ============================================================

  /// Carga el tema guardado desde SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('is_dark_mode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Si hay error, usamos tema claro por defecto
      _themeMode = ThemeMode.light;
    }
  }

  // ============================================================
  // MÉTODOS PÚBLICOS
  // ============================================================

  /// Establece el modo de tema
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', mode == ThemeMode.dark);
    } catch (e) {
      // Ignorar error de guardado
    }
  }

  /// Alterna entre tema claro y oscuro
  void toggleTheme() {
    setThemeMode(
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  /// Establece tema claro
  void setLightMode() => setThemeMode(ThemeMode.light);

  /// Establece tema oscuro
  void setDarkMode() => setThemeMode(ThemeMode.dark);
}
