import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LoadingState extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingState({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.mauve;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: c),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}