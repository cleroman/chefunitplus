// ============================================================
// ChefUnitPlus - Adaptateur de theme Directeur
// --------------------------------------------
// Objectif :
//   Le dashboard Directeur garde TOUTES ses fonctionnalites
//   mais adopte le theme visuel du dashboard Admin.
//
// Utilisation :
//   Dans MaterialApp :
//     theme: DirectorThemeAdapter.theme(),
// ============================================================

import 'package:flutter/material.dart';

class DirectorThemeAdapter {
  DirectorThemeAdapter._();

  // ------------------------------------------------------------
  // 1. COULEURS (alignees sur le dashboard Admin)
  // ------------------------------------------------------------
  static const Color primary       = Color(0xFF8E24AA); // mauve Admin
  static const Color primaryDark   = Color(0xFF6A1B9A); // mauve profond
  static const Color primaryLight  = Color(0xFFAB47BC); // mauve clair
  static const Color secondary     = Color(0xFF3949AB); // bleu Admin
  static const Color tertiary      = Color(0xFF00897B); // teal Admin
  static const Color success       = Color(0xFF43A047); // vert Admin
  static const Color warning       = Color(0xFFF9A825);
  static const Color danger        = Color(0xFFE53935);

  static const Color background    = Color(0xFFF7F3FA); // fond clair mauve
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textMuted     = Color(0xFF6B6B6B);
  static const Color divider       = Color(0xFFE6DDF0);

  // ------------------------------------------------------------
  // 2. GRADIENTS
  // ------------------------------------------------------------
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondary, tertiary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ------------------------------------------------------------
  // 3. RAYONS & ESPACEMENTS
  // ------------------------------------------------------------
  static const double radiusSm = 8.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 22.0;
  static const double radiusXl = 30.0;

  static const double gapXs = 4.0;
  static const double gapSm = 8.0;
  static const double gapMd = 16.0;
  static const double gapLg = 24.0;
  static const double gapXl = 32.0;

  // ------------------------------------------------------------
  // 4. THEME COMPLET
  // ------------------------------------------------------------
  static ThemeData theme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
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
        iconTheme: IconThemeData(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 3,
        shadowColor: primary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: gapLg, vertical: gapMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: gapMd, vertical: gapMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),

      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ).copyWith(
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: textPrimary,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          color: textMuted,
        ),
      ),

      iconTheme: const IconThemeData(color: primary),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: surface,
        elevation: 4,
      ),
    );
  }

  // ------------------------------------------------------------
  // 5. HELPERS
  // ------------------------------------------------------------
  static BoxDecoration headerDecoration() => const BoxDecoration(
        gradient: headerGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(radiusLg),
        ),
      );

  static BoxDecoration cardDecoration() => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusMd),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static TextStyle titleStyle() => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle subtitleStyle() => const TextStyle(
        fontSize: 13,
        color: textMuted,
      );

  // ============================================================
  // HELPERS - Boutons
  // ============================================================
  static ButtonStyle directorPrimaryButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: gapLg, vertical: gapMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      );

  static ButtonStyle directorDangerButtonStyle() => ElevatedButton.styleFrom(
        backgroundColor: danger,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: gapLg, vertical: gapMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      );

  // ============================================================
  // HELPERS - Input
  // ============================================================
  static InputDecoration directorInputDecoration({
    required String label,
    IconData? icon,
    String? hint,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: gapMd,
          vertical: gapMd,
        ),
        prefixIcon: icon != null ? Icon(icon, color: textMuted) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      );
}

