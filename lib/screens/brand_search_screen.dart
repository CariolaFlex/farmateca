// lib/screens/brand_search_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/database_helper.dart';
import '../models/medication_models.dart';
import 'detail/brand_detail_screen.dart';
import 'detail/laboratory_detail_screen.dart';

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
  final List<String> _filterOptions = ['Todas', 'Comerciales', 'Genéricos'];

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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Chips de filtros
                      ..._filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primaryDark,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                              _performSearch();
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primaryDark,
                            checkmarkColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            elevation: 2,
                          ),
                        );
                      }),
                      // Botón circular de Laboratorios
                      const SizedBox(width: 4),
                      _buildCircularIconButton(
                        icon: Icons.business,
                        isSelected: _selectedFilter == 'Laboratorios',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'Laboratorios';
                          });
                          _performSearch();
                        },
                      ),
                    ],
                  ),
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
                                  padding: const EdgeInsets.all(16),
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
                                  padding: const EdgeInsets.all(16),
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

  /// Botón circular para filtros especiales (Laboratorios)
  Widget _buildCircularIconButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primaryDark : Colors.white,
          border: Border.all(color: AppColors.primaryDark, width: 2),
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
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.primaryDark,
          size: 22,
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
