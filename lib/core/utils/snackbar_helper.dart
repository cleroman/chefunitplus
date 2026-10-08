// =============================================================
// ChefUnitPlus - Messages temporaires (SnackBars)
// Version moderne : lisible sur web et mobile
// =============================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class SnackbarHelper {
  SnackbarHelper._(); // Empêche l'instanciation

  // ===========================================================
  // ✅ SUCCÈS (VERT)
  // ===========================================================
  static void success(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: _SnackType.success,
      icon: Icons.check_circle_outline,
      duration: const Duration(seconds: 4),
    );
  }

  // ===========================================================
  // ❌ ERREUR (ROUGE LISIBLE)
  // ===========================================================
  static void error(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: _SnackType.error,
      icon: Icons.error_outline,
      duration: const Duration(seconds: 6),
      showCloseButton: true,
    );
  }

  // ===========================================================
  // ⚠️ AVERTISSEMENT (AMBRE)
  // ===========================================================
  static void warning(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: _SnackType.warning,
      icon: Icons.warning_amber_outlined,
      duration: const Duration(seconds: 5),
      showCloseButton: true,
    );
  }

  // ===========================================================
  // ℹ️ INFORMATION (MAUVE)
  // ===========================================================
  static void info(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: _SnackType.info,
      icon: Icons.info_outline,
      duration: const Duration(seconds: 5),
    );
  }

  // ===========================================================
  // 💬 NOTIFICATION NEUTRE
  // ===========================================================
  static void neutral(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      type: _SnackType.neutral,
      duration: const Duration(seconds: 4),
    );
  }

  // ===========================================================
  // ⏳ CHARGEMENT
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
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Ferme le snack courant
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  // ===========================================================
  // RACCOURCIS CONTEXTUELS
  // ===========================================================
  static void networkError(BuildContext context) =>
      error(context, AppStrings.errorNetwork);

  static void serverError(BuildContext context) =>
      error(context, AppStrings.errorServer);

  static void unauthorized(BuildContext context) =>
      error(context, AppStrings.errorUnauthorized);

  static void comingSoon(BuildContext context) =>
      info(context, 'Fonctionnalité bientôt disponible');

  static void copied(BuildContext context, [String? label]) =>
      success(context, '${label ?? 'Texte'} copié dans le presse-papier');

  // ===========================================================
  // IMPLÉMENTATION INTERNE
  // ===========================================================
  static void _show({
    required BuildContext context,
    required String message,
    required _SnackType type,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
    bool showCloseButton = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    final colors = _getColors(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colors.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  message,
                  style: TextStyle(
                    color: colors.textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (showCloseButton) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    color: colors.textColor.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: colors.background,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1.5),
        ),
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static _SnackColors _getColors(_SnackType type) {
    switch (type) {
      case _SnackType.success:
        return _SnackColors(
          background: Colors.white,
          border: AppColors.success,
          iconBg: AppColors.success.withValues(alpha: 0.12),
          iconColor: AppColors.success,
          textColor: const Color(0xFF1B5E20),
        );
      case _SnackType.error:
        return _SnackColors(
          background: Colors.white,
          border: AppColors.danger,
          iconBg: AppColors.danger.withValues(alpha: 0.12),
          iconColor: AppColors.danger,
          textColor: const Color(0xFFB71C1C),
        );
      case _SnackType.warning:
        return _SnackColors(
          background: Colors.white,
          border: AppColors.warning,
          iconBg: AppColors.warning.withValues(alpha: 0.12),
          iconColor: AppColors.warning,
          textColor: const Color(0xFF8B6914),
        );
      case _SnackType.info:
        return _SnackColors(
          background: Colors.white,
          border: AppColors.mauve,
          iconBg: AppColors.mauve.withValues(alpha: 0.12),
          iconColor: AppColors.mauve,
          textColor: const Color(0xFF4A148C),
        );
      case _SnackType.neutral:
        return _SnackColors(
          background: Colors.white,
          border: AppColors.textMuted,
          iconBg: AppColors.textMuted.withValues(alpha: 0.12),
          iconColor: AppColors.textMuted,
          textColor: const Color(0xFF424242),
        );
    }
  }
}

enum _SnackType { success, error, warning, info, neutral }

class _SnackColors {
  final Color background;
  final Color border;
  final Color iconBg;
  final Color iconColor;
  final Color textColor;

  _SnackColors({
    required this.background,
    required this.border,
    required this.iconBg,
    required this.iconColor,
    required this.textColor,
  });
}