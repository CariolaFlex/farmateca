import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import 'auth/terms_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección Usuario
          _buildSectionTitle('Cuenta'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      (authProvider.userName.isNotEmpty
                              ? authProvider.userName[0]
                              : 'U')
                          .toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    authProvider.userName.isNotEmpty
                        ? authProvider.userName
                        : 'Usuario',
                  ),
                  subtitle: Text(authProvider.userEmail ?? 'Sin correo'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.workspace_premium),
                  title: const Text('Plan actual'),
                  subtitle: const Text('Plan Gratuito'),
                  trailing: TextButton(
                    onPressed: () {
                      // TODO: Ir a pantalla de suscripción
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente: Planes Premium'),
                        ),
                      ); // ← Cambiar coma por punto y coma
                    },
                    child: const Text('Mejorar'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sección Apariencia
          _buildSectionTitle('Apariencia'),
          Card(
            child: SwitchListTile(
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Modo oscuro'),
              subtitle: Text(isDark ? 'Activado' : 'Desactivado'),
              value: isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),

          const SizedBox(height: 24),

          // Sección Legal
          _buildSectionTitle('Legal'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Términos y Condiciones'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Política de Privacidad'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Crear pantalla de privacidad
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sección Información
          _buildSectionTitle('Información'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Versión'),
                  trailing: Text(
                    AppStrings.appVersion,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Desarrollado por'),
                  subtitle: Text(AppConstants.companyNameFull),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Soporte'),
                  subtitle: Text(AppConstants.supportEmail),
                  onTap: () {
                    // TODO: Abrir email
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Botón Cerrar Sesión
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, authProvider),
              icon: const Icon(Icons.logout, color: AppColors.alertRed),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: AppColors.alertRed),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.alertRed),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.alertRed),
            ),
          ),
        ],
      ),
    );
  }
}
