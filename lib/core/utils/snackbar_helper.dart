// =============================================================
// ChefUnitPlus - Messages temporaires (SnackBars)
// Standardise les retours utilisateurs : succs, erreur, info
// =============================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class SnackbarHelper {
  SnackbarHelper._(); // Empche l'instanciation

  // ===========================================================
  // o. SUCC^S (VERT)
  // ===========================================================
  static void success(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  // ===========================================================
  // O ERREUR (ROUGE)
  // ===========================================================
  static void error(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.danger,
      icon: Icons.error_outline,
      duration: const Duration(seconds: 4),
    );
  }

  // ===========================================================
  // s AVERTISSEMENT (AMBRE / KAKI)
  // ===========================================================
  static void warning(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_outlined,
    );
  }

  // ===========================================================
  // " INFORMATION (MAUVE)
  // ===========================================================
  static void info(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.mauve,
      icon: Icons.info_outline,
    );
  }

  // ===========================================================
  // Y"" NOTIFICATION NEUTRE
  // ===========================================================
  static void neutral(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.textMuted,
    );
  }

  // ===========================================================
  // Y"" CHARGEMENT
  // ===========================================================
  static void loading(BuildContext context, [String message = 'Chargement...']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.mauve,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Ferme le snack courant
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  // ===========================================================
  // YZ RACCOURCIS CONTEXTUELS
  // ===========================================================
  static void networkError(BuildContext context) =>
      error(context, AppStrings.errorNetwork);

  static void serverError(BuildContext context) =>
      error(context, AppStrings.errorServer);

  static void unauthorized(BuildContext context) =>
      error(context, AppStrings.errorUnauthorized);

  static void comingSoon(BuildContext context) =>
      info(context, 'Fonctionnalit bientt disponible');

  static void copied(BuildContext context, [String? label]) =>
      success(context, '${label ?? 'Texte'} copi dans le presse-papier');

  // ===========================================================
  // YZ IMPL?MENTATION INTERNE
  // ===========================================================
  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),
    );
  }
}