// =============================================================
// ChefUnitPlus - Dialogue d'erreur modal
// Affiche les erreurs de maniere professionnelle
// =============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<String> details;
  final String? buttonText;

  const ErrorDialog({
    super.key,
    this.title = 'Erreur',
    required this.message,
    this.details = const [],
    this.buttonText = 'OK',
  });

  /// Affiche le dialogue d'erreur
  static Future<void> show(
    BuildContext context, {
    String title = 'Erreur',
    required String message,
    List<String> details = const [],
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ErrorDialog(
        title: title,
        message: message,
        details: details,
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
              color: AppColors.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.danger,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message principal
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            // Details (liste d'erreurs)
            if (details.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details :',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...details.map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: AppColors.danger,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
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
              buttonText ?? 'OK',
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