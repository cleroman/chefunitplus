// ============================================================
// ChefUnitPlus - Adaptateur de theme Directeur
// Genere automatiquement le 2026-09-25 12:30:19
// Objectif : appliquer le theme Admin au dashboard Directeur
//            sans perdre les fonctionnalites du Directeur.
// ============================================================

import 'package:flutter/material.dart';

class DirectorThemeAdapter {
  DirectorThemeAdapter._();

  // --- Couleurs principales (alignees sur l'Admin) ---
  static const Color primary        = Color(0xFF6A1B9A); // mauve profond
  static const Color primaryDark    = Color(0xFF4A148C);
  static const Color primaryLight   = Color(0xFF9C27B0);
  static const Color accent         = Color(0xFFCE93D8);
  static const Color background     = Color(0xFFF5F0FA);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color textPrimary    = Color(0xFF1A1A1A);
  static const Color textSecondary  = Color(0xFF666666);
  static const Color divider        = Color(0xFFE0D6EC);
  static const Color success        = Color(0xFF2E7D32);
  static const Color warning        = Color(0xFFF9A825);
  static const Color error          = Color(0xFFC62828);

  // --- Gradient principal (TopBar / headers) ---
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Gradient secondaire (cartes) ---
  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- Rayons ---
  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge  = 22.0;

  // --- Espacements ---
  static const double gapXs = 4.0;
  static const double gapSm = 8.0;
  static const double gapMd = 16.0;
  static const double gapLg = 24.0;
  static const double gapXl = 32.0;

  // --- ThemeData complet ---
  static ThemeData theme() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      iconTheme: const IconThemeData(color: primary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: gapLg, vertical: gapMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
