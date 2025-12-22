// lib/widgets/trial_expiring_dialog.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import '../screens/paywall_screen.dart';

/// Widget de diálogo persuasivo que aparece cuando el trial está por expirar (≤2 días).
/// Se muestra una vez al día para no molestar al usuario.
class TrialExpiringDialog {
  static const String _lastShownKey = 'trial_expiring_dialog_last_shown';

  /// Verifica si se debe mostrar el diálogo hoy
  static Future<bool> shouldShowToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getString(_lastShownKey);

      if (lastShown == null) return true;

      final lastShownDate = DateTime.tryParse(lastShown);
      if (lastShownDate == null) return true;

      final today = DateTime.now();
      final isNewDay = today.year != lastShownDate.year ||
          today.month != lastShownDate.month ||
          today.day != lastShownDate.day;

      return isNewDay;
    } catch (e) {
      return true;
    }
  }

  /// Marca que el diálogo fue mostrado hoy
  static Future<void> markAsShownToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastShownKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Silenciar error
    }
  }

  /// Muestra el diálogo de expiración de trial
  static Future<void> show(BuildContext context, int daysRemaining) async {
    // Marcar como mostrado
    await markAsShownToday();

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => _TrialExpiringDialogContent(daysRemaining: daysRemaining),
    );
  }

  /// Método de conveniencia para verificar y mostrar si es necesario
  static Future<void> showIfNeeded({
    required BuildContext context,
    required bool isTrialExpiring,
    required int daysRemaining,
  }) async {
    if (!isTrialExpiring) return;

    final shouldShow = await shouldShowToday();
    if (!shouldShow) return;

    if (!context.mounted) return;

    await show(context, daysRemaining);
  }
}

class _TrialExpiringDialogContent extends StatelessWidget {
  final int daysRemaining;

  const _TrialExpiringDialogContent({required this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ZoomIn(
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con gradiente
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade400,
                      Colors.red.shade400,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Ícono animado
                    Pulse(
                      infinite: true,
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.timer,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Título
                    Text(
                      daysRemaining == 1
                          ? 'Tu prueba termina mañana'
                          : 'Tu prueba termina en $daysRemaining días',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Subtítulo
                    Text(
                      '¡No pierdas acceso a todas las funcionalidades Premium!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista de beneficios
                    _buildBenefitItem(
                      icon: Icons.filter_alt,
                      text: 'Búsqueda avanzada con filtros',
                    ),
                    const SizedBox(height: 10),
                    _buildBenefitItem(
                      icon: Icons.science,
                      text: 'Toda la información sin límites',
                    ),
                    const SizedBox(height: 10),
                    _buildBenefitItem(
                      icon: Icons.medication,
                      text: 'Acceso a 200+ compuestos',
                    ),

                    const SizedBox(height: 24),

                    // Botón principal
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaywallScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primaryDark.withValues(alpha: 0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.workspace_premium, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Continuar con Premium',
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

                    // Botón secundario
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Recordar mañana',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: AppColors.successGreen,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
