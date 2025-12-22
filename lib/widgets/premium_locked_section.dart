// lib/widgets/premium_locked_section.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Widget reutilizable que muestra contenido bloqueado para usuarios Free.
/// Diseño futurista consistente con el PaywallScreen.
class PremiumLockedSection extends StatelessWidget {
  final String sectionTitle;
  final VoidCallback onUpgradePressed;

  const PremiumLockedSection({
    super.key,
    required this.sectionTitle,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: isDark ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryMedium.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Ícono de candado con gradiente teal
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primaryMedium,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryMedium.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_outline,
              color: AppColors.premiumGold,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          // Título
          Text(
            'Contenido Premium',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Descripción
          Text(
            'Actualiza a Premium para ver $sectionTitle y toda la información clínica completa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Botón "Ver Planes Premium" con gradiente
          GestureDetector(
            onTap: onUpgradePressed,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primaryMedium,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMedium.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onUpgradePressed,
                  borderRadius: BorderRadius.circular(12),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: AppColors.premiumGold,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ver Planes Premium',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
