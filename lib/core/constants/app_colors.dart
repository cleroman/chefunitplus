// =============================================================
// ChefUnitPlus - Palette officielle
// Couleurs : Mauve (primaire)  Kaki (secondaire)  Vert  Rouge
// =============================================================

import 'package:flutter/material.dart';


class AppColors {
  AppColors._(); // Empche l'instanciation

  // -----------------------------------------------------------
  // YY PRIMAIRE ?" MAUVE
  // -----------------------------------------------------------
  static const Color mauve         = Color(0xFF7B4B94); // Primaire
  static const Color mauveLight    = Color(0xFFA57BB8); // Hover / focus
  static const Color mauveDark     = Color(0xFF4A2A5E); // Titres forts
  static const Color mauveSoft     = Color(0xFFEFE7F3); // Backgrounds doux

  // -----------------------------------------------------------
  // YY SECONDAIRE ?" KAKI
  // -----------------------------------------------------------
  static const Color kaki          = Color(0xFF8B8B4A); // Secondaire
  static const Color kakiLight     = Color(0xFFC9C9A0); // Backgrounds doux
  static const Color kakiDark      = Color(0xFF5C5C30); // Accents foncs
  static const Color kakiSoft      = Color(0xFFF5F5E0); // Cartes douces

  // -----------------------------------------------------------
  // YY SUCC^S ?" VERT
  // -----------------------------------------------------------
  static const Color success       = Color(0xFF2E7D32); // Valid, approuv
  static const Color successLight  = Color(0xFF4CAF50); // Hover
  static const Color successSoft   = Color(0xFFC8E6C9); // Fonds succs
  static const Color successDark   = Color(0xFF1B5E20); // Texte fonc

  // -----------------------------------------------------------
  // Y" DANGER ?" ROUGE
  // -----------------------------------------------------------
  static const Color danger        = Color(0xFFC62828); // Erreur, refus
  static const Color dangerLight   = Color(0xFFE53935); // Hover
  static const Color dangerSoft    = Color(0xFFFFCDD2); // Fonds erreurs
  static const Color dangerDark    = Color(0xFF8E0000); // Texte fonc

  // -----------------------------------------------------------
  // YY AVERTISSEMENT ?" AMBRE (tats "en attente")
  // -----------------------------------------------------------
  static const Color warning       = Color(0xFFF9A825);
  static const Color warningSoft   = Color(0xFFFFF8E1);

  // -----------------------------------------------------------
  // s NEUTRES ?" LIGHT MODE
  // -----------------------------------------------------------
  static const Color background    = Color(0xFFF5F3F7); // Fond d'cran
  static const Color surface       = Color(0xFFFFFFFF); // Cards / dialogs
  static const Color surfaceAlt    = Color(0xFFFAF9FC); // Surface alternative
  static const Color divider       = Color(0xFFE0DCE5); // Sparateurs
  static const Color textPrimary   = Color(0xFF1C1B1F); // Texte principal
  static const Color textMuted     = Color(0xFF6E6A72); // Sous-titres
  static const Color textDisabled  = Color(0xFFBDBDBD); // Dsactiv

  // -----------------------------------------------------------
  // s NEUTRES ?" DARK MODE
  // -----------------------------------------------------------
  static const Color darkBackground = Color(0xFF1A1020); // Fond sombre
  static const Color darkSurface    = Color(0xFF251A2B); // Cards sombres
  static const Color darkDivider    = Color(0xFF3A2D42); // Sparateurs
  static const Color darkTextPrimary = Color(0xFFEDE7F0); // Texte clair
  static const Color darkTextMuted   = Color(0xFFB0A7B8); // Texte attnu

  // -----------------------------------------------------------
  // YZ COULEURS SP?CIFIQUES PAR R"LE
  // -----------------------------------------------------------
  static const Color roleAdmin      = mauve;       // Administrateur
  static const Color roleDirecteur  = kaki;        // Directeur
  static const Color roleFormateur  = success;     // Formateur
  static const Color roleApprenant  = textMuted;   // Apprenant

  // -----------------------------------------------------------
  // Ys STATUTS D'INSCRIPTION
  // -----------------------------------------------------------
  static const Color statusApproved       = success;
  static const Color statusPendingDirector = warning;
  static const Color statusPendingPayment = kaki;
  static const Color statusRejected       = danger;
  static const Color statusFailed         = dangerDark;
}