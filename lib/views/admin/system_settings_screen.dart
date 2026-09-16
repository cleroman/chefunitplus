// =============================================================
// ChefUnitPlus - SystemSettingsScreen
// Paramtres systme de la plateforme
// =============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/snackbar_helper.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _maintenance = false;
  bool _allowSignup = true;
  bool _emailNotif = true;
  bool _pushNotif = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.systemSettings),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          const _SectionLabel('Systme'),
          _SwitchTile(
            icon: Icons.build_outlined,
            title: 'Mode maintenance',
            subtitle: 'Dsactive l\'accs pour tous les utilisateurs',
            value: _maintenance,
            color: AppColors.danger,
            onChanged: (v) => setState(() => _maintenance = v),
          ),
          _SwitchTile(
            icon: Icons.person_add_outlined,
            title: 'Autoriser les inscriptions',
            subtitle: 'Permet la cration de nouveaux comptes',
            value: _allowSignup,
            color: AppColors.success,
            onChanged: (v) => setState(() => _allowSignup = v),
          ),
          const SizedBox(height: 24),

          const _SectionLabel('Notifications'),
          _SwitchTile(
            icon: Icons.email_outlined,
            title: 'Notifications email',
            subtitle: 'Envoi d\'emails aux utilisateurs',
            value: _emailNotif,
            color: AppColors.kaki,
            onChanged: (v) => setState(() => _emailNotif = v),
          ),
          _SwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Notifications push',
            subtitle: 'Alertes en temps rel sur mobile',
            value: _pushNotif,
            color: AppColors.mauve,
            onChanged: (v) => setState(() => _pushNotif = v),
          ),
          const SizedBox(height: 24),

          const _SectionLabel('Actions'),
          _ActionTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Vider le cache',
            subtitle: 'Libre l\'espace temporaire',
            onTap: () => SnackbarHelper.success(context, 'Cache vid'),
          ),
          _ActionTile(
            icon: Icons.backup_outlined,
            title: 'Sauvegarder les donnes',
            subtitle: 'Cre une sauvegarde manuelle',
            onTap: () =>
                SnackbarHelper.comingSoon(context),
          ),
          const SizedBox(height: 24),

          const _SectionLabel('? propos'),
          const _InfoTile(
            icon: Icons.school_outlined,
            title: 'Application',
            value: AppStrings.appName,
          ),
          const _InfoTile(
            icon: Icons.info_outline,
            title: 'Version',
            value: AppStrings.version,
          ),
          const _InfoTile(
            icon: Icons.business_outlined,
            title: '?diteur',
            value: 'ChefUnitPlus SARL',
          ),
          const _InfoTile(
            icon: Icons.cloud_outlined,
            title: 'Backend',
            value: 'api.chefunitplus.com',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: color,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.mauveSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.mauve, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Icon(icon, color: AppColors.mauve, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}