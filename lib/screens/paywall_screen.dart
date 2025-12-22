// lib/screens/paywall_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';

/// Pantalla de Paywall con diseño premium futurista.
/// Por ahora SIN integración RevenueCat (solo UI mockeada).
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedPlanIndex = 1; // Anual seleccionado por defecto

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Header con gradiente
                _buildHeader(),

                const SizedBox(height: 32),

                // Planes de suscripción
                _buildPlans(),

                const SizedBox(height: 32),

                // Características premium
                _buildFeatures(),

                const SizedBox(height: 32),

                // Botón de suscripción
                _buildSubscribeButton(),

                const SizedBox(height: 16),

                // Botón restaurar compras
                _buildRestoreButton(),

                const SizedBox(height: 24),

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

            // Título
            const Text(
              'Farmateca Premium',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Acceso completo a toda la información farmacológica',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlans() {
    return Column(
      children: [
        // Plan Anual (recomendado)
        FadeInUp(
          delay: const Duration(milliseconds: 200),
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
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedPlanIndex == 1
                            ? AppColors.primaryDark
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: _selectedPlanIndex == 1
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
                  ),

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
                            // Badge ahorro
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.premiumGold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'AHORRA 20%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r'CLP $28.990/año',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          r'Solo $2.416 al mes',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600,
                          ),
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
          delay: const Duration(milliseconds: 300),
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
                  // Radio button
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedPlanIndex == 0
                            ? AppColors.primaryDark
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: _selectedPlanIndex == 0
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
                  ),

                  const SizedBox(width: 16),

                  // Info del plan
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
                        const SizedBox(height: 4),
                        Text(
                          r'CLP $2.990/mes',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
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

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.check_circle,
        'title': 'Acceso completo',
        'subtitle': 'Más de 450 compuestos farmacológicos',
      },
      {
        'icon': Icons.local_pharmacy,
        'title': 'Información detallada',
        'subtitle': 'Posología, efectos adversos y contraindicaciones',
      },
      {
        'icon': Icons.medical_information,
        'title': 'Base de datos actualizada',
        'subtitle': 'Registro ISP Chile y guías MINSAL',
      },
      {
        'icon': Icons.wifi_off,
        'title': 'Funciona sin internet',
        'subtitle': 'Acceso offline a toda la información',
      },
      {
        'icon': Icons.favorite,
        'title': 'Favoritos ilimitados',
        'subtitle': 'Guarda todos tus medicamentos frecuentes',
      },
      {
        'icon': Icons.update,
        'title': 'Actualizaciones constantes',
        'subtitle': 'Nuevos compuestos y marcas regularmente',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInLeft(
          delay: const Duration(milliseconds: 400),
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
            delay: Duration(milliseconds: 500 + (index * 100)),
            duration: const Duration(milliseconds: 600),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  // Ícono
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          feature['subtitle'] as String,
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
        }),
      ],
    );
  }

  Widget _buildSubscribeButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 1000),
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
                    ? r'Suscribirse - $28.990/año'
                    : r'Suscribirse - $2.990/mes',
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
      delay: const Duration(milliseconds: 1100),
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
              fontSize: 15,
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
      delay: const Duration(milliseconds: 1200),
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
          'Por ahora, toda la app está en modo beta gratuito.',
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
