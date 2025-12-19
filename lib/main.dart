// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'test_json_parse.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Firebase PRIMERO
  await Firebase.initializeApp();

  // 2. Test del JSON (temporal para desarrollo)
  await testJsonParse();

  // 3. Ejecutar la app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers de autenticación y onboarding
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        // Provider de tema (REQUERIDO por HomeScreen y SettingsScreen)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      // Consumer para reaccionar a cambios de tema
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Farmateca Chile',
            debugShowCheckedModeBanner: false,

            // Temas
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,

            // Pantalla inicial
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
