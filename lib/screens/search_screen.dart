// lib/screens/search_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart' as teal;
import '../services/database_helper.dart';
import '../models/medication_models.dart';
import 'detail/compound_detail_screen.dart';
import 'detail/brand_detail_screen.dart';

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
  bool _isLoading = false;
  String _currentFilter = 'todos';

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
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
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

      setState(() {
        _results = results;
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

          // Resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
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
                      padding: const EdgeInsets.all(16),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return _buildResultCard(item);
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
    final isSelected = _currentFilter == value;
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
        setState(() => _currentFilter = value);
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
            color: teal.AppColors.primaryLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isCompuesto ? Icons.medication : Icons.local_pharmacy,
            color: teal.AppColors.primaryDark,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle.isNotEmpty ? subtitle : 'Sin información',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            // Solo mostrar badge GENÉRICO para marcas genéricas
            if (isGenerico) ...[
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
          color: teal.AppColors.primaryDark,
          size: 18,
        ),
        onTap: () => _navigateToDetail(item, isCompuesto),
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
}
