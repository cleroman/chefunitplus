import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
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
import '../shared/conversations_screen.dart';

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
        onTap: () => _navigate(const ConversationsScreen(), AppRoutes.directorMessages),
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _statsRow(formations.length, published, drafts, pendingModules),
            const SizedBox(height: 24),
            if (pendingModules > 0 || pendingEnroll > 0) ...[
              if (pendingModules > 0)
                _banner(Icons.rule, Colors.orange,
                    '$pendingModules module(s) en attente de validation',
                    () => _navigate(const DirectorModuleValidationScreen(), AppRoutes.directorModulesValidation)),
              if (pendingModules > 0 && pendingEnroll > 0) const SizedBox(height: 10),
              if (pendingEnroll > 0)
                _banner(Icons.assignment_turned_in, Colors.green,
                    '$pendingEnroll inscription(s) en attente',
                    () => _navigate(const EnrollmentsValidationScreen(), AppRoutes.directorEnrollments)),
              const SizedBox(height: 24),
            ],
            _sectionTitle('Actions rapides'),
            const SizedBox(height: 12),
            _actionsGrid(pendingModules, pendingEnroll),
            const SizedBox(height: 24),
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

  Widget _sectionTitle(String t) => Row(
        children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(color: AppColors.mauve, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      );

  Widget _statsRow(int total, int pub, int draft, int pending) {
    return Row(children: [
      _stat('$total', 'Formations', Icons.school, Colors.blue),
      const SizedBox(width: 12),
      _stat('$pub', 'Publiees', Icons.check_circle, Colors.green),
      const SizedBox(width: 12),
      _stat('$draft', 'Brouillons', Icons.edit, Colors.orange),
      const SizedBox(width: 12),
      _stat('$pending', 'A valider', Icons.rule, Colors.red),
    ]);
  }

  Widget _stat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _banner(IconData icon, Color color, String text, VoidCallback onTap) {
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
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color))),
          Icon(Icons.arrow_forward_ios, size: 13, color: color),
        ]),
      ),
    );
  }

  Widget _actionsGrid(int modules, int enroll) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _card(Icons.school_outlined, 'Formations', 'Gerer le catalogue', Colors.blue, 0,
            () => _navigate(const DirectorFormationsListScreen(), AppRoutes.directorFormations)),
        _card(Icons.rule_outlined, 'Modules', 'Valider propositions', Colors.orange, modules,
            () => _navigate(const DirectorModuleValidationScreen(), AppRoutes.directorModulesValidation)),
        _card(Icons.assignment_turned_in_outlined, 'Inscriptions', 'Valider paiements', Colors.green, enroll,
            () => _navigate(const EnrollmentsValidationScreen(), AppRoutes.directorEnrollments)),
        _card(Icons.analytics_outlined, 'Statistiques', 'Voir les analyses', Colors.indigo, 0,
            () => _navigate(const FormationStatsScreen(), AppRoutes.directorStats)),
      ],
    );
  }

  Widget _card(IconData icon, String title, String subtitle, Color color, int badge, VoidCallback onTap) {
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
              if (badge > 0)
                Positioned(
                  top: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(10)),
                    child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formationCard(dynamic f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.mauve.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.school, color: AppColors.mauve),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.title ?? 'Formation', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: f.isPublished ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  f.isPublished ? 'Publiee' : 'Brouillon',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: f.isPublished ? Colors.green : Colors.orange),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(Icons.school_outlined, size: 48, color: AppColors.mauve.withValues(alpha: 0.5)),
        const SizedBox(height: 12),
        const Text('Aucune formation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Creez votre premiere formation', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
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