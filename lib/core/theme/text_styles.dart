// =============================================================
// ChefUnitPlus - Typographie
// Police : Poppins (titres) + Inter (corps)
// =============================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTextStyles {
  AppTextStyles._();

  // ===========================================================
  // Y. TEXT STYLES STATIQUES (indpendants du thme)
  // ===========================================================

  // ------------------ DISPLAY ------------------
  static const TextStyle displayLarge = TextStyle(
    fontSize: AppSizes.fontDisplay,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ------------------ HEADLINES ------------------
  static const TextStyle headlineLarge = TextStyle(
    fontSize: AppSizes.fontXxl,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: AppSizes.fontXl,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: AppSizes.fontLg,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ------------------ TITLES ------------------
  static const TextStyle titleLarge = TextStyle(
    fontSize: AppSizes.fontLg,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: AppSizes.fontMd,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: AppSizes.fontSm,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ------------------ BODY ------------------
  static const TextStyle bodyLarge = TextStyle(
    fontSize: AppSizes.fontMd,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: AppSizes.fontSm,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: AppSizes.fontXs,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ------------------ LABELS ------------------
  static const TextStyle labelLarge = TextStyle(
    fontSize: AppSizes.fontMd,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: AppSizes.fontSm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: AppSizes.fontXs,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  // ------------------ STYLES SP?CIAUX ------------------
  static const TextStyle button = TextStyle(
    fontSize: AppSizes.fontMd,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppSizes.fontXs,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textMuted,
  );

  static const TextStyle price = TextStyle(
    fontSize: AppSizes.fontXl,
    fontWeight: FontWeight.w700,
    color: AppColors.mauve,
  );

  // ===========================================================
  // YZ CONSTRUCTION DU TEXTTHEME (avec couleurs dynamiques)
  // ===========================================================
  static TextTheme buildTextTheme({
    required Color primary,
    required Color muted,
  }) {
    return TextTheme(
      // Display
      displayLarge: displayLarge.copyWith(color: primary),
      displayMedium: displayMedium.copyWith(color: primary),
      displaySmall: displaySmall.copyWith(color: primary),

      // Headlines
      headlineLarge: headlineLarge.copyWith(color: primary),
      headlineMedium: headlineMedium.copyWith(color: primary),
      headlineSmall: headlineSmall.copyWith(color: primary),

      // Titles
      titleLarge: titleLarge.copyWith(color: primary),
      titleMedium: titleMedium.copyWith(color: primary),
      titleSmall: titleSmall.copyWith(color: primary),

      // Body
      bodyLarge: bodyLarge.copyWith(color: primary),
      bodyMedium: bodyMedium.copyWith(color: primary),
      bodySmall: bodySmall.copyWith(color: muted),

      // Labels
      labelLarge: labelLarge.copyWith(color: primary),
      labelMedium: labelMedium.copyWith(color: primary),
      labelSmall: labelSmall.copyWith(color: muted),
    );
  }

  // ===========================================================
  // YZ HELPERS PAR CONTEXTE
  // ===========================================================
  static TextStyle get screenTitle => headlineLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get sectionTitle => titleLarge.copyWith(
        fontWeight: FontWeight.w700,
      );

  static TextStyle get cardTitle => titleMedium.copyWith(
        fontWeight: FontWeight.w600,
      );

  static TextStyle get cardSubtitle => bodyMedium.copyWith(
        color: AppColors.textMuted,
      );

  static TextStyle get errorText => bodySmall.copyWith(
        color: AppColors.danger,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get successText => bodySmall.copyWith(
        color: AppColors.success,
        fontWeight: FontWeight.w500,
      );
}