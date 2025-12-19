// lib/providers/onboarding_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  // Estado interno
  bool _isCompleted = false;
  int _currentPage = 0;
  final int _totalPages = 3;

  // PageController para el PageView
  final PageController pageController = PageController();

  // ============================================================
  // GETTERS
  // ============================================================

  /// Indica si el onboarding ya fue completado
  bool get isCompleted => _isCompleted;

  /// Alias para compatibilidad con código legacy
  bool get hasSeenOnboarding => _isCompleted;

  /// Página actual del onboarding (0-indexed)
  int get currentPage => _currentPage;

  /// Indica si está en la última página
  bool get isLastPage => _currentPage >= _totalPages - 1;

  /// Indica si está en la primera página
  bool get isFirstPage => _currentPage == 0;

  /// Total de páginas del onboarding
  int get totalPages => _totalPages;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  OnboardingProvider() {
    _loadOnboardingStatus();
  }

  // ============================================================
  // MÉTODOS PRIVADOS
  // ============================================================

  /// Carga el estado del onboarding desde SharedPreferences
  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isCompleted = prefs.getBool('onboarding_complete') ?? false;
      notifyListeners();
    } catch (e) {
      // Si hay error, asumimos que no está completado
      _isCompleted = false;
    }
  }

  // ============================================================
  // MÉTODOS PÚBLICOS - NAVEGACIÓN
  // ============================================================

  /// Actualiza la página actual cuando el usuario hace swipe
  void updatePage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  /// Avanza a la siguiente página
  void nextPage() {
    if (!isLastPage) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Retrocede a la página anterior
  void previousPage() {
    if (!isFirstPage) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Salta a una página específica
  void goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ============================================================
  // MÉTODOS PÚBLICOS - ESTADO
  // ============================================================

  /// Marca el onboarding como completado y lo guarda
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      _isCompleted = true;
      notifyListeners();
    } catch (e) {
      // Si falla el guardado, igual marcamos como completado en memoria
      _isCompleted = true;
      notifyListeners();
    }
  }

  /// Resetea el onboarding (útil para testing o configuración)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', false);
      _isCompleted = false;
      _currentPage = 0;
      notifyListeners();
    } catch (e) {
      _isCompleted = false;
      _currentPage = 0;
      notifyListeners();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
