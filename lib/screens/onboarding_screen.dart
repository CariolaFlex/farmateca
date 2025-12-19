// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/onboarding_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    final slides = [
      _SlideData(
        AppStrings.onboardingTitle1,
        AppStrings.onboardingDesc1,
        Icons.cloud_off_rounded,
        AppColors.primaryBlue,
      ),
      _SlideData(
        AppStrings.onboardingTitle2,
        AppStrings.onboardingDesc2,
        Icons.search_rounded,
        AppColors.secondaryTeal,
      ),
      _SlideData(
        AppStrings.onboardingTitle3,
        AppStrings.onboardingDesc3,
        Icons.medical_services_rounded,
        AppColors.primaryBlue,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón Saltar (solo si no es última página)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!provider.isLastPage)
                    TextButton(
                      onPressed: () => _completeOnboarding(context, provider),
                      child: Text(
                        'Saltar',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
            ),

            // PageView con slides
            Expanded(
              child: PageView.builder(
                controller: provider.pageController,
                itemCount: slides.length,
                onPageChanged: provider.updatePage,
                itemBuilder: (context, index) =>
                    _buildSlide(context, slides[index]),
              ),
            ),

            // Indicadores y botones
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Indicadores de página
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (i) => Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == provider.currentPage
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botones según página actual
                  if (provider.isLastPage)
                    Column(
                      children: [
                        PrimaryButton(
                          text: 'Crear Cuenta',
                          icon: Icons.person_add_outlined,
                          onPressed: () =>
                              _completeOnboarding(context, provider),
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          text: 'Iniciar Sesión',
                          icon: Icons.login,
                          onPressed: () =>
                              _completeOnboarding(context, provider),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        if (!provider.isFirstPage) ...[
                          Expanded(
                            child: SecondaryButton(
                              text: 'Atrás',
                              onPressed: provider.previousPage,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: PrimaryButton(
                            text: 'Siguiente',
                            onPressed: provider.nextPage,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(BuildContext context, _SlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: slide.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: slide.color.withAlpha(77), // 0.3 * 255 = ~77
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(slide.icon, size: 80, color: Colors.white),
            ),
          ),
          const SizedBox(height: 48),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              slide.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding(
    BuildContext context,
    OnboardingProvider provider,
  ) async {
    await provider.completeOnboarding();

    if (context.mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }
}

class _SlideData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _SlideData(this.title, this.description, this.icon, this.color);
}
