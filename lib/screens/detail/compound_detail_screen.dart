// lib/screens/detail/compound_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/medication_models.dart';
import '../../utils/constants.dart';

class CompoundDetailScreen extends StatelessWidget {
  final Compuesto compuesto;

  const CompoundDetailScreen({super.key, required this.compuesto});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con gradiente
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                compuesto.pa,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.science,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              // Botón de favorito
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Agregado a favoritos')),
                  );
                },
              ),
            ],
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge de acceso
                  Row(
                    children: [
                      _buildAccessBadge(),
                      const Spacer(),
                      Text(
                        'ID: ${compuesto.idPa}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // === SECCIÓN: FAMILIA ===
                  _buildInfoCard(
                    icon: Icons.category,
                    title: 'Familia Farmacológica',
                    content: compuesto.familia,
                    color: AppColors.primaryBlue,
                    isDark: isDark,
                  ),

                  // === SECCIÓN: USO CLÍNICO ===
                  _buildInfoCard(
                    icon: Icons.medical_information,
                    title: 'Uso Clínico',
                    content: compuesto.uso,
                    color: AppColors.secondaryTeal,
                    isDark: isDark,
                  ),

                  // === SECCIÓN: POSOLOGÍA ===
                  _buildInfoCard(
                    icon: Icons.schedule,
                    title: 'Posología',
                    content: compuesto.posologia,
                    color: AppColors.successGreen,
                    isDark: isDark,
                  ),

                  // === SECCIÓN DESPLEGABLE: CONSIDERACIONES ===
                  if (compuesto.consideraciones.isNotEmpty)
                    _buildExpandableCard(
                      icon: Icons.info_outline,
                      title: 'Consideraciones Especiales',
                      content: compuesto.consideraciones,
                      color: AppColors.warningOrange,
                      isDark: isDark,
                    ),

                  // === SECCIÓN DESPLEGABLE: MECANISMO ===
                  if (compuesto.mecanismo.isNotEmpty)
                    _buildExpandableCard(
                      icon: Icons.psychology,
                      title: 'Mecanismo de Acción',
                      content: compuesto.mecanismo,
                      color: AppColors.primaryBlue,
                      isDark: isDark,
                    ),

                  // === SECCIÓN DESPLEGABLE: MARCAS ===
                  if (compuesto.marcas.isNotEmpty)
                    _buildExpandableCard(
                      icon: Icons.local_pharmacy,
                      title: 'Marcas Comerciales',
                      content: _formatList(compuesto.marcas),
                      color: AppColors.secondaryTeal,
                      isDark: isDark,
                    ),

                  // === SECCIÓN DESPLEGABLE: EFECTOS (Verde-Azul) ===
                  if (compuesto.efectos.isNotEmpty)
                    _buildExpandableCard(
                      icon: Icons.warning_amber,
                      title: 'Efectos Adversos',
                      content: compuesto.efectos,
                      color: const Color(0xFF26A69A), // Verde-azul
                      isDark: isDark,
                      contentColor: const Color(0xFF26A69A),
                    ),

                  // === SECCIÓN DESPLEGABLE: CONTRAINDICACIONES (ROJO) ===
                  if (compuesto.contraindicaciones.isNotEmpty)
                    _buildExpandableCard(
                      icon: Icons.dangerous,
                      title: 'Contraindicaciones',
                      content: compuesto.contraindicaciones,
                      color: AppColors.alertRed,
                      isDark: isDark,
                      contentColor: AppColors.alertRed,
                    ),

                  const SizedBox(height: 24),

                  // === FOOTER: FUENTES ===
                  _buildSourcesFooter(isDark),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessBadge() {
    final isFree = compuesto.isFree;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFree ? AppColors.successGreen : AppColors.premiumGold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFree ? Icons.lock_open : Icons.star,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isFree ? 'GRATIS' : 'PREMIUM',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required bool isDark,
    Color? contentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color:
                      contentColor ??
                      (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourcesFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withAlpha(128)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.source, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Fuentes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.sourcesText,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatList(String text) {
    // Convierte "Item1; Item2; Item3" a lista con viñetas
    final items = text
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    return items.map((item) => '• $item').join('\n');
  }
}
