import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.success, Icons.check_circle);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.danger, Icons.error_outline);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, AppColors.warning, Icons.warning_amber_outlined);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.mauve, Icons.info_outline);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}