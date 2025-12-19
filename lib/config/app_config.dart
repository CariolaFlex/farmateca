// lib/config/app_config.dart

class AppConfig {
  // === Información de la aplicación ===
  static const String appName = 'Farmateca';
  static const String appTagline = 'Bibliomédica Chilena Offline';
  static const String appVersion = '0.9.0';
  static const String appBuild = '1';

  // === Contacto y soporte ===
  static const String supportEmail = 'farmateca.soporte@gmail.com';

  // === URLs (se configurarán más adelante) ===
  static const String websiteUrl = '';
  static const String privacyPolicyUrl = '';
  static const String termsUrl = '';

  // === Bundle IDs ===
  static const String bundleIdAndroid = 'cl.vectium.farmateca';
  static const String bundleIdIOS = 'cl.vectium.farmateca';

  // === Firebase ===
  static const String firebaseProjectId = 'farmateca-app';

  // === RevenueCat (compras in-app) ===
  static const String revenueCatApiKey = '';

  // === IDs de productos ===
  static const String productIdMonthly = 'farmateca_monthly';
  static const String productIdAnnual = 'farmateca_annual';

  // === Entitlements ===
  static const String premiumEntitlement = 'premium';

  // === Base de datos local ===
  static const String dbName = 'farmateca.db';
  static const int dbVersion = 2;

  // === Rutas de assets ===
  /// Ruta al archivo JSON maestro con medicamentos
  /// IMPORTANTE: Este archivo se actualiza periódicamente pero mantiene el mismo nombre
  /// para facilitar deployments. La versión se controla en Git commits.
  static const String jsonAssetPath = 'assets/data/farmateca_master.json';

  // === Estadísticas de la base de datos (v2.1) ===
  static const int totalCompuestos = 200;
  static const int totalMarcas = 2556;
  static const int totalFamilias = 34;
  static const int totalLaboratorios = 151;

  // === Texto de fuentes ===
  static const String sourcesText =
    'Fuentes: Registro Oficial ISP Chile, Folletos de Información al '
    'Profesional y Guías Clínicas MINSAL. Actualización: Base de datos v.2026.01';

  // === Configuración de UI ===
  static const int splashDurationMs = 2000;

  // === Búsqueda ===
  static const int searchDebounceMs = 300;

  // === Límites ===
  static const int maxSearchResults = 50;

  // === Modo debug ===
  static const bool debugMode = true;

  // === Logs de desarrollo ===
  static const bool showJsonParseLog = true;
}
