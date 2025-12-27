import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart' as teal;
import '../models/medication_models.dart';
import '../services/favorites_service.dart';
import '../providers/auth_provider.dart';
import 'detail/compound_detail_screen.dart';
import 'detail/brand_detail_screen.dart';
import 'home_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  final FavoritesService _favoritesService = FavoritesService();
  late TabController _tabController;

  List<Compuesto> _favoriteCompounds = [];
  List<Marca> _favoriteBrands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final compounds = await _favoritesService.getFavoriteCompounds(userId);
      final brands = await _favoritesService.getFavoriteBrands(userId);

      setState(() {
        _favoriteCompounds = compounds;
        _favoriteBrands = brands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando favoritos: $e')),
        );
      }
    }
  }

  Future<void> _removeCompoundFavorite(Compuesto compound) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;

    if (userId == null) return;

    try {
      await _favoritesService.removeCompoundFromFavorites(
        userId: userId,
        compoundId: compound.idPa,
      );
      await _loadFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.heart_broken, color: Colors.white),
                const SizedBox(width: 8),
                Text('${compound.pa} eliminado de favoritos'),
              ],
            ),
            backgroundColor: Colors.grey.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _removeBrandFavorite(Marca brand) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.firebaseUser?.uid;

    if (userId == null) return;

    try {
      await _favoritesService.removeBrandFromFavorites(
        userId: userId,
        brandId: brand.idMa,
      );
      await _loadFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.heart_broken, color: Colors.white),
                const SizedBox(width: 8),
                Text('${brand.ma} eliminado de favoritos'),
              ],
            ),
            backgroundColor: Colors.grey.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.firebaseUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        backgroundColor: teal.AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          // Botón Home
          IconButton(
            icon: const Icon(Icons.home_outlined),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.science),
              text: 'Compuestos (${_favoriteCompounds.length})',
            ),
            Tab(
              icon: const Icon(Icons.local_pharmacy),
              text: 'Marcas (${_favoriteBrands.length})',
            ),
          ],
        ),
      ),
      body: !isLoggedIn
          ? _buildNotLoggedInView()
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCompoundsList(),
                    _buildBrandsList(),
                  ],
                ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Inicia sesión para ver tus favoritos',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus favoritos se guardarán en tu cuenta\ny se sincronizarán en todos tus dispositivos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
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
    );
  }

  Widget _buildCompoundsList() {
    if (_favoriteCompounds.isEmpty) {
      return _buildEmptyView('No tienes compuestos favoritos', Icons.science);
    }

    return RefreshIndicator(
      color: teal.AppColors.primaryDark,
      onRefresh: _loadFavorites,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _favoriteCompounds.length,
        itemBuilder: (context, index) {
          final compound = _favoriteCompounds[index];
          return _buildCompoundCard(compound);
        },
      ),
    );
  }

  Widget _buildBrandsList() {
    if (_favoriteBrands.isEmpty) {
      return _buildEmptyView('No tienes marcas favoritas', Icons.local_pharmacy);
    }

    return RefreshIndicator(
      color: teal.AppColors.primaryDark,
      onRefresh: _loadFavorites,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _favoriteBrands.length,
        itemBuilder: (context, index) {
          final brand = _favoriteBrands[index];
          return _buildBrandCard(brand);
        },
      ),
    );
  }

  Widget _buildCompoundCard(Compuesto compound) {
    return Dismissible(
      key: Key('compound_${compound.idPa}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.alertRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeCompoundFavorite(compound),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: teal.AppColors.primaryDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.science,
              color: teal.AppColors.primaryDark,
            ),
          ),
          title: Text(
            compound.pa,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            compound.familia,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.alertRed),
            onPressed: () => _removeCompoundFavorite(compound),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompoundDetailScreen(compuesto: compound),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandCard(Marca brand) {
    return Dismissible(
      key: Key('brand_${brand.idMa}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.alertRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeBrandFavorite(brand),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: teal.AppColors.primaryMedium.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_pharmacy,
              color: teal.AppColors.primaryMedium,
            ),
          ),
          title: Text(
            brand.ma,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${brand.labM} • ${brand.tipoM}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.alertRed),
            onPressed: () => _removeBrandFavorite(brand),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BrandDetailScreen(marca: brand),
              ),
            );
          },
        ),
      ),
    );
  }
}
