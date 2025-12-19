import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/database_helper.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _dbHelper.getAllFavoritos();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando favoritos: $e')));
      }
    }
  }

  Future<void> _removeFavorite(Map<String, dynamic> favorite) async {
    try {
      await _dbHelper.removeFavorito(favorite['item_id'].toString());
      await _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Eliminado de favoritos')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes favoritos aún',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega medicamentos a favoritos\npara acceder rápidamente',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final favorite = _favorites[index];
                  return _buildFavoriteCard(favorite);
                },
              ),
            ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
    final bool isCompuesto = favorite['tipo'] == 'compuesto';
    final String title = favorite['nombre'] ?? 'Sin nombre';

    return Dismissible(
      key: Key('${favorite['tipo']}_${favorite['item_id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.alertRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeFavorite(favorite),

      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompuesto
                  ? AppColors.primaryBlue.withValues(alpha: 0.1)
                  : AppColors.secondaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompuesto ? Icons.science : Icons.local_pharmacy,
              color: isCompuesto
                  ? AppColors.primaryBlue
                  : AppColors.secondaryTeal,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isCompuesto ? 'Compuesto' : 'Marca comercial',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.alertRed),
            onPressed: () => _removeFavorite(favorite),
          ),
          onTap: () {
            // TODO: Navegar a DetailScreen
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Ver detalles de: $title')));
          },
        ),
      ),
    );
  }
}
