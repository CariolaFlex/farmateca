// lib/utils/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // === PALETA PRINCIPAL (TEAL/AZUL) ===
  static const Color primaryDark = Color(0xFF1e9db9);
  static const Color primaryLight = Color(0xFFb4e5f4);
  static const Color primaryMedium = Color(0xFF0c88ba);
  static const Color secondaryDark = Color(0xFF147790);
  static const Color secondaryLight = Color(0xFF27c2d1);

  // === PALETA GRISES ===
  static const Color grayDark = Color(0xFF5d6067);
  static const Color grayLight = Color(0xFFdcdee2);
  static const Color grayMediumDark = Color(0xFF43464c);
  static const Color grayMedium = Color(0xFF9fa2a9);
  static const Color grayLightMedium = Color(0xFF7f828a);

  // === COLORES FUNCIONALES ===
  static const Color premiumGold = Color(0xFFFFB800);
  static const Color favoritesRed = Color(0xFFFF6B6B);
  static const Color comingSoonGray = grayMedium;

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);

  // === COLORES ESPECÍFICOS UI (según Logica-Json.pdf) ===
  static const Color efectosAdversosBackground = Color(0xFFE8F5E9);
  static const Color efectosAdversosBorder = Color(0xFF4CAF50);
  static const Color contraindicacionesBackground = Color(0xFFFFEBEE);
  static const Color contraindicacionesBorder = Color(0xFFF44336);

  // === BACKGROUNDS ===
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF2C2C2C);

  // === TEXT ===
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);
}
