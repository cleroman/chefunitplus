// =============================================================
// ChefUnitPlus - SettingsScreen
// Page des parametres de l'utilisateur
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final user = authCtrl.currentUser;
    final themeCtrl = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Parametres'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PROFIL
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.mauve.withValues(alpha: 0.15),
                  child: Text(
                    _initials(user?.fullName ?? '?'),
                    style: const TextStyle(
                      color: AppColors.mauve,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Utilisateur',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mauve.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user?.role.name ?? 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mauve,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Application'),
          const SizedBox(height: 8),
          _tile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: themeCtrl.mode == ThemeMode.dark ? 'Sombre' : 'Clair',
            onTap: () {
              themeCtrl.toggle();
            },
          ),
          _tile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Gerer les notifications',
            onTap: () {},
          ),
          _tile(
            icon: Icons.language_outlined,
            title: 'Langue',
            subtitle: 'Francais',
            onTap: () {},
          ),

          const SizedBox(height: 20),
          _sectionTitle('Compte'),
          const SizedBox(height: 8),
          _tile(
            icon: Icons.person_outline,
            title: 'Mon profil',
            subtitle: 'Voir et modifier mes informations',
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          _tile(
            icon: Icons.lock_outline,
            title: 'Changer le mot de passe',
            subtitle: 'Securite du compte',
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),

          const SizedBox(height: 20),
          _sectionTitle('A propos'),
          const SizedBox(height: 8),
          _tile(
            icon: Icons.info_outline,
            title: 'ChefUnitPlus',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // DECONNEXION
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Deconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                authCtrl.logout();
                Navigator.pushReplacementNamed(context, '/auth/login');
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      );

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.mauve.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.mauve, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}