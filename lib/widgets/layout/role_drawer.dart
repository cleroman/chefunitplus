// =============================================================
// ChefUnitPlus - RoleDrawer (avec menu admin etendu)
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/role_constants.dart';
import '../../core/routes/app_routes.dart';

class RoleDrawer extends StatelessWidget {
  const RoleDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    if (user == null) return const Drawer();

    return Drawer(
      child: Column(
        children: [
          // ---------------- HEADER ----------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  user.role.color,
                  user.role.color.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: user.role.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(user.role.icon,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        user.role.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---------------- MENU ----------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _menuFor(context, user.role),
            ),
          ),

          // ---------------- FOOTER ----------------
          const Divider(height: 1, color: AppColors.divider),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text(
              'Deconnexion',
              style: TextStyle(
                  color: AppColors.danger, fontWeight: FontWeight.w600),
            ),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _menuFor(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.apprenant:
        return [
          _item(context, Icons.home_outlined, 'Accueil',
              AppRoutes.learnerHome),
          _item(context, Icons.explore_outlined, 'Catalogue',
              AppRoutes.learnerCatalog),
          _item(context, Icons.assignment_turned_in_outlined,
              'Mes inscriptions', AppRoutes.learnerMyEnrollments),
          _item(context, Icons.workspace_premium_outlined,
              'Mes certificats', AppRoutes.learnerCertificates),
          const Divider(indent: 16, endIndent: 16),
          _item(context, Icons.person_outline, 'Profil',
              AppRoutes.profile),
        ];

      case UserRole.formateur:
        return [
          _item(context, Icons.home_outlined, 'Accueil',
              AppRoutes.trainerHome),
          _item(context, Icons.library_books_outlined, 'Mes modules',
              AppRoutes.trainerModules),
          _item(context, Icons.add_box_outlined, 'Creer un module',
              AppRoutes.trainerModuleEditor),
          _item(context, Icons.people_outline, 'Etudiants',
              AppRoutes.trainerStudents),
          const Divider(indent: 16, endIndent: 16),
          _item(context, Icons.person_outline, 'Profil',
              AppRoutes.profile),
        ];

      case UserRole.directeur:
        return [
          _item(context, Icons.home_outlined, 'Accueil',
              AppRoutes.directorHome),
          _item(context, Icons.add_box_outlined, 'Creer formation',
              AppRoutes.directorFormationEditor),
          _item(context, Icons.assignment_ind_outlined,
              'Affecter formateur', AppRoutes.directorModuleAssign),
          _item(context, Icons.check_circle_outline,
              'Valider inscriptions', AppRoutes.directorEnrollments),
          _item(context, Icons.group_outlined, 'Formateurs',
              AppRoutes.directorTrainers),
          _item(context, Icons.analytics_outlined, 'Statistiques',
              AppRoutes.directorStats),
          const Divider(indent: 16, endIndent: 16),
          _item(context, Icons.person_outline, 'Profil',
              AppRoutes.profile),
        ];

      case UserRole.admin:
        return [
          _section('GESTION'),
          _item(context, Icons.dashboard_outlined, 'Dashboard',
              AppRoutes.adminHome),
          _item(context, Icons.people_outline, 'Utilisateurs',
              AppRoutes.adminUsers),
          _item(context, Icons.upgrade_outlined, 'Promouvoir',
              AppRoutes.adminPromote),

          _section('SCOUT'),
          _item(context, Icons.groups_outlined, 'Groupes Scout',
              AppRoutes.adminScoutGroups),
          _item(context, Icons.report_problem_outlined, 'Plaintes',
              AppRoutes.adminComplaints),
          _item(context, Icons.key_outlined, 'Mots de passe',
              AppRoutes.adminPasswordRequests),

          _section('SYSTEME'),
          _item(context, Icons.bar_chart_outlined, 'Statistiques',
              AppRoutes.adminStats),
          _item(context, Icons.receipt_long_outlined, 'Paiements',
              AppRoutes.adminPayments),
          _item(context, Icons.settings_outlined, 'Parametres',
              AppRoutes.adminSettings),

          const Divider(indent: 16, endIndent: 16),
          _item(context, Icons.person_outline, 'Profil',
              AppRoutes.profile),
        ];
    }
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.mauve),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      onTap: () {
        Navigator.pop(context);
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

      Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous vraiment vous deconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Se deconnecter'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final auth = context.read<AuthController>();
    await auth.logout();

    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/auth/login',
      (route) => false,
    );
  }
}