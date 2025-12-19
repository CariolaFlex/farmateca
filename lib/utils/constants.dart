import 'package:flutter/material.dart';

// ============================================================
// CONSTANTES DE MARCA - FARMATECA
// ============================================================

class AppConstants {
  static const String appName = 'Farmateca';
  static const String appNameFull = 'Farmateca Chile';
  static const String appTagline =
      'Diseñada para profesionales y estudiantes de la salud';
  static const String companyName = 'Vectium';
  static const String companyNameFull = 'Vectium SpA';
  static const String supportEmail = 'soporte@farmateca.cl';
  static const String dbVersion = 'v.2026.01';
  static const String sourcesText =
      'Fuentes: Registro Oficial ISP Chile, Folletos de Información al Profesional y Guías Clínicas MINSAL. Actualización: Base de datos $dbVersion';
  static const String dbName = 'farmateca.db';
  static const int dbVersionNumber = 1;
  static const String jsonDataPath = 'assets/data/farmateca_master.json';
  static const int freeCompoundsLimit = 50;
  static const int totalCompounds = 150;
}

// ============================================================
// STRINGS
// ============================================================

class AppStrings {
  // App
  static const String appName = 'Farmateca';
  static const String appSubtitle = 'Tu guía farmacológica';
  static const String appVersion = 'v1.0.0';

  // Onboarding
  static const String onboardingTitle1 = 'Funciona Sin Internet';
  static const String onboardingDesc1 =
      'Accede a toda la información farmacológica sin necesidad de conexión. Ideal para hospitales y zonas sin cobertura.';
  static const String onboardingTitle2 = 'Búsqueda Inteligente';
  static const String onboardingDesc2 =
      'Encuentra medicamentos por nombre comercial, principio activo o familia farmacológica en segundos.';
  static const String onboardingTitle3 = 'Para Profesionales';
  static const String onboardingDesc3 =
      'Diseñada para profesionales y estudiantes de la salud con información confiable y actualizada.';
  static const String skip = 'Saltar';
  static const String next = 'Siguiente';
  static const String back = 'Atrás';
  static const String getStarted = 'Comenzar';

  // Auth
  static const String welcomeBack = 'Bienvenido de nuevo';
  static const String loginSubtitle = 'Inicia sesión para continuar';
  static const String createAccount = 'Crear cuenta';
  static const String registerSubtitle = 'Completa tus datos para registrarte';
  static const String login = 'Iniciar Sesión';
  static const String register = 'Registrarse';
  static const String email = 'Correo electrónico';
  static const String emailHint = 'tu@correo.com';
  static const String password = 'Contraseña';
  static const String passwordHint = '••••••••';
  static const String confirmPassword = 'Confirmar contraseña';
  static const String confirmPasswordHint = 'Repite tu contraseña';
  static const String fullName = 'Nombre completo';
  static const String fullNameHint = 'Ej: Juan Pérez';
  static const String profession = 'Profesión';
  static const String selectProfession = 'Selecciona tu profesión';
  static const String rememberMe = 'Recordarme';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String noAccount = '¿No tienes cuenta?';
  static const String alreadyHaveAccount = '¿Ya tienes cuenta?';
  static const String createAccountButton = 'Crear Cuenta';
  static const String orContinueWith = 'o continúa con';
  static const String recoverPassword = 'Recuperar Contraseña';
  static const String recoverPasswordDesc =
      'Ingresa tu correo y te enviaremos instrucciones para restablecer tu contraseña.';
  static const String sendInstructions = 'Enviar Instrucciones';
  static const String backToLogin = 'Volver al inicio de sesión';
  static const String checkEmail = '¡Revisa tu correo!';
  static const String instructionsSent =
      'Te enviamos instrucciones para restablecer tu contraseña.';

  // Terms
  static const String termsAccept = 'Acepto los';
  static const String termsAndConditions = 'Términos y Condiciones';
  static const String termsTitle = 'Términos y Condiciones';
  static const String acceptTerms = 'Aceptar';

  // Errors
  static const String errorGeneric = 'Ha ocurrido un error. Intenta de nuevo.';
  static const String errorTermsRequired =
      'Debes aceptar los términos y condiciones';
  static const String errorInvalidEmail = 'Ingresa un correo válido';
  static const String errorPasswordShort =
      'La contraseña debe tener al menos 6 caracteres';
  static const String errorPasswordMatch = 'Las contraseñas no coinciden';
  static const String errorNameRequired = 'Ingresa tu nombre';
  static const String errorProfessionRequired = 'Selecciona tu profesión';

  // Professions
  static const List<String> professions = [
    'Médico/a',
    'Enfermero/a',
    'Químico/a Farmacéutico/a',
    'Matrón/a',
    'Kinesiólogo/a',
    'Nutricionista',
    'Odontólogo/a',
    'Tecnólogo/a Médico/a',
    'Paramédico/a',
    'Estudiante de Medicina',
    'Estudiante de Enfermería',
    'Estudiante de Salud',
    'Otro profesional de salud',
  ];
}

// ============================================================
// COLORES
// ============================================================

class AppColors {
  static const Color primaryBlue = Color(0xFF6B4CE6);
  static const Color primaryDark = Color(0xFF5038B8);
  static const Color secondaryTeal = Color(0xFF00D9FF);
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color alertRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF1E1E1E);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryDark],
  );
}

// ============================================================
// DIMENSIONES
// ============================================================

class AppDimens {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Font sizes
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontTitle = 24.0;
  static const double fontHeader = 32.0;
}

// ============================================================
// DURACIONES
// ============================================================

class AppDurations {
  static const Duration splash = Duration(milliseconds: 2500);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

// ============================================================
// KEYS DE PREFERENCIAS
// ============================================================

class PrefsKeys {
  static const String onboardingCompleted = 'onboarding_complete';
  static const String isDarkMode = 'is_dark_mode';
  static const String lastEmail = 'last_email';
  static const String rememberMe = 'remember_me';
}

// ============================================================
// TEMAS
// ============================================================

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cardDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
