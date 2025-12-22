// lib/screens/detail/compound_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medication_models.dart';
import '../../utils/constants.dart';
import '../../utils/app_colors.dart' as teal;
import '../../services/database_helper.dart';
import '../../services/favorites_service.dart';
import '../../widgets/premium_locked_section.dart';
import '../../providers/auth_provider.dart';
import '../paywall_screen.dart';
import '../home_screen.dart';
import 'brand_detail_screen.dart';

class CompoundDetailScreen extends StatefulWidget {
  final Compuesto compuesto;

  const CompoundDetailScreen({super.key, required this.compuesto});

  @override
  State<CompoundDetailScreen> createState() => _CompoundDetailScreenState();
}

class _CompoundDetailScreenState extends State<CompoundDetailScreen> {
  Compuesto get compuesto => widget.compuesto;

  // TODO: Implementar lógica real con RevenueCat cuando esté configurado
  bool get isUserPremium => false; // Por ahora todos FREE para testing

  // === FAVORITOS ===
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isLoadingFavorite = true;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;

    if (userId != null) {
      final isFav = await _favoritesService.isCompoundFavorite(
        userId: userId,
        compoundId: widget.compuesto.idPa,
      );

      setState(() {
        _isFavorite = isFav;
        _isLoadingFavorite = false;
      });
    } else {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicia sesión para guardar favoritos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoadingFavorite = true);

