// =============================================================
// ChefUnitPlus - Gradients rutilisables
// Signatures visuelles : Mauve ?' Kaki (branding principal)
// =============================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppGradients {
  AppGradients._(); // Empche l'instanciation

  // ===========================================================
  // YZ GRADIENTS DE MARQUE
  // ===========================================================

  /// Gradient principal : Mauve ?' Kaki (headers, AppBar personnalise)
  static const LinearGradient header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.mauve, AppColors.kaki],
  );

  /// Gradient diagonal pour badges / hero cards
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.mauveDark, AppColors.mauve, AppColors.kaki],
    stops: [0.0, 0.5, 1.0],
  );

  /// Gradient vertical doux (backgrounds de sections)
  static const LinearGradient softVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.mauveSoft, Color(0xFFF8F8EC)],
  );

  // ===========================================================
  // YZ GRADIENTS PAR R"LE
  // ===========================================================

  static const LinearGradient admin = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.mauveDark, AppColors.mauve],
  );

  static const LinearGradient directeur = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.kakiDark, AppColors.kaki],
  );

  static const LinearGradient formateur = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.successDark, AppColors.success],
  );

  static const LinearGradient apprenant = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.mauve, AppColors.mauveLight],
  );

  // ===========================================================
  // YZ GRADIENTS D'?TAT
  // ===========================================================

  /// Succs (vert)
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.success, AppColors.successLight],
  );

  /// Danger (rouge)
  static const LinearGradient danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.danger, AppColors.dangerLight],
  );

  /// Avertissement (ambre)
  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.warning, Color(0xFFFFCC80)],
  );

  // ===========================================================
  // YZ GRADIENTS DE CARTES
  // ===========================================================

  static const LinearGradient cardSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.mauveSoft, Color(0xFFF5F5E0)],
  );

  static const LinearGradient cardKaki = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.kakiSoft, AppColors.kakiLight],
  );

  static const LinearGradient cardMauve = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.mauveSoft, AppColors.mauveLight],
  );

  // ===========================================================
  // YZ OVERLAYS (au-dessus d'images)
  // ===========================================================

  /// Overlay sombre progressif (pour lisibilit sur image)
  static const LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
    stops: [0.5, 1.0],
  );

  /// Overlay mauve transparent
  static const LinearGradient mauveOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, AppColors.mauveDark],
    stops: [0.4, 1.0],
  );

  // ===========================================================
  // YZ M?THODE DYNAMIQUE PAR R"LE
  // ===========================================================

  /// Retourne le gradient correspondant  un rle
  /// (utile pour les headers personnaliss des dashboards)
  static LinearGradient forRole(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
      case 'administrateur':
        return admin;
      case 'directeur':
        return directeur;
      case 'formateur':
        return formateur;
      case 'apprenant':
      default:
        return apprenant;
    }
  }
}