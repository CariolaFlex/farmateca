// lib/screens/settings_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import '../services/storage_service.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/preferences_provider.dart';
import 'paywall_screen.dart';
import 'auth/login_screen.dart';
import 'auth/terms_screen.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool openProfileEdit;

  const SettingsScreen({super.key, this.openProfileEdit = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Si se solicita abrir el modal de edición de perfil automáticamente
    if (widget.openProfileEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.firebaseUser != null) {
          _showEditProfileModal(authProvider);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // PERFIL DE USUARIO (Mejorado)
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: _buildProfileSection(authProvider, isDark),
            ),

            const SizedBox(height: 8),

            // PLAN ACTUAL (Con navegación a premium)
            FadeInLeft(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: _buildPlanSection(context, authProvider, isDark),
            ),

            const SizedBox(height: 8),

            // APARIENCIA (Dark Mode existente)
            FadeInRight(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 200),
              child: _buildAppearanceSection(themeProvider, isDark),
            ),

            const SizedBox(height: 8),

            // TIPOGRAFÍA (NUEVO)
            FadeInLeft(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 300),
              child: _buildTypographySection(prefsProvider, isDark),
            ),

            const SizedBox(height: 8),

            // MODO DESARROLLADOR (Solo visible en debug)
            if (kDebugMode)
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 350),
                child: _buildDeveloperSection(authProvider, isDark),
              ),

            if (kDebugMode) const SizedBox(height: 8),

            // LEGAL
            FadeInRight(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 400),
              child: _buildLegalSection(isDark),
            ),

            const SizedBox(height: 8),

            // INFORMACIÓN
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 500),
              child: _buildInfoSection(isDark),
            ),

            const SizedBox(height: 16),

            // CERRAR SESIÓN
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 600),
              child: _buildLogoutButton(authProvider),
            ),

            const SizedBox(height: 16),

            // FOOTER (Sin cuadro, al final)
            _buildFooter(isDark),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ===== PERFIL MEJORADO =====
  Widget _buildProfileSection(AuthProvider authProvider, bool isDark) {
    final userModel = authProvider.userModel;
    final displayName = userModel?.displayName ?? authProvider.userName;
    final email = authProvider.userEmail;
    final photoURL = userModel?.photoURL;
    final nivel = userModel?.nivelDisplay;
    final area = userModel?.areaDisplay;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryMedium,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditProfileModal(authProvider),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // FOTO DE PERFIL (con opción de cambiar)
                Stack(
                  children: [
                    Hero(
                      tag: 'profile_avatar',
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            photoURL != null ? NetworkImage(photoURL) : null,
                        child: photoURL == null
                            ? Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // INFORMACIÓN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isNotEmpty ? displayName : 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ROL Y ÁREA (si existen)
                      if (nivel != null &&
                          nivel != 'No especificado' &&
                          area != null &&
                          area.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$nivel - $area',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ÍCONO EDITAR
                Icon(
                  Icons.edit,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== PLAN ACTUAL (con navegación) =====
  Widget _buildPlanSection(
      BuildContext context, AuthProvider authProvider, bool isDark) {
    final isPremium = authProvider.userModel?.isPremium ?? false;

    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Plan Actual', Icons.workspace_premium, isDark),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaywallScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryDark.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPremium
                            ? AppColors.premiumGold.withValues(alpha: 0.2)
                            : AppColors.primaryDark.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPremium ? Icons.star : Icons.card_membership,
                        color:
                            isPremium ? AppColors.premiumGold : AppColors.primaryDark,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPremium ? 'Plan Premium' : 'Plan Gratuito',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isPremium
                                ? 'Acceso completo a todo el contenido'
                                : 'Acceso limitado a contenido',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primaryMedium,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Mejorar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== APARIENCIA (MANTENER DARK MODE EXISTENTE) =====
  Widget _buildAppearanceSection(ThemeProvider themeProvider, bool isDark) {
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Apariencia', Icons.palette, isDark),
          const SizedBox(height: 12),
          // Dark Mode toggle - MANTENER FUNCIONALIDAD EXISTENTE
          SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primaryDark,
            ),
            title: Text(
              'Modo oscuro',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              isDark ? 'Activado' : 'Desactivado',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            value: isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
            activeColor: AppColors.primaryDark,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // ===== TIPOGRAFÍA (NUEVO) =====
  Widget _buildTypographySection(PreferencesProvider prefs, bool isDark) {
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Tipografía', Icons.text_fields, isDark),
          const SizedBox(height: 16),

          // SELECTOR DE FUENTE
          Row(
            children: [
              Icon(
                Icons.font_download,
                color: AppColors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de letra',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: prefs.preferences.fontFamily,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryDark.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryDark.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryDark,
                            width: 2,
                          ),
                        ),
                      ),
                      dropdownColor:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      items: PreferencesProvider.availableFonts
                          .map((font) => DropdownMenuItem(
                                value: font,
                                child: Text(
                                  font,
                                  style: TextStyle(
                                    fontFamily: font,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          prefs.setFontFamily(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SLIDER DE TAMAÑO
          Row(
            children: [
              Icon(
                Icons.format_size,
                color: AppColors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tamaño de letra',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${prefs.preferences.fontSize.toInt()}px',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primaryDark,
                        inactiveTrackColor:
                            AppColors.primaryDark.withValues(alpha: 0.2),
                        thumbColor: AppColors.primaryDark,
                        overlayColor:
                            AppColors.primaryDark.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: prefs.preferences.fontSize,
                        min: PreferencesProvider.minFontSize,
                        max: PreferencesProvider.maxFontSize,
                        divisions: 12,
                        label: '${prefs.preferences.fontSize.toInt()}',
                        onChanged: (value) => prefs.setFontSize(value),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pequeña',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black45,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Grande',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black45,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // PREVIEW
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Texto de ejemplo: Farmateca es una enciclopedia farmacológica completa.',
              style: TextStyle(
                fontFamily: prefs.preferences.fontFamily,
                fontSize: prefs.preferences.fontSize,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== MODO DESARROLLADOR (Solo visible en kDebugMode) =====
  Widget _buildDeveloperSection(AuthProvider authProvider, bool isDark) {
    final isDevPremium = authProvider.isDeveloperPremiumActive;

    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con icono de herramienta en rojo
          Row(
            children: [
              Icon(
                Icons.build_circle,
                color: AppColors.alertRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Modo Desarrollador',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.alertRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Switch para activar Premium de prueba
          SwitchListTile(
            secondary: Icon(
              Icons.workspace_premium,
              color: isDevPremium ? AppColors.premiumGold : (isDark ? Colors.white54 : Colors.grey),
            ),
            title: Text(
              'Activar Modo Premium',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Simula acceso Premium para testing',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
              ),
            ),
            value: isDevPremium,
            onChanged: (value) async {
              await authProvider.setDeveloperPremium(value);
            },
            activeColor: AppColors.premiumGold,
            contentPadding: EdgeInsets.zero,
          ),

          // Badge "DEV MODE ACTIVO" cuando está activado
          if (isDevPremium) ...[
            const SizedBox(height: 12),
            FadeIn(
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.premiumGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.premiumGold.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.premiumGold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DEV MODE ACTIVO',
                      style: TextStyle(
                        color: AppColors.premiumGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Nota de advertencia
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? Colors.white54 : Colors.black45,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Este modo no estará disponible en producción.',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== LEGAL =====
  Widget _buildLegalSection(bool isDark) {
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Legal', Icons.gavel, isDark),
          const SizedBox(height: 8),
          _buildListTile(
            icon: Icons.description,
            title: 'Términos y Condiciones',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: 'Política de Privacidad',
            onTap: () => _showPrivacyDialog(),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ===== INFORMACIÓN =====
  Widget _buildInfoSection(bool isDark) {
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Información', Icons.info, isDark),
          const SizedBox(height: 8),
          _buildInfoTile(
            icon: Icons.code,
            title: 'Versión',
            subtitle: 'v1.0.0',
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          _buildInfoTile(
            icon: Icons.email,
            title: 'Soporte',
            subtitle: 'soporte@farmateca.cl',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ===== CERRAR SESIÓN =====
  Widget _buildLogoutButton(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(authProvider),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red.shade600,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== FOOTER (sin cuadro) =====
  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Text(
          'Desarrollado por',
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vectium SpA',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ===== WIDGETS HELPER =====
  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryDark,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryDark, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ===== MODALES =====
  void _showEditProfileModal(AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileModal(authProvider: authProvider),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'Farmateca respeta tu privacidad y protege tus datos personales. '
            'La información que proporcionas se utiliza únicamente para mejorar '
            'tu experiencia en la aplicación y no se comparte con terceros sin tu consentimiento.\n\n'
            'Para más información, contacta a soporte@farmateca.cl',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== MODAL DE EDICIÓN DE PERFIL =====
class EditProfileModal extends StatefulWidget {
  final AuthProvider authProvider;

  const EditProfileModal({super.key, required this.authProvider});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _aliasController;
  String? _selectedNivel;
  String? _selectedArea;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final List<String> niveles = ['estudiante', 'interno', 'profesional'];
  final List<String> nivelesDisplay = ['Estudiante', 'Interno(a)', 'Profesional'];

  final List<String> areas = [
    'medicina',
    'enfermeria',
    'quimica',
    'kinesiologia',
    'obstetricia',
    'nutricion',
    'tens',
    'otra',
  ];
  final List<String> areasDisplay = [
    'Medicina',
    'Enfermería',
    'Química y Farmacia',
    'Kinesiología',
    'Obstetricia',
    'Nutrición',
    'TENS',
    'Otra',
  ];

  @override
  void initState() {
    super.initState();
    final userModel = widget.authProvider.userModel;
    _aliasController = TextEditingController(text: userModel?.alias);
    _selectedNivel = userModel?.nivel;
    _selectedArea = userModel?.area;
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userModel = widget.authProvider.userModel;
    final photoURL = userModel?.photoURL;
    final displayName = userModel?.displayName ?? widget.authProvider.userName;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // TÍTULO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Editar Perfil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // FOTO
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            AppColors.primaryDark.withValues(alpha: 0.1),
                        backgroundImage:
                            photoURL != null ? NetworkImage(photoURL) : null,
                        child: photoURL == null
                            ? Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              )
                            : null,
                      ),
                      if (_isUploading)
                        Positioned.fill(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.black54,
                            child: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showPhotoOptions(context, photoURL),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ALIAS
                TextFormField(
                  controller: _aliasController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Alias o Apodo',
                    labelStyle:
                        TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    hintText: 'Cómo quieres que te llamemos',
                    hintStyle:
                        TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.primaryDark,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.primaryDark, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // NIVEL
                DropdownButtonFormField<String>(
                  value: _selectedNivel,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Rol Profesional',
                    labelStyle:
                        TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    prefixIcon: Icon(
                      Icons.work_outline,
                      color: AppColors.primaryDark,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.primaryDark, width: 2),
                    ),
                  ),
                  items: List.generate(
                    niveles.length,
                    (index) => DropdownMenuItem(
                      value: niveles[index],
                      child: Text(nivelesDisplay[index]),
                    ),
                  ),
                  onChanged: (value) => setState(() => _selectedNivel = value),
                ),

                const SizedBox(height: 16),

                // ÁREA
                DropdownButtonFormField<String>(
                  value: _selectedArea,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Área de Salud',
                    labelStyle:
                        TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    prefixIcon: Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.primaryDark,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.primaryDark, width: 2),
                    ),
                  ),
                  items: List.generate(
                    areas.length,
                    (index) => DropdownMenuItem(
                      value: areas[index],
                      child: Text(areasDisplay[index]),
                    ),
                  ),
                  onChanged: (value) => setState(() => _selectedArea = value),
                ),

                const SizedBox(height: 24),

                // BOTÓN GUARDAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      print('📸 Iniciando selección de imagen desde: $source');

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        print('❌ No se seleccionó ninguna imagen');
        return;
      }

      print('✅ Imagen seleccionada: ${image.path}');

      setState(() => _isUploading = true);

      final File imageFile = File(image.path);

      // Verificar que el archivo existe
      if (!await imageFile.exists()) {
        print('❌ El archivo no existe');
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error: El archivo no existe'),
              backgroundColor: AppColors.alertRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // Usar StorageService para subir
      final storageService = StorageService();
      final userId = widget.authProvider.firebaseUser!.uid;

      print('☁️ Subiendo imagen a Firebase Storage...');

      final photoURL = await storageService.uploadProfileImage(userId, imageFile);

      if (photoURL == null) {
        print('❌ Error al subir imagen a Storage');
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error al subir la foto. Intenta nuevamente.'),
              backgroundColor: AppColors.alertRed,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      print('✅ Imagen subida exitosamente: $photoURL');

      // Actualizar perfil (AuthProvider notificará los cambios)
      await widget.authProvider.updateUserProfile(
        photoURL: photoURL,
      );

      print('✅ Perfil actualizado en Firestore');

      setState(() => _isUploading = false);

      if (mounted) {
        // Cerrar modal para forzar rebuild del padre con nueva foto
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto actualizada exitosamente'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error en _pickImage: $e');
      print('❌ Stack: $stackTrace');

      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir foto: $e'),
            backgroundColor: AppColors.alertRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isUploading = true);

        await widget.authProvider.updateUserProfile(
          alias: _aliasController.text.trim().isNotEmpty
              ? _aliasController.text.trim()
              : null,
          nivel: _selectedNivel,
          area: _selectedArea,
        );

        setState(() => _isUploading = false);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado exitosamente')),
          );
        }
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar: $e')),
          );
        }
      }
    }
  }

  /// Mostrar opciones de foto en bottom sheet
  void _showPhotoOptions(BuildContext context, String? currentPhotoURL) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Foto de perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const Divider(),

              // Opción: Tomar foto
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primaryDark,
                  ),
                ),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),

              // Opción: Elegir de galería
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppColors.primaryDark,
                  ),
                ),
                title: const Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),

              // Opción: Eliminar foto (solo si tiene foto)
              if (currentPhotoURL != null && currentPhotoURL.isNotEmpty)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.alertRed,
                    ),
                  ),
                  title: Text(
                    'Eliminar foto',
                    style: TextStyle(color: AppColors.alertRed),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDeletePhoto();
                  },
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Confirmar eliminación de foto
  Future<void> _confirmDeletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar foto'),
        content: const Text('¿Estás seguro de que deseas eliminar tu foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deletePhoto();
    }
  }

  /// Eliminar foto de perfil
  Future<void> _deletePhoto() async {
    setState(() => _isUploading = true);

    try {
      final userModel = widget.authProvider.userModel;
      final currentPhotoURL = userModel?.photoURL;

      // Eliminar de Storage si existe
      if (currentPhotoURL != null && currentPhotoURL.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(currentPhotoURL);
          await ref.delete();
        } catch (e) {
          print('Error deleting photo from storage: $e');
        }
      }

      // Eliminar referencia del perfil
      await widget.authProvider.updateUserProfile(photoURL: null);

      setState(() => _isUploading = false);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto eliminada correctamente'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la foto: $e'),
            backgroundColor: AppColors.alertRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
