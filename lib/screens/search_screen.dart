// lib/screens/search_screen.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title = 'Buscar';
    if (widget.searchType == 'compuesto') title = 'Buscar Compuesto';
    if (widget.searchType == 'marca') title = 'Buscar Marca';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.cardDark : Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Escribe para buscar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _results = []);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceDark
                    : Colors.grey.shade100,
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Ingresa un término de búsqueda'
                              : 'No se encontraron resultados',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      return _buildResultCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _currentFilter = value);
        if (_searchController.text.isNotEmpty) {
          _performSearch(_searchController.text);
        }
      },
      selectedColor: AppColors.primaryBlue.withAlpha(51),
      checkmarkColor: AppColors.primaryBlue,
    );
  }

  Widget _buildResultCard(dynamic item) {
    final bool isCompuesto = item is Compuesto;
    final String title = isCompuesto ? item.pa : (item as Marca).ma;
    final String subtitle = isCompuesto ? item.familia : item.paM;
    final bool isFree = isCompuesto ? item.isFree : item.isFree;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompuesto
                ? AppColors.primaryBlue.withAlpha(26)
                : AppColors.secondaryTeal.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCompuesto ? Icons.science : Icons.local_pharmacy,
            color: isCompuesto
                ? AppColors.primaryBlue
                : AppColors.secondaryTeal,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isFree ? AppColors.successGreen : AppColors.premiumGold,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isFree ? 'GRATIS' : 'PREMIUM',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
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
