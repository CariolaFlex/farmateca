import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../config/app_config.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName.isNotEmpty
        ? authProvider.userName
        : 'Usuario';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // HEADER: Avatar + Nombre + Settings
              // ============================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar + Nombre
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryMedium,
                        child: Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            'Ver perfil',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Botón Settings
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: AppColors.primaryMedium,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ============================================
              // LOGO + TÍTULO + SUBTÍTULO (Centrado)
              // ============================================
              Center(
                child: Column(
                  children: [
                    // Logo/Isotipo en cuadrado redondeado
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primaryMedium,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Título "Farmateca"
                    Text(
                      AppConfig.appName,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMedium,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtítulo
                    Text(
                      AppConfig.appTagline,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ============================================
              // TÍTULO SECCIÓN
              // ============================================
              const Text(
                '¿Qué deseas buscar?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // ============================================
              // TARJETAS GRANDES CON GRADIENTES
              // ============================================
              Expanded(
                child: ListView(
                  children: [
                    // TARJETA 1: Buscar (cyan claro)
                    _buildGradientCard(
                      context: context,
                      title: 'Buscar',
                      subtitle: 'Busca por nombre comercial o compuesto',
                      icon: Icons.search,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00BCD4), Color(0xFF80DEEA)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // TARJETA 2: Buscar por Compuesto (teal medio)
                    _buildGradientCard(
                      context: context,
                      title: 'Buscar por Compuesto',
                      subtitle: 'Principios activos',
                      icon: Icons.science_outlined,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryMedium,
                          AppColors.secondaryLight,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(searchType: 'compuesto'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // TARJETA 3: Buscar por Marca (teal oscuro)
                    _buildGradientCard(
                      context: context,
                      title: 'Buscar por Marca',
                      subtitle: 'Marcas comerciales',
                      icon: Icons.local_offer_outlined,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primaryMedium,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(searchType: 'marca'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // TARJETA 4: Mis Favoritos (rojo/rosa)
                    _buildGradientCard(
                      context: context,
                      title: 'Mis Favoritos',
                      subtitle: 'Acceso rápido a medicamentos guardados',
                      icon: Icons.favorite,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE91E63), Color(0xFFFF6090)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // FOOTER: Versión
                    Center(
                      child: Text(
                        'v${AppConfig.appVersion}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET: Tarjeta grande con gradiente
  /// ============================================
  Widget _buildGradientCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ============================================
              // ÍCONO GRANDE en cuadrado semi-transparente
              // ============================================
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              // ============================================
              // TEXTOS (Título + Subtítulo)
              // ============================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // FLECHA (chevron derecha)
              // ============================================
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
