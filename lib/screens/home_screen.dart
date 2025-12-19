import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../config/app_config.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // Animación de "respiración" para tarjeta principal
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }


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
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Row(
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
              ),

              const SizedBox(height: 32),

              // ============================================
              // LOGO ISOTIPO + TÍTULO + SUBTÍTULO
              // ============================================
              FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Center(
                  child: Column(
                    children: [
                      // LOGO REAL DE FARMATECA
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryMedium,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/logos/isotipo_farmateca.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback si la imagen no existe
                              return const Icon(
                                Icons.local_pharmacy,
                                color: Colors.white,
                                size: 50,
                              );
                            },
                          ),
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
              ),

              const SizedBox(height: 40),

              // ============================================
              // TÍTULO SECCIÓN
              // ============================================
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                child: const Text(
                  '¿Qué deseas buscar?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ============================================
              // TARJETAS CON ANIMACIONES
              // ============================================
              Expanded(
                child: ListView(
                  children: [
                    // ==========================================
                    // TARJETA PRINCIPAL: Buscar (MÁS GRANDE)
                    // ==========================================
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: ScaleTransition(
                        scale: _breathingAnimation,
                        child: _buildPrimaryCard(
                          context: context,
                          title: 'Buscar',
                          subtitle: 'Busca por nombre comercial o compuesto',
                          icon: Icons.search,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24), // ← MAYOR SEPARACIÓN

                    // ==========================================
                    // TARJETAS SECUNDARIAS (MÁS PEQUEÑAS)
                    // ==========================================

                    // Compuesto
                    FadeInRight(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 100),
                      child: _buildSecondaryCard(
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
                    ),

                    const SizedBox(height: 12), // ← MENOR SEPARACIÓN

                    // Marca
                    FadeInRight(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: _buildSecondaryCard(
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
                    ),

                    const SizedBox(height: 12),

                    // Favoritos (ROJO PURO)
                    FadeInRight(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: _buildSecondaryCard(
                        context: context,
                        title: 'Mis Favoritos',
                        subtitle: 'Acceso rápido a medicamentos guardados',
                        icon: Icons.favorite,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD32F2F), // ← ROJO PURO (no rosado)
                            Color(0xFFF44336),
                          ],
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
  /// WIDGET: Tarjeta PRINCIPAL (GRANDE Y PREMIUM)
  /// ============================================
  Widget _buildPrimaryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.white.withValues(alpha: 0.3),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Ink(
          padding: const EdgeInsets.all(22), // ← MÁS PADDING
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00D4D4), // ← GRADIENTE DE 3 COLORES
                Color(0xFF00BCD4),
                Color(0xFF80DEEA),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), // ← BORDE BRILLANTE
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // ÍCONO GRANDE
              Container(
                width: 70, // ← MÁS GRANDE
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 36,
                ),
              ),

              const SizedBox(width: 18),

              // TEXTOS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20, // ← MÁS GRANDE
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14, // ← MÁS GRANDE
                        color: Colors.white.withValues(alpha: 0.95),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // FLECHA
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET: Tarjetas SECUNDARIAS (MÁS PEQUEÑAS)
  /// ============================================
  Widget _buildSecondaryCard({
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
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Ink(
          padding: const EdgeInsets.all(16), // ← MENOS PADDING
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // ÍCONO MEDIANO
              Container(
                width: 50, // ← MÁS PEQUEÑO
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              // TEXTOS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16, // ← MÁS PEQUEÑO
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12, // ← MÁS PEQUEÑO
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // FLECHA
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
