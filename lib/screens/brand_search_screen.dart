// lib/screens/brand_search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/database_helper.dart';
import '../models/medication_models.dart';
import '../providers/auth_provider.dart';
import 'detail/brand_detail_screen.dart';
import 'detail/laboratory_detail_screen.dart';
import 'home_screen.dart';
import 'paywall_screen.dart';

class BrandSearchScreen extends StatefulWidget {
  const BrandSearchScreen({super.key});

  @override
  State<BrandSearchScreen> createState() => _BrandSearchScreenState();
}

class _BrandSearchScreenState extends State<BrandSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Marca> _filteredBrands = [];
  List<Map<String, dynamic>> _filteredLaboratories = [];
  String _searchQuery = '';
  bool _isLoading = false;

  // Variables para filtros
  String _selectedFilter = 'Todas';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty && _selectedFilter != 'Laboratorios') {
      setState(() {
        _filteredBrands = [];
        _filteredLaboratories = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Si es modo laboratorios, buscar laboratorios
      if (_selectedFilter == 'Laboratorios') {
        final allBrands = await _dbHelper.searchMarcas('');
        final laboratories = _groupByLaboratory(allBrands);

        // Filtrar por búsqueda si hay query
        List<Map<String, dynamic>> filtered = laboratories;
        if (_searchQuery.isNotEmpty) {
          filtered = laboratories
              .where(
                (lab) => (lab['nombre'] as String).toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
        }

        setState(() {
          _filteredLaboratories = filtered;
          _filteredBrands = [];
          _isLoading = false;
        });
        return;
      }

      final results = await _dbHelper.searchMarcas(_searchQuery);

      // Aplicar filtros según selección
      List<Marca> filtered = results;

      if (_selectedFilter == 'Comerciales') {
        filtered = results
            .where(
              (marca) =>
                  marca.tipoM.toLowerCase() == 'marca comercial' ||
                  marca.tipoM.toLowerCase() == 'comercial',
            )
            .toList();
      } else if (_selectedFilter == 'Genéricos') {
        filtered = results
            .where(
              (marca) =>
                  marca.tipoM.toLowerCase() == 'genérico' ||
                  marca.tipoM.toLowerCase() == 'generico',
            )
            .toList();
      }
      // Si es 'Todas', no filtra nada

      setState(() {
        _filteredBrands = filtered;
        _filteredLaboratories = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error en búsqueda: $e')));
      }
    }
  }

  /// Agrupa las marcas por laboratorio
  List<Map<String, dynamic>> _groupByLaboratory(List<Marca> brands) {
    Map<String, List<Marca>> labMap = {};

    for (var brand in brands) {
      final labName = brand.labM.isNotEmpty ? brand.labM : 'Sin laboratorio';
      if (!labMap.containsKey(labName)) {
        labMap[labName] = [];
      }
      labMap[labName]!.add(brand);
    }

    // Convertir a lista ordenada alfabéticamente
    List<Map<String, dynamic>> laboratories = labMap.entries.map((entry) {
      return {
        'nombre': entry.key,
        'marcas': entry.value,
        'cantidad': entry.value.length,
      };
    }).toList();

    laboratories.sort(
      (a, b) => (a['nombre'] as String).compareTo(b['nombre'] as String),
    );
    return laboratories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buscar Marca',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda con gradiente teal + filtros
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryDark, AppColors.primaryMedium],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Campo de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Escribe para buscar...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryDark,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.primaryDark,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _filteredBrands = [];
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _performSearch();
                  },
                ),

                // Filtros con chips + botón circular de Laboratorios (scroll horizontal)
                const SizedBox(height: 12),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final isPremium = authProvider.isPremium;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Chip "Todas" - siempre disponible
                          _buildPremiumFilterChip(
                            label: 'Todas',
                            isSelected: _selectedFilter == 'Todas',
                            isPremiumFilter: false,
                            isPremiumUser: isPremium,
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'Todas';
                              });
                              _performSearch();
                            },
                          ),
                          const SizedBox(width: 8),

                          // Chip "Comerciales" - PREMIUM
                          _buildPremiumFilterChip(
                            label: 'Comerciales',
                            isSelected: _selectedFilter == 'Comerciales',
                            isPremiumFilter: true,
                            isPremiumUser: isPremium,
                            onTap: () {
                              if (!isPremium) {
                                _showPremiumFilterModal('tipo de marca');
                                return;
                              }
                              setState(() {
                                _selectedFilter = 'Comerciales';
                              });
                              _performSearch();
                            },
                          ),
                          const SizedBox(width: 8),

                          // Chip "Genéricos" - PREMIUM
                          _buildPremiumFilterChip(
                            label: 'Genéricos',
                            isSelected: _selectedFilter == 'Genéricos',
                            isPremiumFilter: true,
                            isPremiumUser: isPremium,
                            onTap: () {
                              if (!isPremium) {
                                _showPremiumFilterModal('tipo de marca');
                                return;
                              }
                              setState(() {
                                _selectedFilter = 'Genéricos';
                              });
                              _performSearch();
                            },
                          ),

                          // Botón circular de Laboratorios - PREMIUM
                          const SizedBox(width: 8),
                          _buildCircularIconButton(
                            icon: isPremium ? Icons.business : Icons.lock,
                            isSelected: _selectedFilter == 'Laboratorios',
                            isPremiumLocked: !isPremium,
                            onTap: () {
                              if (!isPremium) {
                                _showPremiumFilterModal('laboratorio');
                                return;
                              }
                              setState(() {
                                _selectedFilter = 'Laboratorios';
                              });
                              _performSearch();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_selectedFilter == 'Laboratorios'
                      ? (_filteredLaboratories.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                color: AppColors.primaryDark,
                                onRefresh: () async {
                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                  _performSearch();
                                },
                                child: ListView.builder(
                                  physics: const ClampingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                                  itemCount: _filteredLaboratories.length,
                                  itemBuilder: (context, index) {
                                    final lab = _filteredLaboratories[index];
                                    return _buildLaboratoryCard(lab);
                                  },
                                ),
                              ))
                      : (_filteredBrands.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                color: AppColors.primaryDark,
                                onRefresh: () async {
                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                  _performSearch();
                                },
                                child: ListView.builder(
                                  physics: const ClampingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                                  itemCount: _filteredBrands.length,
                                  itemBuilder: (context, index) {
                                    final marca = _filteredBrands[index];
                                    return _buildBrandCard(marca);
                                  },
                                ),
                              ))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Ingresa un término de búsqueda...'
                : 'No se encontraron resultados para "$_selectedFilter"',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(Marca marca) {
    final isComercial =
        marca.tipoM.toLowerCase() == 'marca comercial' ||
        marca.tipoM.toLowerCase() == 'comercial';

    // Detectar si está "Próximamente"
    final isComingSoon = _isComingSoonBrand(marca);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isComingSoon ? 1 : 2,
      color: isComingSoon ? Colors.grey.shade200 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isComingSoon
                ? Colors.grey.shade300
                : AppColors.primaryLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.local_pharmacy,
            color: isComingSoon ? Colors.grey.shade500 : AppColors.primaryDark,
            size: 28,
          ),
        ),
        title: Text(
          marca.ma,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isComingSoon ? Colors.grey.shade700 : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              marca.labM.isNotEmpty ? marca.labM : 'Sin laboratorio',
              style: TextStyle(
                color: isComingSoon
                    ? Colors.grey.shade600
                    : Colors.grey.shade600,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Badge PRÓXIMAMENTE o tipo de marca
            if (isComingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.comingSoonGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRÓXIMAMENTE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isComercial
                      ? Colors.blue.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  marca.tipoM,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isComercial
                        ? Colors.blue.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isComingSoon ? Colors.grey.shade400 : AppColors.primaryDark,
          size: 18,
        ),
        onTap: () {
          if (isComingSoon) {
            _showComingSoonDialog(marca.ma);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BrandDetailScreen(marca: marca),
              ),
            );
          }
        },
      ),
    );
  }

  /// Verifica si una marca está "próximamente" (sin información completa)
  bool _isComingSoonBrand(Marca brand) {
    return brand.usoM.isEmpty || brand.presentacionM.isEmpty;
  }

  /// Muestra diálogo para medicamentos "próximamente"
  void _showComingSoonDialog(String medicationName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryDark, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Próximamente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'El medicamento "$medicationName" estará disponible pronto con toda su información farmacológica.\n\n¿Quieres que te notifiquemos cuando esté listo?',
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Te notificaremos cuando esté disponible',
                  ),
                  backgroundColor: AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Notificarme',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Chip de filtro con soporte premium
  Widget _buildPremiumFilterChip({
    required String label,
    required bool isSelected,
    required bool isPremiumFilter,
    required bool isPremiumUser,
    required VoidCallback onTap,
  }) {
    final bool isLocked = isPremiumFilter && !isPremiumUser;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLocked ? Colors.grey.shade400 : AppColors.primaryDark,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isLocked ? Colors.grey.shade500 : AppColors.primaryDark),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            // Badge PRO si está bloqueado
            if (isLocked) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.premiumGold,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Botón circular para filtros especiales (Laboratorios)
  Widget _buildCircularIconButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isPremiumLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primaryDark : Colors.white,
          border: Border.all(
            color: isPremiumLocked ? Colors.grey.shade400 : AppColors.primaryDark,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryDark.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isPremiumLocked ? Colors.grey.shade500 : AppColors.primaryDark),
              size: 22,
            ),
            // Badge PRO pequeño si está bloqueado
            if (isPremiumLocked)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.premiumGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Muestra modal persuasivo para filtros Premium
  void _showPremiumFilterModal(String filterType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Ícono de candado
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.premiumGold.withValues(alpha: 0.2),
                    AppColors.premiumGold.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                color: AppColors.premiumGold,
                size: 36,
              ),
            ),

            const SizedBox(height: 20),

            // Título
            const Text(
              'Filtros Avanzados',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Badge Premium
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.premiumGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'FUNCIÓN PREMIUM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Descripción
            Text(
              filterType == 'laboratorio'
                  ? 'Filtra marcas por los 151 laboratorios disponibles. '
                    'Encuentra todos los productos de tu laboratorio favorito.'
                  : 'Filtra marcas por tipo: comerciales o genéricos. '
                    'Encuentra exactamente lo que buscas de manera rápida.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Botón CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.premiumGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.premiumGold.withValues(alpha: 0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Desbloquear con Premium',
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
                'Quizás más tarde',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card para mostrar un laboratorio
  Widget _buildLaboratoryCard(Map<String, dynamic> laboratory) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.business, color: AppColors.primaryDark, size: 28),
        ),
        title: Text(
          laboratory['nombre'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${laboratory['cantidad']} marca${(laboratory['cantidad'] as int) != 1 ? 's' : ''}',
          style: TextStyle(
            color: AppColors.primaryMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.primaryDark),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LaboratoryDetailScreen(
                laboratoryName: laboratory['nombre'] as String,
                brands: laboratory['marcas'] as List<Marca>,
              ),
            ),
          );
        },
      ),
    );
  }
}
