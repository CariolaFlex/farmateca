// lib/widgets/premium_locked_section.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget reutilizable que muestra contenido bloqueado para usuarios Free.
/// Al tocar, navega al PaywallScreen para mostrar planes Premium.
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

    return InkWell(
      onTap: onUpgradePressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFF8E1).withAlpha(isDark ? 51 : 77),
              const Color(0xFFFFE082).withAlpha(isDark ? 38 : 51),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.premiumGold.withAlpha(77),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Icono de candado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.premiumGold.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock,
                color: AppColors.premiumGold,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),

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
              ),
            ),
            const SizedBox(height: 16),

            // Botón de upgrade
            ElevatedButton.icon(
              onPressed: onUpgradePressed,
              icon: const Icon(Icons.star, size: 18),
              label: const Text('Ver Planes Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.premiumGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
