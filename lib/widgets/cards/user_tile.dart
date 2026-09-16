// =============================================================
// ChefUnitPlus - UserTile (premium)
// =============================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/role_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showEmail;
  final bool showRoleBadge;

  const UserTile({
    super.key,
    required this.user,
    this.trailing,
    this.onTap,
    this.showEmail = true,
    this.showRoleBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: user.role.color.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
            border: user.isActive
                ? null
                : Border.all(
                    color: AppColors.danger.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
          ),
          child: Row(
            children: [
              // Avatar avec bordure de rôle
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      user.role.color,
                      user.role.color.withValues(alpha: 0.5),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      Formatters.initials(user.fullName),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: user.role.color,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName.isEmpty ? 'Utilisateur' : user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (!user.isActive)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.dangerSoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SUSPENDU',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dangerDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (showEmail) ...[
                      const SizedBox(height: 3),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    if (showRoleBadge) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: user.role.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.role.icon,
                              size: 10,
                              color: user.role.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.role.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: user.role.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ] else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}