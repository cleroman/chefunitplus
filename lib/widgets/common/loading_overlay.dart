// =============================================================
// ChefUnitPlus - LoadingOverlay (elegant)
// =============================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: AppColors.mauve,
                        strokeWidth: 3,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================
// Skeleton loader (pour listes)
// =============================================================
class SkeletonLoader extends StatefulWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonLoader({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return Container(
              height: widget.itemHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.divider.withValues(alpha: 0.4),
                    AppColors.divider.withValues(alpha: 0.15),
                    AppColors.divider.withValues(alpha: 0.4),
                  ],
                  stops: [
                    (_ctrl.value - 0.3).clamp(0.0, 1.0),
                    _ctrl.value,
                    (_ctrl.value + 0.3).clamp(0.0, 1.0),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        );
      },
    );
  }
}