// lib/screens/paywall_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';

/// Pantalla de Paywall con diseño premium y técnicas de marketing SaaS.
/// Incluye sistema de Trial de 7 días + planes de suscripción.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPlanIndex = 1; // Anual seleccionado por defecto
  bool _isActivatingTrial = false;

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hasUsedTrial = authProvider.hasUsedTrial;
    final isTrialActive = authProvider.isTrialActive;
    final trialDaysRemaining = authProvider.trialDaysRemaining;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Header con gradiente
                _buildHeader(),

                const SizedBox(height: 24),

                // Si trial activo, mostrar countdown
                if (isTrialActive) ...[
                  _buildTrialActiveCard(trialDaysRemaining),
                  const SizedBox(height: 24),
                ],

                // Sección de Trial (solo si no ha usado trial)
                if (!hasUsedTrial && !isTrialActive) ...[
                  _buildTrialSection(authProvider),
                  const SizedBox(height: 24),
                ],

                // Si ya usó trial y expiró, mostrar mensaje
                if (hasUsedTrial && !isTrialActive) ...[
                  _buildTrialExpiredCard(),
                  const SizedBox(height: 24),
                ],

                // Social Proof
                _buildSocialProof(),

                const SizedBox(height: 24),

                // Planes de suscripción
                _buildPlansTitle(),
                const SizedBox(height: 16),
                _buildPlans(),

                const SizedBox(height: 24),

                // Características premium
                _buildFeatures(),

                const SizedBox(height: 24),

                // Botón de suscripción
                _buildSubscribeButton(),

                const SizedBox(height: 12),

                // Botón restaurar compras
                _buildRestoreButton(),

                const SizedBox(height: 20),

                // Footer legal
                _buildLegalFooter(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryMedium,
              AppColors.secondaryLight,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMedium.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Ícono premium
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 40,
                color: AppColors.premiumGold,
              ),
            ),

            const SizedBox(height: 16),

            // Título persuasivo
            const Text(
              'Desbloquea Todo el Potencial',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Únete a miles de profesionales de la salud que confían en Farmateca',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialSection(AuthProvider authProvider) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 600),
      child: AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.premiumGold.withValues(alpha: 0.15),
                AppColors.premiumGold.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.premiumGold,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.premiumGold.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Ícono de regalo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.premiumGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: 32,
                  color: AppColors.premiumGold,
                ),
              ),

              const SizedBox(height: 12),

              // Título
              const Text(
                'Prueba GRATIS por 7 días',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              Text(
                'Acceso completo a todas las funcionalidades.\nSin tarjeta de crédito.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.visible,
              ),

              const SizedBox(height: 16),

              // Botón CTA Trial
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isActivatingTrial
                      ? null
                      : () => _activateTrial(authProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premiumGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.premiumGold.withValues(alpha: 0.4),
                  ),
                  child: _isActivatingTrial
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Comenzar Prueba Gratuita',
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

              // Disclaimer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cancela cuando quieras. Sin compromisos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrialActiveCard(int daysRemaining) {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.successGreen.withValues(alpha: 0.15),
              AppColors.primaryLight.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.successGreen.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.successGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prueba Gratuita Activa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Te quedan $daysRemaining día${daysRemaining != 1 ? 's' : ''} de acceso Premium',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
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

  Widget _buildTrialExpiredCard() {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer_off,
                color: Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu prueba gratuita ha finalizado',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Suscríbete para continuar con acceso Premium',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
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

  Widget _buildSocialProof() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Estrellas
            ...List.generate(
              5,
              (index) => const Icon(
                Icons.star,
                color: AppColors.premiumGold,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Más de 1,000 profesionales confían en Farmateca',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansTitle() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 600),
      child: const Text(
        'Planes de Suscripción',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPlans() {
    return Column(
      children: [
        // Plan Anual (recomendado)
        FadeInUp(
          delay: const Duration(milliseconds: 450),
          duration: const Duration(milliseconds: 600),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlanIndex = 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedPlanIndex == 1
                    ? AppColors.primaryLight.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                border: Border.all(
                  color: _selectedPlanIndex == 1
                      ? AppColors.primaryDark
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _selectedPlanIndex == 1
                    ? [
                        BoxShadow(
                          color: AppColors.primaryMedium.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  // Radio button
                  _buildRadioButton(_selectedPlanIndex == 1),

                  const SizedBox(width: 16),

                  // Info del plan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Premium Anual',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Badge MEJOR VALOR
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.premiumGold,
                                    AppColors.premiumGold.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'AHORRA 40%',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              r'$2.990',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              ' /mes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              r'Facturado $35.880/año',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r'$59.880',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
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
          ),
        ),

        // Plan Mensual
        FadeInUp(
          delay: const Duration(milliseconds: 500),
          duration: const Duration(milliseconds: 600),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlanIndex = 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedPlanIndex == 0
                    ? AppColors.primaryLight.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                border: Border.all(
                  color: _selectedPlanIndex == 0
                      ? AppColors.primaryDark
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _selectedPlanIndex == 0
                    ? [
                        BoxShadow(
                          color: AppColors.primaryMedium.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  _buildRadioButton(_selectedPlanIndex == 0),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium Mensual',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              r'$4.990',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              ' /mes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
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
          ),
        ),
      ],
    );
  }

  Widget _buildRadioButton(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primaryDark : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryDark,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.filter_alt,
        'title': 'Filtros avanzados',
        'subtitle': 'Busca por familia, laboratorio y tipo',
      },
      {
        'icon': Icons.science,
        'title': 'Información completa',
        'subtitle': 'Posología, efectos adversos, interacciones',
      },
      {
        'icon': Icons.medication,
        'title': '200+ compuestos y 2,500+ marcas',
        'subtitle': 'Base de datos actualizada constantemente',
      },
      {
        'icon': Icons.wifi_off,
        'title': 'Acceso offline',
        'subtitle': 'Funciona sin conexión a internet',
      },
      {
        'icon': Icons.favorite,
        'title': 'Favoritos ilimitados',
        'subtitle': 'Guarda todos tus medicamentos frecuentes',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Soporte prioritario',
        'subtitle': 'Respuesta rápida a tus consultas',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 550),
          duration: const Duration(milliseconds: 600),
          child: const Text(
            '¿Qué incluye Premium?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...features.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> feature = entry.value;

          return FadeInLeft(
            delay: Duration(milliseconds: 600 + (index * 80)),
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  // Checkmark verde
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.successGreen,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          feature['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubscribeButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 900),
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryMedium,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMedium.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: Implementar compra con RevenueCat
              _showComingSoonDialog();
            },
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                _selectedPlanIndex == 1
                    ? r'Suscribirse - $35.880/año'
                    : r'Suscribirse - $4.990/mes',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 950),
      duration: const Duration(milliseconds: 600),
      child: Center(
        child: TextButton(
          onPressed: () {
            // TODO: Implementar restauración de compras
            _showComingSoonDialog();
          },
          child: const Text(
            'Restaurar Compras',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalFooter() {
    return FadeIn(
      delay: const Duration(milliseconds: 1000),
      duration: const Duration(milliseconds: 600),
      child: Text(
        'Al suscribirte, aceptas los Términos de Servicio y la Política de Privacidad. La suscripción se renueva automáticamente a menos que se cancele 24 horas antes del fin del período.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade500,
          height: 1.4,
        ),
      ),
    );
  }

  Future<void> _activateTrial(AuthProvider authProvider) async {
    setState(() => _isActivatingTrial = true);

    final success = await authProvider.activateTrial();

    setState(() => _isActivatingTrial = false);

    if (success && mounted) {
      // Mostrar diálogo de éxito
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.celebration, color: AppColors.premiumGold, size: 28),
              const SizedBox(width: 10),
              const Text('¡Prueba Activada!'),
            ],
          ),
          content: const Text(
            'Tienes 7 días de acceso Premium completo. '
            '¡Disfruta de todas las funcionalidades!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Cerrar PaywallScreen
              },
              child: Text(
                'Comenzar a explorar',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (mounted) {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo activar la prueba. Intenta nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            const Text('Próximamente'),
          ],
        ),
        content: const Text(
          'El sistema de suscripciones estará disponible pronto. '
          'Por ahora, usa la Prueba Gratuita de 7 días para acceder a todas las funciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Entendido',
              style: TextStyle(color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}
