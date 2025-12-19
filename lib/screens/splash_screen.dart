// lib/screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/constants.dart';
import 'onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(AppDurations.splash);

    // Verificar si el widget sigue montado
    if (!mounted) return;

    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Determinar siguiente pantalla
    Widget nextScreen;
    if (!onboardingProvider.isCompleted) {
      nextScreen = const OnboardingScreen();
    } else if (authProvider.isAuthenticated) {
      nextScreen = const HomeScreen();
    } else {
      nextScreen = const LoginScreen();
    }

    // Navegar
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // Círculo decorativo superior
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(13), // 0.05 * 255 = ~13
                ),
              ),
            ),
            // Círculo decorativo inferior
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(13),
                ),
              ),
            ),
            // Contenido central
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono animado
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38), // 0.15 * 255 = ~38
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withAlpha(
                              51,
                            ), // 0.2 * 255 = ~51
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_pharmacy_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nombre de la app
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: const Text(
                      AppStrings.appSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de carga
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: FadeIn(
                delay: const Duration(milliseconds: 800),
                child: const Column(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white54,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Cargando...',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            // Versión
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: FadeIn(
                delay: const Duration(milliseconds: 1000),
                child: const Text(
                  AppStrings.appVersion,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
