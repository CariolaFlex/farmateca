// lib/screens/paywall_screen.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Pantalla de Paywall que muestra los planes Premium disponibles.
/// Por ahora SIN integración RevenueCat (solo UI mockeada).
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.primaryBlue),
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
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes Premium'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header con icono premium
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.premiumGold.withAlpha(26),
                    AppColors.premiumGold.withAlpha(13),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 80,
                color: AppColors.premiumGold,
              ),
            ),
            const SizedBox(height: 16),

            // Título principal
            Text(
              'Desbloquea Todo el Contenido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Accede a posología, efectos adversos, contraindicaciones y más.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Plan Mensual
            _buildPlanCard(
              context: context,
              title: 'Premium Mensual',
              icon: Icons.diamond,
              price: 'CLP \$2.990/mes',
              features: const [
                'Acceso completo a 150 compuestos',
                'Posología detallada',
                'Efectos adversos y contraindicaciones',
                'Acceso a todas las marcas',
                'Actualizaciones constantes',
              ],
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            // Plan Anual (Recomendado)
            _buildPlanCard(
              context: context,
              title: 'Premium Anual',
              icon: Icons.emoji_events,
              subtitle: 'AHORRA 20%',
              price: 'CLP \$28.990/año',
              features: const [
                'Todo lo del plan mensual',
                'Ahorra \$7.000 al año',
                'Prioridad en soporte',
                'Acceso anticipado a nuevas funciones',
              ],
              isRecommended: true,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Restaurar compras
            TextButton.icon(
              onPressed: () => _showComingSoonDialog(context),
              icon: Icon(
                Icons.restore,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
              label: Text(
                'Restaurar Compras',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Términos
            Text(
              'Al suscribirte, aceptas los Términos de Servicio y la Política de Privacidad. '
              'La suscripción se renueva automáticamente a menos que se cancele 24 horas antes del fin del período.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    String? subtitle,
    required String price,
    required List<String> features,
    bool isRecommended = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isRecommended
            ? const LinearGradient(
                colors: [Color(0xFFFFE082), AppColors.premiumGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isRecommended ? null : (isDark ? AppColors.cardDark : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended ? AppColors.premiumGold : Colors.grey.shade300,
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color: AppColors.premiumGold.withAlpha(51),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del plan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: isRecommended ? Colors.white : AppColors.premiumGold,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isRecommended ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
              if (subtitle != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Precio
          Text(
            price,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isRecommended ? Colors.white : AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Features
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isRecommended ? Colors.white : AppColors.successGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: isRecommended ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),

          // Botón de selección
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showComingSoonDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended ? Colors.white : AppColors.primaryBlue,
                foregroundColor: isRecommended ? AppColors.premiumGold : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: isRecommended ? 0 : 2,
              ),
              child: Text(
                isRecommended ? 'Seleccionar Plan Anual' : 'Seleccionar Plan',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
