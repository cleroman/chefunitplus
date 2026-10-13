// =============================================================
// ChefUnitPlus - Dialogue d'information modal
// Affiche un message simple avec un bouton OK
// =============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String buttonText;

  const InfoDialog({
    super.key,
    this.title = 'Information',
    required this.message,
    this.icon = Icons.info_outline,
    this.iconColor = AppColors.mauve,
    this.buttonText = 'OK',
  });

  /// Affiche le dialogue d'information
  static Future<void> show(
    BuildContext context, {
    String title = 'Information',
    required String message,
    IconData icon = Icons.info_outline,
    Color iconColor = AppColors.mauve,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => InfoDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        buttonText: buttonText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mauve,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
}