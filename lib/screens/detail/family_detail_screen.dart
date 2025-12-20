// lib/screens/detail/family_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/medication_models.dart';
import '../../utils/app_colors.dart';
import 'compound_detail_screen.dart';

class FamilyDetailScreen extends StatelessWidget {
  final String familyName;
  final List<Compuesto> compounds;

  const FamilyDetailScreen({
    super.key,
    required this.familyName,
    required this.compounds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              familyName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${compounds.length} compuesto${compounds.length != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card
          _buildInfoCard(),
          const SizedBox(height: 20),

          // Título sección
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Compuestos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lista de compuestos
          ...compounds.map((compound) => _buildCompoundButton(context, compound)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryMedium,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.category,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              familyName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Familia Farmacológica',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompoundButton(BuildContext context, Compuesto compound) {
    // Detectar si está próximamente
    final isComingSoon = compound.uso.isEmpty ||
        compound.posologia.isEmpty ||
        compound.mecanismo.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isComingSoon ? 1 : 2,
      color: isComingSoon ? Colors.grey.shade200 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (isComingSoon) {
            _showComingSoonDialog(context, compound.pa);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompoundDetailScreen(compuesto: compound),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isComingSoon
                      ? Colors.grey.shade300
                      : AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.science,
                  color: isComingSoon
                      ? Colors.grey.shade600
                      : AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compound.pa,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isComingSoon
                            ? Colors.grey.shade700
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (isComingSoon) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.comingSoonGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRÓXIMAMENTE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isComingSoon
                    ? Colors.grey.shade400
                    : AppColors.primaryMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String compoundName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryDark, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        content: Text(
          'El compuesto "$compoundName" estará disponible pronto con toda su información farmacológica.',
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
