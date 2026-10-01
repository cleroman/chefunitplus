import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/formation_controller.dart';
import '../../../controllers/module_controller.dart';
import '../../../controllers/enrollment_controller.dart';
import '../../../widgets/layout/pro_layout.dart';
import 'director_formations_list_screen.dart';
import 'director_module_validation_screen.dart';
import 'enrollments_validation_screen.dart';
import 'trainers_management_screen.dart';
import 'module_assign_screen.dart';
import 'formation_stats_screen.dart';
import 'formation_editor_screen.dart';
import '../../shared/messages_screen.dart';

class MobileDirectorDashboard extends StatefulWidget {
  const MobileDirectorDashboard({super.key});

  @override
  State<MobileDirectorDashboard> createState() => _DirectorDashboardState();
}

class _DirectorDashboardState extends State<MobileDirectorDashboard> {
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) {
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
        onTap: () => _navigate(
            const DirectorFormationsListScreen(), AppRoutes.directorFormations),
      ),
      ProMenuItem(
        icon: Icons.rule_outlined,
        label: 'Modules a valider',
        route: AppRoutes.directorModulesValidation,
        color: Colors.orange,
        badge: pendingModules,
        onTap: () => _navigate(const DirectorModuleValidationScreen(),
            AppRoutes.directorModulesValidation),
      ),
      ProMenuItem(
        icon: Icons.assignment_turned_in_outlined,
        label: 'Inscriptions',
        route: AppRoutes.directorEnrollments,
        color: Colors.green,
        badge: pendingEnroll,
        onTap: () => _navigate(const EnrollmentsValidationScreen(),
            AppRoutes.directorEnrollments),
      ),
      ProMenuItem(
        icon: Icons.people_outline,
        label: 'Formateurs',
        route: AppRoutes.directorTrainers,
        color: Colors.teal,
        onTap: () => _navigate(
            const TrainersManagementScreen(), AppRoutes.directorTrainers),
      ),
      ProMenuItem(
        icon: Icons.assignment_ind_outlined,
        label: 'Assignations',
        route: AppRoutes.directorModuleAssign,
        color: Colors.purple,
        onTap: () =>
            _navigate(const ModuleAssignScreen(), AppRoutes.directorModuleAssign),
      ),
      ProMenuItem(
        icon: Icons.analytics_outlined,
        label: 'Statistiques',
        route: AppRoutes.directorStats,
        color: Colors.indigo,
        onTap: () =>
            _navigate(const FormationStatsScreen(), AppRoutes.directorStats),
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
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ============================================================
            // STATS (4 cartes - style admin)
            // ============================================================
            _buildStatsRow(
              formations.length,
              published,
              pendingModules,
              pendingEnroll,
            ),
            const SizedBox(height: 24),

            // ============================================================
            // BANNIERES D'ALERTE
            // ============================================================
            if (pendingModules > 0 || pendingEnroll > 0)
              _buildPendingBanners(pendingModules, pendingEnroll),
            if (pendingModules > 0 || pendingEnroll > 0)
              const SizedBox(height: 24),

            // ============================================================
            // SECTION 1 : GESTION RAPIDE (4 cartes)
            // ============================================================
            _sectionTitle('Gestion rapide'),
            const SizedBox(height: 12),
            _buildManagementGrid(pendingModules, pendingEnroll),
            const SizedBox(height: 24),

            // ============================================================
            // SECTION 2 : PLATEFORME (4 cartes)
            // ============================================================
            _sectionTitle('Plateforme'),
            const SizedBox(height: 12),
            _buildPlatformGrid(),
            const SizedBox(height: 24),

            // ============================================================
            // FORMATIONS RECENTES
            // ============================================================
            _sectionTitle('Formations recentes'),
            const SizedBox(height: 12),
            if (formations.isEmpty)
              _emptyCard()
            else
              ...formations.take(3).map(_formationCard),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================
  Widget _sectionTitle(String t) => Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.mauve,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(t,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
        ],
      );

  // ============================================================
  // STATS ROW (4 cartes)
  // ============================================================
  Widget _buildStatsRow(int total, int pub, int modules, int enroll) {
    return Row(
      children: [
        _statCard('$total', 'Formations', Icons.school, Colors.blue),
        const SizedBox(width: 12),
        _statCard('$pub', 'Publiees', Icons.check_circle, Colors.green),
        const SizedBox(width: 12),
        _statCard('$modules', 'A valider', Icons.rule, Colors.orange),
        const SizedBox(width: 12),
        _statCard(
            '$enroll', 'Inscriptions', Icons.assignment_turned_in, Colors.purple),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BANNIERES D'ALERTE
  // ============================================================
  Widget _buildPendingBanners(int modules, int enroll) {
    return Column(
      children: [
        if (modules > 0)
          _banner(
            icon: Icons.rule,
            color: Colors.orange,
            text: '$modules module(s) en attente de validation',
            onTap: () => _navigate(const DirectorModuleValidationScreen(),
                AppRoutes.directorModulesValidation),
          ),
        if (modules > 0 && enroll > 0) const SizedBox(height: 10),
        if (enroll > 0)
          _banner(
            icon: Icons.assignment_turned_in,
            color: Colors.green,
            text: '$enroll inscription(s) en attente',
            onTap: () => _navigate(const EnrollmentsValidationScreen(),
                AppRoutes.directorEnrollments),
          ),
      ],
    );
  }

  Widget _banner({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  )),
            ),
            Icon(Icons.arrow_forward_ios, size: 13, color: color),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION 1 : GESTION RAPIDE (4 cartes)
  // ============================================================
  Widget _buildManagementGrid(int modules, int enroll) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _actionCard(
          icon: Icons.school_outlined,
          title: 'Formations',
          subtitle: 'Gerer le catalogue',
          color: Colors.blue,
          onTap: () => _navigate(
              const DirectorFormationsListScreen(), AppRoutes.directorFormations),
        ),
        _actionCard(
          icon: Icons.rule_outlined,
          title: 'Modules',
          subtitle: 'Valider propositions',
          color: Colors.orange,
          badge: modules,
          onTap: () => _navigate(const DirectorModuleValidationScreen(),
              AppRoutes.directorModulesValidation),
        ),
        _actionCard(
          icon: Icons.assignment_turned_in_outlined,
          title: 'Inscriptions',
          subtitle: 'Valider paiements',
          color: Colors.green,
          badge: enroll,
          onTap: () => _navigate(
              const EnrollmentsValidationScreen(), AppRoutes.directorEnrollments),
        ),
        _actionCard(
          icon: Icons.people_outline,
          title: 'Formateurs',
          subtitle: 'Gerer equipe',
          color: Colors.teal,
          onTap: () =>
              _navigate(const TrainersManagementScreen(), AppRoutes.directorTrainers),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION 2 : PLATEFORME (4 cartes)
  // ============================================================
  Widget _buildPlatformGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _actionCard(
          icon: Icons.analytics_outlined,
          title: 'Statistiques',
          subtitle: 'Voir les analyses',
          color: Colors.indigo,
          onTap: () =>
              _navigate(const FormationStatsScreen(), AppRoutes.directorStats),
        ),
        _actionCard(
          icon: Icons.assignment_ind_outlined,
          title: 'Assignations',
          subtitle: 'Modules aux formateurs',
          color: Colors.purple,
          onTap: () => _navigate(
              const ModuleAssignScreen(), AppRoutes.directorModuleAssign),
        ),
        _actionCard(
          icon: Icons.chat_bubble_outline,
          title: 'Messages',
          subtitle: 'Communication',
          color: Colors.cyan,
          onTap: () =>
              _navigate(const MessagesScreen(), AppRoutes.directorMessages),
        ),
        _actionCard(
          icon: Icons.add_circle_outline,
          title: 'Nouvelle formation',
          subtitle: 'Creer une formation',
          color: AppColors.mauve,
          onTap: () => _navigate(
              const FormationEditorScreen(), AppRoutes.directorFormations),
        ),
      ],
    );
  }

  // ============================================================
  // ACTION CARD (style admin)
  // ============================================================
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              if (badge > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$badge',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMATION CARD
  // ============================================================
  Widget _formationCard(dynamic f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.mauve.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.school, color: AppColors.mauve),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.title ?? 'Formation',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: f.isPublished
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  f.isPublished ? 'Publiee' : 'Brouillon',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: f.isPublished ? Colors.green : Colors.orange),
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ]),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(Icons.school_outlined,
            size: 48, color: AppColors.mauve.withValues(alpha: 0.5)),
        const SizedBox(height: 12),
        const Text('Aucune formation',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Creez votre premiere formation',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ]),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous vraiment vous deconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthController>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Se deconnecter'),
          ),
        ],
      ),
    );
  }
}