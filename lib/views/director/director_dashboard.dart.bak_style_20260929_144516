// ============================================================
// ChefUnitPlus - Dashboard Directeur (VERSION PRO)
// ------------------------------------------------------------
// - Garde TOUS les services/controleurs/routes existants
// - Theme Admin (mauve) applique via DirectorThemeAdapter
// - Header gradient, KPIs modernes, actions rapides, timeline
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/director_theme_adapter.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/formation_controller.dart';
import '../../controllers/module_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../widgets/layout/pro_layout.dart';
import 'director_formations_list_screen.dart';
import 'director_module_validation_screen.dart';
import 'enrollments_validation_screen.dart';
import 'trainers_management_screen.dart';
import 'module_assign_screen.dart';
import 'formation_stats_screen.dart';
import 'formation_editor_screen.dart';
import '../shared/messages_screen.dart';

class DirectorDashboard extends StatefulWidget {
  const DirectorDashboard({super.key});

  @override
  State<DirectorDashboard> createState() => _DirectorDashboardState();
}

class _DirectorDashboardState extends State<DirectorDashboard> {
  String _currentRoute = AppRoutes.directorHome;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    await Future.wait([
      context.read<FormationController>().load(all: true, refresh: true),
      context.read<ModuleController>().loadPending(refresh: true),
      context.read<EnrollmentController>().loadMine(refresh: true),
    ]);
  }

  void _navigate(Widget screen, String route) {
    setState(() => _currentRoute = route);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) {
      if (mounted) {
        setState(() => _currentRoute = AppRoutes.directorHome);
        _loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final formCtrl = context.watch<FormationController>();
    final moduleCtrl = context.watch<ModuleController>();
    final enrollCtrl = context.watch<EnrollmentController>();

    final formations = formCtrl.formations;
    final published = formations.where((f) => f.isPublished).length;
    final drafts = formations.length - published;
    final pendingModules = moduleCtrl.pending.length;
    final pendingEnroll = enrollCtrl.pending.length;

    final items = [
      const ProMenuItem(
        icon: Icons.dashboard_outlined,
        label: 'Tableau de bord',
        route: AppRoutes.directorHome,
        color: AppColors.mauve,
      ),
      ProMenuItem(
        icon: Icons.school_outlined,
        label: 'Formations',
        route: AppRoutes.directorFormations,
        color: Colors.blue,
        badge: formations.length,
        onTap: () => _navigate(const DirectorFormationsListScreen(), AppRoutes.directorFormations),
      ),
      ProMenuItem(
        icon: Icons.rule_outlined,
        label: 'Modules a valider',
        route: AppRoutes.directorModulesValidation,
        color: Colors.orange,
        badge: pendingModules,
        onTap: () => _navigate(const DirectorModuleValidationScreen(), AppRoutes.directorModulesValidation),
      ),
      ProMenuItem(
        icon: Icons.assignment_turned_in_outlined,
        label: 'Inscriptions',
        route: AppRoutes.directorEnrollments,
        color: Colors.green,
        badge: pendingEnroll,
        onTap: () => _navigate(const EnrollmentsValidationScreen(), AppRoutes.directorEnrollments),
      ),
      ProMenuItem(
        icon: Icons.people_outline,
        label: 'Formateurs',
        route: AppRoutes.directorTrainers,
        color: Colors.teal,
        onTap: () => _navigate(const TrainersManagementScreen(), AppRoutes.directorTrainers),
      ),
      ProMenuItem(
        icon: Icons.assignment_ind_outlined,
        label: 'Assignations',
        route: AppRoutes.directorModuleAssign,
        color: Colors.purple,
        onTap: () => _navigate(const ModuleAssignScreen(), AppRoutes.directorModuleAssign),
      ),
      ProMenuItem(
        icon: Icons.analytics_outlined,
        label: 'Statistiques',
        route: AppRoutes.directorStats,
        color: Colors.indigo,
        onTap: () => _navigate(const FormationStatsScreen(), AppRoutes.directorStats),
      ),
      ProMenuItem(
        icon: Icons.chat_bubble_outline,
        label: 'Messages',
        route: AppRoutes.directorMessages,
        color: Colors.cyan,
        onTap: () => _navigate(const MessagesScreen(), AppRoutes.directorMessages),
      ),
    ];

    return ProLayout(
      title: 'Espace Directeur',
      subtitle: user?.fullName ?? 'Directeur',
      currentRoute: _currentRoute,
      items: items,
      onLogout: _logout,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: AppColors.mauve),
          tooltip: 'Nouvelle formation',
          onPressed: () => _navigate(const FormationEditorScreen(), AppRoutes.directorFormations),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: DirectorThemeAdapter.primary,
        child: ListView(
          padding: const EdgeInsets.all(DirectorThemeAdapter.gapMd),
          children: [
            _buildHeader(user?.fullName ?? 'Directeur'),
            const SizedBox(height: DirectorThemeAdapter.gapLg),

            _buildStatsRow(
              formations.length,
              published,
              drafts,
              pendingModules,
            ),
            const SizedBox(height: DirectorThemeAdapter.gapLg),

            if (pendingModules > 0 || pendingEnroll > 0) ...[
              if (pendingModules > 0)
                _buildBanner(
                  icon: Icons.rule,
                  color: DirectorThemeAdapter.warning,
                  text: '$pendingModules module(s) en attente de validation',
                  onTap: () => _navigate(const DirectorModuleValidationScreen(), AppRoutes.directorModulesValidation),
                ),
              if (pendingModules > 0 && pendingEnroll > 0)
                const SizedBox(height: DirectorThemeAdapter.gapSm),
              if (pendingEnroll > 0)
                _buildBanner(
                  icon: Icons.assignment_turned_in,
                  color: DirectorThemeAdapter.success,
                  text: '$pendingEnroll inscription(s) en attente',
                  onTap: () => _navigate(const EnrollmentsValidationScreen(), AppRoutes.directorEnrollments),
                ),
              const SizedBox(height: DirectorThemeAdapter.gapLg),
            ],

            _buildSectionTitle('Actions rapides'),
            const SizedBox(height: DirectorThemeAdapter.gapMd),
            _buildActionsGrid(pendingModules, pendingEnroll),

            const SizedBox(height: DirectorThemeAdapter.gapLg),

            _buildSectionTitle('Formations recentes'),
            const SizedBox(height: DirectorThemeAdapter.gapMd),
            if (formations.isEmpty)
              _buildEmptyCard()
            else
              ...formations.take(3).map(_buildFormationCard),

            const SizedBox(height: DirectorThemeAdapter.gapXl),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Header gradient
  // ------------------------------------------------------------
  Widget _buildHeader(String name) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Bonjour'
        : hour < 18
            ? 'Bon apres-midi'
            : 'Bonsoir';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DirectorThemeAdapter.gapLg),
      decoration: DirectorThemeAdapter.headerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: DirectorThemeAdapter.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DirectorThemeAdapter.gapMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DirectorThemeAdapter.gapMd,
              vertical: DirectorThemeAdapter.gapSm,
            ),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 15),
                const SizedBox(width: 8),
                Text(
                  '${now.day.toString().padLeft(2, "0")}/${now.month.toString().padLeft(2, "0")}/${now.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Section title
  // ------------------------------------------------------------
  Widget _buildSectionTitle(String t) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: DirectorThemeAdapter.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          t,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: DirectorThemeAdapter.textPrimary,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // Stats row (KPIs)
  // ------------------------------------------------------------
  Widget _buildStatsRow(int total, int pub, int draft, int pending) {
    return Row(
      children: [
        _buildStat('$total', 'Formations', Icons.school, DirectorThemeAdapter.primary),
        const SizedBox(width: 12),
        _buildStat('$pub', 'Publiees', Icons.check_circle, DirectorThemeAdapter.success),
        const SizedBox(width: 12),
        _buildStat('$draft', 'Brouillons', Icons.edit, DirectorThemeAdapter.warning),
        const SizedBox(width: 12),
        _buildStat('$pending', 'A valider', Icons.rule, DirectorThemeAdapter.danger),
      ],
    );
  }

  Widget _buildStat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: DirectorThemeAdapter.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusSm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: DirectorThemeAdapter.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: DirectorThemeAdapter.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Banner alerte
  // ------------------------------------------------------------
  Widget _buildBanner({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 13, color: color),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Actions grid
  // ------------------------------------------------------------
  Widget _buildActionsGrid(int modules, int enroll) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildActionCard(Icons.school_outlined, 'Formations', 'Gerer le catalogue',
            DirectorThemeAdapter.primary, 0,
            () => _navigate(const DirectorFormationsListScreen(), AppRoutes.directorFormations)),
        _buildActionCard(Icons.rule_outlined, 'Modules', 'Valider propositions',
            DirectorThemeAdapter.warning, modules,
            () => _navigate(const DirectorModuleValidationScreen(), AppRoutes.directorModulesValidation)),
        _buildActionCard(Icons.assignment_turned_in_outlined, 'Inscriptions', 'Valider paiements',
            DirectorThemeAdapter.success, enroll,
            () => _navigate(const EnrollmentsValidationScreen(), AppRoutes.directorEnrollments)),
        _buildActionCard(Icons.analytics_outlined, 'Statistiques', 'Voir les analyses',
            DirectorThemeAdapter.secondary, 0,
            () => _navigate(const FormationStatsScreen(), AppRoutes.directorStats)),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, Color color,
      int badge, VoidCallback onTap) {
    return Material(
      color: DirectorThemeAdapter.surface,
      borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusMd),
            boxShadow: [
              BoxShadow(
                color: DirectorThemeAdapter.primary.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusSm),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DirectorThemeAdapter.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: DirectorThemeAdapter.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (badge > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DirectorThemeAdapter.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Formation card
  // ------------------------------------------------------------
  Widget _buildFormationCard(dynamic f) {
    final isPublished = f.isPublished == true;
    final color = isPublished ? DirectorThemeAdapter.success : DirectorThemeAdapter.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: DirectorThemeAdapter.cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DirectorThemeAdapter.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusSm),
            ),
            child: const Icon(Icons.school, color: DirectorThemeAdapter.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.title ?? 'Formation',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DirectorThemeAdapter.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPublished ? 'Publiee' : 'Brouillon',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: DirectorThemeAdapter.textMuted),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Empty card
  // ------------------------------------------------------------
  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: DirectorThemeAdapter.cardDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 48,
            color: DirectorThemeAdapter.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucune formation',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DirectorThemeAdapter.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Creez votre premiere formation',
            style: TextStyle(
              fontSize: 12,
              color: DirectorThemeAdapter.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Logout
  // ------------------------------------------------------------
  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous vraiment vous deconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthController>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: DirectorThemeAdapter.danger),
            child: const Text('Se deconnecter'),
          ),
        ],
      ),
    );
  }
}
