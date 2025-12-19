// lib/utils/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // === TÍTULOS ===
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // === CUERPO ===
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // === ESPECIALES ===
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );

  static const TextStyle sources = TextStyle(
    fontSize: 10,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 14,
    color: AppColors.textHint,
  );

  // === BOTONES ===
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // === ETIQUETAS ===
  static const TextStyle tag = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle premium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.premiumGold,
  );
}