    try {
      if (_isFavorite) {
        await _favoritesService.removeCompoundFromFavorites(
          userId: userId,
          compoundId: widget.compuesto.idPa,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.heart_broken, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Eliminado de favoritos'),
                ],
              ),
              backgroundColor: Colors.grey.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await _favoritesService.addCompoundToFavorites(
          userId: userId,
          compound: widget.compuesto,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Agregado a favoritos'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      setState(() {
        _isFavorite = !_isFavorite;
        _isLoadingFavorite = false;
      });
    } catch (e) {
      setState(() => _isLoadingFavorite = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar favoritos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con gradiente TEAL
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: teal.AppColors.primaryDark,
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
                  gradient: teal.AppColors.primaryGradient,
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
              // Botón Home
              IconButton(
                icon: const Icon(Icons.home_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                tooltip: 'Inicio',
              ),
              // Botón de favorito
              _isLoadingFavorite
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
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
                  // ============================================
                  // SECCIONES REORDENADAS: GRATIS primero, PREMIUM después
                  // ============================================

                  // 1. Familia Farmacológica (GRATIS)
                  _buildInfoCard(
                    icon: Icons.category,
                    title: 'Familia Farmacológica',
                    content: compuesto.familia,
                    color: teal.AppColors.primaryDark,
                    isDark: isDark,
                  ),

                  // 2. Uso Clínico (GRATIS)
                  _buildInfoCard(
                    icon: Icons.medical_information,
                    title: 'Uso Clínico',
                    content: compuesto.uso,
                    color: teal.AppColors.primaryMedium,
                    isDark: isDark,
                  ),

                  // 3. Mecanismo de Acción (GRATIS) - MOVIDO AQUÍ antes de premium
                  if (compuesto.mecanismo.isNotEmpty)
                    _buildExpandableCard(
                      icon: Icons.psychology,
                      title: 'Mecanismo de Acción',
                      content: compuesto.mecanismo,
                      color: teal.AppColors.primaryDark,
                      isDark: isDark,
                    ),

                  // === SECCIONES PREMIUM (con candado) ===

                  // 4. Posología (PREMIUM 🔒)
                  _buildConditionalSection(
                    icon: Icons.schedule,
                    title: 'Posología',
                    content: compuesto.posologia,
                    color: teal.AppColors.successGreen,
                    isDark: isDark,
                    isPremium: true,
                  ),

                  // 5. Consideraciones Especiales (PREMIUM 🔒)
                  if (compuesto.consideraciones.isNotEmpty)
                    _buildConditionalSection(
                      icon: Icons.info_outline,
                      title: 'Consideraciones Especiales',
                      content: compuesto.consideraciones,
                      color: teal.AppColors.warningOrange,
                      isDark: isDark,
                      isPremium: true,
                    ),

                  // 6. Efectos Adversos (PREMIUM 🔒)
                  if (compuesto.efectos.isNotEmpty)
                    _buildConditionalSection(
                      icon: Icons.warning_amber,
                      title: 'Efectos Adversos',
                      content: compuesto.efectos,
                      color: const Color(0xFF26A69A), // Verde-azul
                      isDark: isDark,
                      isPremium: true,
                      contentColor: const Color(0xFF26A69A),
                    ),

                  // 7. Contraindicaciones (PREMIUM 🔒)
                  if (compuesto.contraindicaciones.isNotEmpty)
                    _buildConditionalSection(
                      icon: Icons.dangerous,
                      title: 'Contraindicaciones',
                      content: compuesto.contraindicaciones,
                      color: teal.AppColors.alertRed,
                      isDark: isDark,
                      isPremium: true,
                      contentColor: teal.AppColors.alertRed,
                    ),

                  // 8 y 9. Marcas Comerciales y Genéricos (PREMIUM 🔒) ⬇️ MOVIDO ABAJO
                  FutureBuilder<List<Marca>>(
                    future: _loadMarcas(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final allMarcas = snapshot.data!;

                      // Separar por tipo
                      final marcasComerciales = allMarcas
                          .where((m) =>
                              m.tipoM.toLowerCase().contains('comercial'))
                          .toList();
                      final genericos = allMarcas
                          .where((m) =>
                              m.tipoM.toLowerCase().contains('genérico') ||
                              m.tipoM.toLowerCase().contains('generico'))
                          .toList();

                      return Column(
                        children: [
                          // Marcas Comerciales
                          if (marcasComerciales.isNotEmpty)
                            _buildBrandsSection(
                              title: 'Marcas Comerciales',
                              brands: marcasComerciales,
                              isPremium: true,
                              isDark: isDark,
                              icon: Icons.local_pharmacy,
                              color: teal.AppColors.primaryMedium,
                            ),

                          // Genéricos
                          if (genericos.isNotEmpty)
                            _buildBrandsSection(
                              title: 'Genéricos',
                              brands: genericos,
                              isPremium: true,
                              isDark: isDark,
                              icon: Icons.medication,
                              color: teal.AppColors.primaryDark,
                            ),
                        ],
                      );
                    },
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

  /// Carga las marcas asociadas al compuesto desde la base de datos
  Future<List<Marca>> _loadMarcas() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getMarcasByCompuestoId(compuesto.idPa);
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
        color: isDark ? teal.AppColors.surfaceDark : Colors.white,
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
        color: isDark ? teal.AppColors.surfaceDark : Colors.white,
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
          color: isDark ? teal.AppColors.surfaceDark : Colors.white,
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
                color: teal.AppColors.premiumGold.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock,
                color: teal.AppColors.premiumGold,
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
                  color: teal.AppColors.premiumGold,
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

  /// Sección de marcas/genéricos con lógica premium
  Widget _buildBrandsSection({
    required String title,
    required List<Marca> brands,
    required bool isPremium,
    required bool isDark,
    required IconData icon,
    required Color color,
  }) {
    // Si es premium y usuario no lo es, mostrar bloqueo
    if (isPremium && !isUserPremium) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? teal.AppColors.surfaceDark : Colors.white,
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
                color: teal.AppColors.premiumGold.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock,
                color: teal.AppColors.premiumGold,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Icon(icon, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$title (${brands.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Icon(
                  Icons.star,
                  color: teal.AppColors.premiumGold,
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

    // Usuario premium: mostrar lista de marcas
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? teal.AppColors.surfaceDark : Colors.white,
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
            '$title (${brands.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          children: brands.map((marca) {
            return ListTile(
              title: Text(
                marca.ma,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                '${marca.labM}${marca.viaM.isNotEmpty ? ' • ${marca.viaM}' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BrandDetailScreen(marca: marca),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Footer con fuentes
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
}
