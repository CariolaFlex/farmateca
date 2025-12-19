// lib/screens/onboarding_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Página actual
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSlide1(isDark),
                  _buildSlide2(isDark),
                  _buildSlide3(isDark),
                ],
              ),
            ),

            // Indicador de páginas
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryBlue
                          : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Botones de navegación
            if (_currentPage < 2)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _skipToEnd,
                      child: Text(
                        'Saltar',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Siguiente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (_currentPage == 2)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _completeOnboarding();
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add, size: 22),
                            SizedBox(width: 12),
                            Text(
                              'Crear Cuenta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await _completeOnboarding();
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 22),
                            SizedBox(width: 12),
                            Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SLIDE 1: Funcionamiento Offline
  // ============================================
  Widget _buildSlide1(bool isDark) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono animado
            Pulse(
              infinite: true,
              duration: const Duration(seconds: 2),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryBlue.withAlpha(51),
                      AppColors.primaryBlue.withAlpha(13),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withAlpha(51),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storage_rounded,
                  size: 70,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Título
            Text(
              'Funciona Sin Internet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Descripción
            Text(
              'Accede a toda la información farmacológica sin conexión. '
              'Base de datos local SQLite con 150 compuestos y 553 marcas.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SLIDE 2: Búsqueda Inteligente
  // ============================================
  Widget _buildSlide2(bool isDark) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono animado con bounce
            Bounce(
              infinite: true,
              duration: const Duration(seconds: 2),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.successGreen.withAlpha(51),
                      AppColors.successGreen.withAlpha(13),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.successGreen.withAlpha(51),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 70,
                  color: AppColors.successGreen,
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Título
            Text(
              'Búsqueda Inteligente',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.successGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Descripción
            Text(
              'Encuentra medicamentos por nombre comercial, principio activo '
              'o familia farmacológica en segundos.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SLIDE 3: TU VIAJE EN SALUD (MORPHING FUTURISTA)
  // ============================================
  Widget _buildSlide3(bool isDark) {
    return _AnimatedJourneySlide(isDark: isDark);
  }
}

// ============================================
// WIDGET STATEFUL PARA ANIMACIÓN MORPHING
// ============================================
class _AnimatedJourneySlide extends StatefulWidget {
  final bool isDark;

  const _AnimatedJourneySlide({required this.isDark});

  @override
  State<_AnimatedJourneySlide> createState() => _AnimatedJourneySlideState();
}

class _AnimatedJourneySlideState extends State<_AnimatedJourneySlide> {
  int _currentState = 0; // 0: Estudiante, 1: Interno, 2: Profesional
  Timer? _timer;

  final List<Map<String, dynamic>> _states = [
    {
      'icon': Icons.school_rounded,
      'color': const Color(0xFF00BCD4), // Cyan
      'title': 'Domina tu Aprendizaje',
      'subtitle': 'ESTUDIANTE',
      'description':
          'Conceptos complejos simplificados y herramientas de estudio inteligentes para destacar en cada examen.',
    },
    {
      'icon': Icons.local_hospital_rounded,
      'color': const Color(0xFF9C27B0), // Púrpura
      'title': 'Seguridad en la Práctica',
      'subtitle': 'INTERNO',
      'description':
          'Tu salvavidas en la guardia. Accede a protocolos rápidos y guías clínicas validadas justo cuando más las necesitas.',
    },
    {
      'icon': Icons.workspace_premium_rounded,
      'color': const Color(0xFFFFB800), // Dorado
      'title': 'Excelencia Clínica',
      'subtitle': 'PROFESIONAL',
      'description':
          'Mantente a la vanguardia. Evidencia actualizada y herramientas de precisión para decisiones de alto nivel.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startStateLoop();
  }

  void _startStateLoop() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentState = (_currentState + 1) % 3;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _states[_currentState];
    final Color currentColor = currentData['color'];

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Título fijo superior
          FadeIn(
            child: Text(
              'Tu Viaje en Salud',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white54 : Colors.grey.shade500,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Ícono con morphing
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey(_currentState),
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    currentColor.withAlpha(51),
                    currentColor.withAlpha(13),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: currentColor.withAlpha(77),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                currentData['icon'],
                size: 80,
                color: currentColor,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Subtítulo (ESTUDIANTE/INTERNO/PROFESIONAL)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Container(
              key: ValueKey('subtitle_$_currentState'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: currentColor.withAlpha(26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: currentColor.withAlpha(77),
                  width: 1,
                ),
              ),
              child: Text(
                currentData['subtitle'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: currentColor,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Título con morphing
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                ),
              );
            },
            child: Text(
              currentData['title'],
              key: ValueKey('title_$_currentState'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: currentColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          // Descripción con morphing
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Text(
              currentData['description'],
              key: ValueKey('desc_$_currentState'),
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? Colors.white70 : Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Indicadores de estado (pequeños dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isActive = index == _currentState;
              final stateColor = _states[index]['color'] as Color;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 12 : 8,
                height: isActive ? 12 : 8,
                decoration: BoxDecoration(
                  color: isActive ? stateColor : stateColor.withAlpha(77),
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: stateColor.withAlpha(128),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
