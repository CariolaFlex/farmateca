// lib/screens/detail/brand_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/medication_models.dart';
import '../../utils/constants.dart';
import '../../services/database_helper.dart';
import '../../widgets/premium_locked_section.dart';
import '../paywall_screen.dart';
import 'compound_detail_screen.dart';

class BrandDetailScreen extends StatefulWidget {
  final Marca marca;

  const BrandDetailScreen({super.key, required this.marca});

  @override
  State<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends State<BrandDetailScreen> {
  Marca get marca => widget.marca;

  // TODO: Implementar lógica real con RevenueCat cuando esté configurado
  bool get isUserPremium => false; // Por ahora todos FREE para testing

  void _navigateToPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGenerico = marca.tipoM.toLowerCase().contains('genérico') ||
        marca.tipoM.toLowerCase().contains('generico');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con gradiente (diferente color para marcas)
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.secondaryTeal,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                marca.ma,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.secondaryTeal, Color(0xFF00ACC1)],
                  ),
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
                          Icons.local_pharmacy,
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
                  // Badges de acceso y tipo
                  Row(
                    children: [
                      _buildAccessBadge(),
                      const SizedBox(width: 8),
                      _buildTypeBadge(isGenerico),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // === SECCIÓN: PRINCIPIO ACTIVO (BOTÓN NAVEGABLE) ===
                  _buildActiveIngredientButton(isDark),

                  // === SECCIÓN: LABORATORIO (GRATIS) ===
                  _buildInfoCard(
                    icon: Icons.business,
                    title: 'Laboratorio',
                    content: marca.labM.isNotEmpty
                        ? marca.labM
                        : 'No especificado',
                    color: AppColors.primaryBlue,
                    isDark: isDark,
                  ),

                  // === SECCIÓN: FAMILIA (GRATIS) ===
                  if (marca.familiaM.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.category,
                      title: 'Familia Farmacológica',
                      content: marca.familiaM,
                      color: AppColors.primaryBlue,
                      isDark: isDark,
                    ),

                  // === SECCIÓN: USO (GRATIS) ===
                  if (marca.usoM.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.medical_information,
                      title: 'Uso Clínico',
                      content: marca.usoM,
                      color: AppColors.secondaryTeal,
                      isDark: isDark,
                    ),

                  // === SECCIÓN: VÍA DE ADMINISTRACIÓN (PREMIUM 🔒) ===
                  if (marca.viaM.isNotEmpty)
                    _buildConditionalSection(
                      icon: Icons.healing,
                      title: 'Vía de Administración',
                      content: marca.viaM,
                      color: AppColors.successGreen,
                      isDark: isDark,
                      isPremium: true,
                    ),

                  // === SECCIÓN: PRESENTACIÓN (PREMIUM 🔒) ===
                  if (marca.presentacionM.isNotEmpty)
                    _buildConditionalSection(
                      icon: Icons.inventory_2,
                      title: 'Presentación',
                      content: marca.presentacionM,
                      color: AppColors.warningOrange,
                      isDark: isDark,
                      isPremium: true,
                    ),

                  // === SECCIÓN: CONTRAINDICACIONES (PREMIUM 🔒) ===
                  if (marca.contraindicacionesM.isNotEmpty)
                    _buildConditionalSection(
                      icon: Icons.dangerous,
                      title: 'Contraindicaciones',
                      content: marca.contraindicacionesM,
                      color: AppColors.alertRed,
                      isDark: isDark,
                      isPremium: true,
                      contentColor: AppColors.alertRed,
                    ),

                  const SizedBox(height: 24),

                  // === FOOTER: FUENTES + DESCARGO ===
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

  /// Badge que indica acceso GRATIS
  Widget _buildAccessBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_open,
            size: 14,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            'GRATIS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge de tipo (Genérico o Comercial)
  Widget _buildTypeBadge(bool isGenerico) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isGenerico ? Colors.blue.shade100 : Colors.purple.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isGenerico ? 'GENÉRICO' : 'COMERCIAL',
        style: TextStyle(
          color: isGenerico ? Colors.blue.shade700 : Colors.purple.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Botón navegable al principio activo
  Widget _buildActiveIngredientButton(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToCompound(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.science,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Principio Activo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        marca.paM,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navegar al compuesto correspondiente
  Future<void> _navigateToCompound() async {
    final dbHelper = DatabaseHelper();
    try {
      final compuesto = await dbHelper.getCompuestoById(marca.idPam);
      if (compuesto != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompoundDetailScreen(compuesto: compuesto),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compuesto no encontrado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar compuesto: $e')),
        );
      }
    }
  }

  /// Card de información simple (siempre visible)
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

  /// Card expandible (para secciones gratuitas)
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
                      contentColor ?? (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sección condicional: muestra contenido o bloqueo premium
  Widget _buildConditionalSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required bool isDark,
    required bool isPremium,
    Color? contentColor,
  }) {
    // Si es sección premium y el usuario NO es premium, mostrar bloqueo
    if (isPremium && !isUserPremium) {
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
                color: AppColors.premiumGold.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock,
                color: AppColors.premiumGold,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Icon(icon, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Icon(
                  Icons.star,
                  color: AppColors.premiumGold,
                  size: 16,
                ),
              ],
            ),
            children: [
              PremiumLockedSection(
                sectionTitle: title.toLowerCase(),
                onUpgradePressed: _navigateToPaywall,
              ),
            ],
          ),
        ),
      );
    }

    // Usuario Premium o sección gratuita: mostrar contenido
    return _buildExpandableCard(
      icon: icon,
      title: title,
      content: content,
      color: color,
      isDark: isDark,
      contentColor: contentColor,
    );
  }

  /// Footer con fuentes + descargo de disponibilidad (SOLO EN MARCAS)
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
          const SizedBox(height: 12),
          // Descargo adicional para marcas
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.amber.shade900.withAlpha(51)
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? Colors.amber.shade700.withAlpha(77)
                    : Colors.amber.shade200,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Información obtenida de registro ISP a la fecha: Diciembre, 2025. '
                    'Las marcas y genéricos mostrados son los registrados, no necesariamente '
                    'los disponibles en farmacia en este momento.',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? Colors.amber.shade200
                          : Colors.amber.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
