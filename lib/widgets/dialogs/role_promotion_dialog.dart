import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/role_constants.dart';
import '../../models/user.dart';


Future<UserRole?> showRolePromotionDialog({
  required BuildContext context,
  required User user,
  required List<UserRole> availableRoles,
}) {
  return showModalBottomSheet<UserRole>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Promouvoir ${user.fullName}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rôle actuel : ${user.role.label}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          ...availableRoles.map(
            (role) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: role.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(role.icon, color: role.color, size: 20),
              ),
              title: Text(role.label),
              subtitle: Text(role.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(ctx, role),
            ),
          ),
        ],
      ),
    ),
  );
}