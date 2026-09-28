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
      case EnrollmentStatus.completed:
        return AppColors.success;
      case EnrollmentStatus.pendingDirector:
      case EnrollmentStatus.pendingPayment:
        return AppColors.warning;
      case EnrollmentStatus.rejected:
      case EnrollmentStatus.failed:
        return AppColors.danger;
      case EnrollmentStatus.cancelled:
      case EnrollmentStatus.unknown:
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
      case EnrollmentStatus.completed:
        return Icons.emoji_events_outlined;
      case EnrollmentStatus.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: compact ? 10 : 14),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}