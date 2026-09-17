import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../controllers/locale_controller.dart';
import '../../controllers/theme_controller.dart';
import '../shared/change_password_screen.dart';
import '../shared/user_badge_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnrollmentController>().loadMine(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final enrollCtrl = context.watch<EnrollmentController>();

    final activeCount = enrollCtrl.approved.length;
    final pendingCount = enrollCtrl.awaiting.length;
    final totalCount = enrollCtrl.mine.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<EnrollmentController>().loadMine(refresh: true),
        child: ListView(
          children: [
            // HEADER PROFIL
            _buildHeader(user),

            // STATS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _statCard('$totalCount', 'Formations', Icons.school,
                      AppColors.mauve),
                  const SizedBox(width: 10),
                  _statCard('$activeCount', 'Actives', Icons.play_circle,
                      AppColors.success),
                  const SizedBox(width: 10),
                  _statCard('$pendingCount', 'En attente',
                      Icons.hourglass_empty, AppColors.warning),
                ],
              ),
            ),

            // COMPTE
            _section('Compte'),
            _item(
              icon: Icons.person_outline,
              label: 'Modifier mes informations',
              onTap: () => _goTo(AppRoutes.editProfile),
            ),
            _item(
              icon: Icons.qr_code_2,
              label: 'Mon badge',
              onTap: () => _goToBadge(),
            ),
            _item(
              icon: Icons.lock_outline,
              label: 'Changer mon mot de passe',
              onTap: () => _goToChangePassword(),
            ),
            _item(
              icon: Icons.phone_outlined,
              label: 'Verifier mon telephone',
              onTap: () => _notImplemented(),
            ),

            const SizedBox(height: 8),

            // PREFERENCES
            _section('Preferences'),
            _item(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () => _notImplemented(),
            ),
            _languageToggle(),
            _themeToggle(),

            const SizedBox(height: 8),

            // A PROPOS
            _section('A propos'),
            _item(
              icon: Icons.info_outline,
              label: 'Version',
              trailingText: '1.0.0',
              onTap: () {},
            ),
            _item(
              icon: Icons.help_outline,
              label: 'Aide & support',
              onTap: () => _notImplemented(),
            ),

            const SizedBox(height: 24),

            // LOGOUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(),
                  icon: const Icon(Icons.logout, color: AppColors.danger),
                  label: const Text(
                    'Se deconnecter',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.mauve.withValues(alpha: 0.15),
            child: Text(
              user?.initials ?? '?',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.mauveDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Utilisateur',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mauve.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.role?.label ?? 'Apprenant',
              style: const TextStyle(
                color: AppColors.mauveDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STAT CARD
  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ITEM MENU
  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? trailingText,
  }) {
    return Material(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.mauve),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  // ACTIONS
  void _goTo(String route) {
    Navigator.pushNamed(context, route);
  }

  void _goToBadge() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserBadgeScreen()),
    );
  }

  void _goToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
  }

  void _notImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalite bientot disponible'),
        backgroundColor: AppColors.kaki,
      ),
    );
  }

  Widget _themeToggle() {
    final themeCtrl = context.watch<ThemeController>();
    return Material(
      color: Colors.white,
      child: SwitchListTile(
        secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.mauve),
        title: const Text(
          'Mode sombre',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        value: themeCtrl.isDark,
        activeThumbColor: AppColors.mauve,
        onChanged: (v) => themeCtrl.setDark(v),
      ),
    );
  }

  Widget _languageToggle() {
    final localeCtrl = context.watch<LocaleController>();
    return Material(
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.language, color: AppColors.mauve),
        title: const Text(
          'Langue',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'fr', label: Text('FR')),
            ButtonSegment(value: 'en', label: Text('EN')),
          ],
          selected: {localeCtrl.code},
          onSelectionChanged: (s) => localeCtrl.setLanguage(s.first),
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous vraiment vous deconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Se deconnecter'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    context.read<AuthController>().logout();
  }
}