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
  static const String firebaseProjectId = 'farmateca';

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

  // === Lista de profesiones ===
  static const List<String> professions = [
    'Médico',
    'Enfermera/o',
    'Matrona/ón',
    'Químico Farmacéutico',
    'Estudiante de Medicina',
    'Estudiante de Enfermería',
    'Otro',
  ];
}

/// ==========================================
/// DIMENSIONES Y ESPACIADOS
/// ==========================================
class AppDimens {
  // Padding general
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusCircular = 50.0;

  // Elevaciones
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // Tamaños de iconos
  static const double iconS = 18.0;
  static const double iconM = 24.0;
  static const double iconL = 28.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 60.0;

  // Tamaños de fuente
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 24.0;
  static const double fontTitle = 28.0;
  static const double fontHero = 32.0;
}

/// ==========================================
/// DURACIONES DE ANIMACIÓN
/// ==========================================
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 3500);
}
