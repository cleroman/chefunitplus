// =============================================================
// ChefUnitPlus - RoleBadge (elegant)
// =============================================================

import 'package:flutter/material.dart';
import '../../core/constants/role_constants.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool compact;
  final bool showIcon;
  final bool filled;

  const RoleBadge({
    super.key,
    required this.role,
    this.compact = false,
    this.showIcon = true,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? role.color
        : role.color.withValues(alpha: 0.12);
    final fg = filled ? Colors.white : role.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        gradient: filled
            ? LinearGradient(
                colors: [
                  role.color,
                  role.color.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: filled ? null : bg,
        borderRadius: BorderRadius.circular(20),
        border: filled
            ? null
            : Border.all(
                color: role.color.withValues(alpha: 0.25),
                width: 1,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(role.icon, size: compact ? 10 : 13, color: fg),
            SizedBox(width: compact ? 3 : 5),
          ],
          Text(
            role.label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}