import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/enrollment.dart';

class StatusChip extends StatelessWidget {
  final EnrollmentStatus status;
  final bool compact;

  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  Color get _color {
    switch (status) {
      case EnrollmentStatus.approved:
        return AppColors.success;
      case EnrollmentStatus.pendingDirector:
      case EnrollmentStatus.pendingPayment:
        return AppColors.warning;
      case EnrollmentStatus.rejected:
      case EnrollmentStatus.failed:
        return AppColors.danger;
      case EnrollmentStatus.cancelled:
        return AppColors.textMuted;
    }
  }

  IconData get _icon {
    switch (status) {
      case EnrollmentStatus.approved:
        return Icons.check_circle_outline;
      case EnrollmentStatus.pendingDirector:
        return Icons.hourglass_empty;
      case EnrollmentStatus.pendingPayment:
        return Icons.payment_outlined;
      case EnrollmentStatus.rejected:
        return Icons.cancel_outlined;
      case EnrollmentStatus.failed:
        return Icons.error_outline;
      case EnrollmentStatus.cancelled:
        return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 12 : 14, color: _color),
          SizedBox(width: compact ? 3 : 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}