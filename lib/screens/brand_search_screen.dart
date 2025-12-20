// lib/screens/brand_search_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/database_helper.dart';
import '../models/medication_models.dart';
import 'detail/brand_detail_screen.dart';

class BrandSearchScreen extends StatefulWidget {
  const BrandSearchScreen({super.key});

  @override
  State<BrandSearchScreen> createState() => _BrandSearchScreenState();
}

class _BrandSearchScreenState extends State<BrandSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Marca> _filteredBrands = [];
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
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredBrands = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _dbHelper.searchMarcas(_searchQuery);

      // Aplicar filtros según selección
      List<Marca> filtered = results;

      if (_selectedFilter == 'Comerciales') {
        filtered = results.where((marca) =>
            marca.tipoM.toLowerCase() == 'marca comercial' ||
            marca.tipoM.toLowerCase() == 'comercial').toList();
      } else if (_selectedFilter == 'Genéricos') {
        filtered = results.where((marca) =>
            marca.tipoM.toLowerCase() == 'genérico' ||
            marca.tipoM.toLowerCase() == 'generico').toList();
      }
      // Si es 'Todas', no filtra nada

      setState(() {
        _filteredBrands = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en búsqueda: $e')),
        );
      }
    }
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
                colors: [
                  AppColors.primaryDark,
                  AppColors.primaryMedium,
                ],
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
                    prefixIcon: Icon(Icons.search, color: AppColors.primaryDark),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.primaryDark),
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

                // Filtros con chips
                const SizedBox(height: 12),
                Row(
                  children: _filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primaryDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                  }).toList(),
                ),
              ],
            ),
          ),

          // Resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBrands.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primaryDark,
                        onRefresh: () async {
                          await Future.delayed(const Duration(milliseconds: 500));
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
                      ),
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
            _searchQuery.isEmpty
                ? 'Ingresa un término de búsqueda...'
                : 'No se encontraron resultados para "$_selectedFilter"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(Marca marca) {
    final isComercial = marca.tipoM.toLowerCase() == 'marca comercial' ||
        marca.tipoM.toLowerCase() == 'comercial';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.local_pharmacy,
            color: AppColors.primaryDark,
            size: 28,
          ),
        ),
        title: Text(
          marca.ma,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              marca.labM.isNotEmpty ? marca.labM : 'Sin laboratorio',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isComercial ? Colors.blue.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                marca.tipoM,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isComercial ? Colors.blue.shade700 : Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primaryDark,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BrandDetailScreen(marca: marca),
            ),
          );
        },
      ),
    );
  }
}
