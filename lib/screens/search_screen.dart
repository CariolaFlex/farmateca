// lib/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart' as teal;
import '../services/database_helper.dart';
import '../models/medication_models.dart';
import '../providers/auth_provider.dart';
import 'detail/compound_detail_screen.dart';
import 'detail/brand_detail_screen.dart';
import 'detail/family_detail_screen.dart';
import 'home_screen.dart';
import 'paywall_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? searchType; // 'compuesto', 'marca', o null para búsqueda global

  const SearchScreen({super.key, this.searchType});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<dynamic> _results = [];
  List<Map<String, dynamic>> _filteredFamilies = [];
  bool _isLoading = false;
  String _currentFilter = 'todos';
  bool _showFamilyFilter = false; // Para filtro por familia en compuestos

  // === FAMILIAS FARMACOLÓGICAS (Premium) ===
  final Set<String> _selectedFamilies = {};

  @override
  void initState() {
    super.initState();
    if (widget.searchType != null) {
      _currentFilter = widget.searchType!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    // Si está en modo familia, no requiere query
    // También permitir búsqueda si hay familias seleccionadas
    if (query.trim().isEmpty && !_showFamilyFilter && _selectedFamilies.isEmpty) {
      setState(() {
        _results = [];
        _filteredFamilies = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Si está en modo familia (solo para compuestos)
      if (_showFamilyFilter && widget.searchType == 'compuesto') {
        final allCompounds = await _dbHelper.searchCompuestos('');
        final families = _groupByFamily(allCompounds.cast<Compuesto>());

        // Filtrar por búsqueda si hay query
        List<Map<String, dynamic>> filtered = families;
        if (query.isNotEmpty) {
          filtered = families.where((family) =>
              (family['nombre'] as String).toLowerCase().contains(query.toLowerCase())
          ).toList();
        }

        setState(() {
          _filteredFamilies = filtered;
          _results = [];
          _isLoading = false;
        });
        return;
      }

      List<dynamic> results = [];

      switch (_currentFilter) {
        case 'compuesto':
          results = await _dbHelper.searchCompuestos(query);
          break;
        case 'marca':
          results = await _dbHelper.searchMarcas(query);
          break;
        default:
          // searchGlobal retorna Map<String, dynamic>
          final globalResults = await _dbHelper.searchGlobal(query);
          final compuestos =
              globalResults['compuestos'] as List<dynamic>? ?? [];
          final marcas = globalResults['marcas'] as List<dynamic>? ?? [];
          results = [...compuestos, ...marcas];
      }

      // === FILTRO PREMIUM POR FAMILIA ===
      // Si hay familias seleccionadas, filtrar los compuestos
      if (_selectedFamilies.isNotEmpty && widget.searchType == 'compuesto') {
        results = results.where((item) {
          if (item is Compuesto) {
            // Buscar coincidencia parcial de familia
            return _selectedFamilies.any((selectedFamily) =>
                item.familia.toLowerCase().contains(selectedFamily.toLowerCase()) ||
                selectedFamily.toLowerCase().contains(item.familia.toLowerCase()));
          }
          return true;
        }).toList();
      }

      setState(() {
        _results = results;
        _filteredFamilies = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error en búsqueda: $e')));
      }
    }
  }

  /// Agrupa los compuestos por familia
  List<Map<String, dynamic>> _groupByFamily(List<Compuesto> compounds) {
    Map<String, List<Compuesto>> familyMap = {};

    for (var compound in compounds) {
      final familyName = compound.familia.isNotEmpty ? compound.familia : 'Sin familia';
      if (!familyMap.containsKey(familyName)) {
        familyMap[familyName] = [];
      }
      familyMap[familyName]!.add(compound);
    }

    // Convertir a lista ordenada alfabéticamente
    List<Map<String, dynamic>> families = familyMap.entries.map((entry) {
      return {
        'nombre': entry.key,
        'compuestos': entry.value,
        'cantidad': entry.value.length,
      };
    }).toList();

    families.sort((a, b) => (a['nombre'] as String).compareTo(b['nombre'] as String));
    return families;
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Buscar';
    if (widget.searchType == 'compuesto') title = 'Buscar Compuesto';
    if (widget.searchType == 'marca') title = 'Buscar Marca';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: teal.AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
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
          // Barra de búsqueda con gradiente teal
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  teal.AppColors.primaryDark,
                  teal.AppColors.primaryMedium,
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Escribe para buscar...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: teal.AppColors.primaryDark),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: teal.AppColors.primaryDark),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _results = []);
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
              onChanged: _performSearch,
            ),
          ),

          // Filtros (solo si no hay tipo predefinido)
          if (widget.searchType == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('Todos', 'todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Compuestos', 'compuesto'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Marcas', 'marca'),
                ],
              ),
            ),

          // Botones circulares: Todos / Por Familia (solo si es búsqueda de compuestos)
          if (widget.searchType == 'compuesto')
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final isPremium = authProvider.isPremium;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Botón "Todos"
                      _buildFilterChip('Todos', 'todos'),
                      const SizedBox(width: 12),

                      // Botón "Por Familia" - PREMIUM
                      GestureDetector(
                        onTap: () {
                          if (!isPremium) {
                            _showPremiumFilterModal();
                            return;
                          }
                          // Activar modo familia
                          setState(() {
                            _showFamilyFilter = true;
                            _currentFilter = 'familia';
                          });
                          // Cargar familias
                          _performSearch(_searchController.text);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _showFamilyFilter
                                ? teal.AppColors.primaryDark
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPremium
                                  ? teal.AppColors.primaryDark
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPremium ? Icons.category : Icons.lock,
                                size: 20,
                                color: _showFamilyFilter
                                    ? Colors.white
                                    : (isPremium ? teal.AppColors.primaryDark : Colors.grey.shade500),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Por Familia',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _showFamilyFilter
                                      ? Colors.white
                                      : (isPremium ? teal.AppColors.primaryDark : Colors.grey.shade500),
                                ),
                              ),
                              if (!isPremium) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: teal.AppColors.premiumGold,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_showFamilyFilter && widget.searchType == 'compuesto'
                    ? (_filteredFamilies.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: teal.AppColors.primaryDark,
                            onRefresh: () async {
                              await Future.delayed(const Duration(milliseconds: 500));
                              _performSearch(_searchController.text);
                            },
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                              itemCount: _filteredFamilies.length,
                              itemBuilder: (context, index) {
                                final family = _filteredFamilies[index];
                                return _buildFamilyCard(family);
                              },
                            ),
                          ))
                    : (_results.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: teal.AppColors.primaryDark,
                            onRefresh: () async {
                              await Future.delayed(const Duration(milliseconds: 500));
                              if (_searchController.text.isNotEmpty) {
                                _performSearch(_searchController.text);
                              }
                            },
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final item = _results[index];
                                return _buildResultCard(item);
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
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Ingresa un término de búsqueda...'
                : 'No se encontraron resultados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentFilter == value && !_showFamilyFilter;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : teal.AppColors.primaryDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = value;
          _showFamilyFilter = false; // Desactivar modo familia
        });
        if (_searchController.text.isNotEmpty) {
          _performSearch(_searchController.text);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: teal.AppColors.primaryDark,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
    );
  }

  Widget _buildResultCard(dynamic item) {
    final bool isCompuesto = item is Compuesto;
    final String title = isCompuesto ? item.pa : (item as Marca).ma;
    final String subtitle = isCompuesto ? item.familia : item.paM;

    // Detectar si es marca genérica
    final bool isGenerico = !isCompuesto &&
        (item.tipoM.toLowerCase().contains('genérico') ||
         item.tipoM.toLowerCase().contains('generico'));

    // Detectar si está "Próximamente" (sin información completa)
    final bool isComingSoon;
    if (isCompuesto) {
      isComingSoon = _isComingSoonCompound(item);
    } else {
      isComingSoon = _isComingSoonBrand(item as Marca);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isComingSoon ? 1 : 2,
      color: isComingSoon ? Colors.grey.shade200 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isComingSoon
                ? Colors.grey.shade300
                : (isCompuesto
                    ? teal.AppColors.compoundBlue.withValues(alpha: 0.15)
                    : teal.AppColors.primaryLight.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isCompuesto ? Icons.science : Icons.local_pharmacy,
            color: isComingSoon
                ? Colors.grey.shade500
                : (isCompuesto ? teal.AppColors.compoundBlue : teal.AppColors.primaryDark),
            size: 28,
          ),
        ),
        title: Text(
          title,
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
              subtitle.isNotEmpty ? subtitle : 'Sin información',
              style: TextStyle(
                color: isComingSoon ? Colors.grey.shade600 : Colors.grey.shade600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Badge PRÓXIMAMENTE
            if (isComingSoon) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: teal.AppColors.comingSoonGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRÓXIMAMENTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            // Solo mostrar badge GENÉRICO para marcas genéricas (si no es próximamente)
            if (!isComingSoon && isGenerico) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'GENÉRICO',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isComingSoon ? Colors.grey.shade400 : teal.AppColors.primaryDark,
          size: 18,
        ),
        onTap: () {
          if (isComingSoon) {
            _showComingSoonDialog(title);
          } else {
            _navigateToDetail(item, isCompuesto);
          }
        },
      ),
    );
  }

  /// Verifica si un compuesto está "próximamente" (sin información completa)
  bool _isComingSoonCompound(Compuesto compound) {
    return compound.uso.isEmpty ||
        compound.posologia.isEmpty ||
        compound.mecanismo.isEmpty;
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
            Icon(Icons.info_outline, color: teal.AppColors.primaryDark, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Próximamente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: teal.AppColors.primaryDark,
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
                  content: const Text('Te notificaremos cuando esté disponible'),
                  backgroundColor: teal.AppColors.successGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: teal.AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Notificarme', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Navega a la pantalla de detalle correspondiente
  void _navigateToDetail(dynamic item, bool isCompuesto) {
    if (isCompuesto) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompoundDetailScreen(compuesto: item as Compuesto),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BrandDetailScreen(marca: item as Marca),
        ),
      );
    }
  }

  /// Card para mostrar una familia farmacológica
  Widget _buildFamilyCard(Map<String, dynamic> family) {
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
            color: teal.AppColors.primaryMedium.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.category,
            color: teal.AppColors.primaryDark,
            size: 28,
          ),
        ),
        title: Text(
          family['nombre'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${family['cantidad']} compuesto${(family['cantidad'] as int) != 1 ? 's' : ''}',
          style: TextStyle(
            color: teal.AppColors.primaryMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: teal.AppColors.primaryDark,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FamilyDetailScreen(
                familyName: family['nombre'] as String,
                compounds: family['compuestos'] as List<Compuesto>,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Muestra modal persuasivo para filtros Premium
  void _showPremiumFilterModal() {
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
                    teal.AppColors.premiumGold.withValues(alpha: 0.2),
                    teal.AppColors.premiumGold.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                color: teal.AppColors.premiumGold,
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
                color: teal.AppColors.premiumGold,
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
              'Filtra compuestos por las 34 familias farmacológicas '
              'disponibles. Encuentra exactamente lo que necesitas de '
              'manera rápida y precisa.',
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
                  backgroundColor: teal.AppColors.premiumGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: teal.AppColors.premiumGold.withValues(alpha: 0.4),
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

}
