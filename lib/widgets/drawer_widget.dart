// =============================================================
// ChefUnitPlus - DrawerWidget
// Menu lateral harmonise avec logo
// =============================================================

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/user.dart';
import 'user_avatar.dart';
class DrawerItem {
  final IconData icon;
  final String label;
  final String? route;
  final bool selected;
  final int? badge;
  final VoidCallback? onTap;

  const DrawerItem({
    required this.icon,
    required this.label,
    this.route,
    this.selected = false,
    this.badge,
    this.onTap,
  });
}

class DrawerWidget extends StatelessWidget {
  final User? user;
  final List<DrawerItem> items;
  final VoidCallback? onLogout;
  final String roleLabel;

  const DrawerWidget({
    super.key,
    required this.user,
    required this.items,
    this.onLogout,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header avec logo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.mauve, AppColors.kaki],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Logo
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school,
                          color: AppColors.mauve,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ChefUnitPlus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Plateforme de formation',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // User info
                Row(
                  children: [
                    UserAvatar(
                      radius: 22,
                      photoUrl: user?.photoUrl,
                      initials: user?.initials ?? '?',
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Utilisateur',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            roleLabel,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: items.map((item) => _drawerItem(context, item)).toList(),
            ),
          ),

          // Footer avec deconnexion
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: const Text(
                  'Se deconnecter',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: onLogout,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, DrawerItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: item.selected
            ? AppColors.mauve.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            item.icon,
            color: item.selected ? AppColors.mauve : AppColors.textMuted,
          ),
          title: Text(
            item.label,
            style: TextStyle(
              color: item.selected ? AppColors.mauve : AppColors.textPrimary,
              fontWeight: item.selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          trailing: item.badge != null && item.badge! > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.badge}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
          onTap: item.onTap ?? () => Navigator.pop(context),
        ),
      ),
    );
  }
}