// lib/providers/preferences_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  AppPreferences _preferences = AppPreferences();
  AppPreferences get preferences => _preferences;

  // Fuentes disponibles
  static const List<String> availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Raleway',
    'Poppins',
  ];

  // Tamaños de fuente
  static const double minFontSize = 12.0;
  static const double maxFontSize = 24.0;
  static const double defaultFontSize = 16.0;

  PreferencesProvider() {
    _loadPreferences();
  }

  // Cargar preferencias guardadas
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _preferences = AppPreferences(
      fontFamily: prefs.getString('fontFamily') ?? 'Roboto',
      fontSize: prefs.getDouble('fontSize') ?? 16.0,
    );
    notifyListeners();
  }

  // Cambiar fuente
  Future<void> setFontFamily(String fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', fontFamily);
    _preferences = _preferences.copyWith(fontFamily: fontFamily);
    notifyListeners();
  }

  // Cambiar tamaño
  Future<void> setFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
    _preferences = _preferences.copyWith(fontSize: fontSize);
    notifyListeners();
  }

  // Getter para textScaleFactor global
  double get textScaleFactor {
    return _preferences.fontSize / 16.0;
  }

  // Obtener TextTheme personalizado
  TextTheme getTextTheme(TextTheme base) {
    final double scaleFactor = _preferences.fontSize / 16.0;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.displayLarge?.fontSize ?? 57) * scaleFactor,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.displayMedium?.fontSize ?? 45) * scaleFactor,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.displaySmall?.fontSize ?? 36) * scaleFactor,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.headlineLarge?.fontSize ?? 32) * scaleFactor,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.headlineMedium?.fontSize ?? 28) * scaleFactor,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.headlineSmall?.fontSize ?? 24) * scaleFactor,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.titleLarge?.fontSize ?? 22) * scaleFactor,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.titleMedium?.fontSize ?? 16) * scaleFactor,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.titleSmall?.fontSize ?? 14) * scaleFactor,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.bodyLarge?.fontSize ?? 16) * scaleFactor,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.bodyMedium?.fontSize ?? 14) * scaleFactor,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.bodySmall?.fontSize ?? 12) * scaleFactor,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.labelLarge?.fontSize ?? 14) * scaleFactor,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.labelMedium?.fontSize ?? 12) * scaleFactor,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: _preferences.fontFamily,
        fontSize: (base.labelSmall?.fontSize ?? 11) * scaleFactor,
      ),
    );
  }
}
