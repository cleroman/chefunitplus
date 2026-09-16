import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/formation_controller.dart';
import '../../controllers/module_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../models/formation.dart';
import '../../widgets/layout/director_drawer.dart';
import 'formation_editor_screen.dart';
import 'director_module_validation_screen.dart';
import 'enrollments_validation_screen.dart';
import 'trainers_management_screen.dart';
import 'module_assign_screen.dart';
import 'formation_stats_screen.dart';

class DirectorDashboard extends StatefulWidget {
  const DirectorDashboard({super.key});

  @override
  State<DirectorDashboard> createState() => _DirectorDashboardState();
}

class _DirectorDashboardState extends State<DirectorDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
    });
  }

  Future<void> _loadAll() async {
    final formCtrl = context.read<FormationController>();
    final moduleCtrl = context.read<ModuleController>();
    final enrollCtrl = context.read<EnrollmentController>();

    await Future.wait([
      formCtrl.load(all: true, refresh: true),
      moduleCtrl.loadPending(refresh: true),
      enrollCtrl.loadPending(refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final formCtrl = context.watch<FormationController>();
    final moduleCtrl = context.watch<ModuleController>();
    final enrollCtrl = context.watch<EnrollmentController>();

    final formations = formCtrl.formations;
    final publishedCount = formations.where((f) => f.isPublished).length;
    final draftCount = formations.length - publishedCount;
    final pendingModules = moduleCtrl.pending.length;
    final pendingEnrollments = enrollCtrl.pending.length;

    return Scaffold(
      drawer: const DirectorDrawer(),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: CustomScrollView(
          slivers: [
            _buildHeader(user?.fullName ?? 'Directeur'),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatsRow(
                    formations.length,
                    publishedCount,
                    draftCount,
                    pendingModules,
                  ),
                  const SizedBox(height: 20),
                  if (pendingModules > 0 || pendingEnrollments > 0)
                    _buildPendingBanners(pendingModules, pendingEnrollments),
                  if (pendingModules > 0 || pendingEnrollments > 0)
                    const SizedBox(height: 20),
                  const _SectionTitle(title: 'Actions rapides'),
                  const SizedBox(height: 12),
                  _buildActionsGrid(pendingModules, pendingEnrollments),
                  const SizedBox(height: 20),
                  const _SectionTitle(title: 'Formations recentes'),
                  const SizedBox(height: 12),
                  if (formCtrl.isLoading && formations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (formations.isEmpty)
                    _buildEmptyFormations()
                  else
                    ...formations
                        .take(3)
                        .map((f) => _buildFormationCard(f)),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER GRADIENT
  // ============================================================
  Widget _buildHeader(String userName) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mauve, AppColors.kaki],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Espace Directeur',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _confirmLogout(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATS ROW
  // ============================================================
  Widget _buildStatsRow(int total, int published, int draft, int pendingMod) {
    return Row(
      children: [
        _statCard('$total', 'Formations', Icons.school, AppColors.mauve),
        const SizedBox(width: 10),
        _statCard('$published', 'Publiees', Icons.check_circle, AppColors.success),
        const SizedBox(width: 10),
        _statCard('$draft', 'Brouillons', Icons.edit, AppColors.warning),
        const SizedBox(width: 10),
        _statCard('$pendingMod', 'A valider', Icons.rule, AppColors.danger),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
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

  // ============================================================
  // BANNIERES PENDING
  // ============================================================
  Widget _buildPendingBanners(int pendingModules, int pendingEnrollments) {
    return Column(
      children: [
        if (pendingModules > 0)
          _pendingBanner(
            count: pendingModules,
            label: 'module(s) propose(s) par les formateurs',
            icon: Icons.rule,
            color: AppColors.warning,
            onTap: () => _push(const DirectorModuleValidationScreen()),
          ),
        if (pendingModules > 0 && pendingEnrollments > 0)
          const SizedBox(height: 10),
        if (pendingEnrollments > 0)
          _pendingBanner(
            count: pendingEnrollments,
            label: 'inscription(s) en attente de validation',
            icon: Icons.assignment_turned_in,
            color: AppColors.kaki,
            onTap: () => _push(const EnrollmentsValidationScreen()),
          ),
      ],
    );
  }

  Widget _pendingBanner({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count $label',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Touchez pour valider',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GRILLE ACTIONS
  // ============================================================
  Widget _buildActionsGrid(int pendingModules, int pendingEnrollments) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _actionCard(
          icon: Icons.school_outlined,
          title: 'Formations',
          subtitle: 'Gerer le catalogue',
          color: AppColors.mauve,
          onTap: () => _push(const FormationEditorScreen()),
        ),
        _actionCard(
          icon: Icons.rule_outlined,
          title: 'Modules',
          subtitle: 'Valider les propositions',
          color: AppColors.warning,
          badge: pendingModules,
          onTap: () => _push(const DirectorModuleValidationScreen()),
        ),
        _actionCard(
          icon: Icons.assignment_turned_in_outlined,
          title: 'Inscriptions',
          subtitle: 'Valider les paiements',
          color: AppColors.kaki,
          badge: pendingEnrollments,
          onTap: () => _push(const EnrollmentsValidationScreen()),
        ),
        _actionCard(
          icon: Icons.people_outline,
          title: 'Formateurs',
          subtitle: 'Gerer les formateurs',
          color: AppColors.success,
          onTap: () => _push(const TrainersManagementScreen()),
        ),
        _actionCard(
          icon: Icons.assignment_ind_outlined,
          title: 'Assignations',
          subtitle: 'Modules aux formateurs',
          color: AppColors.mauveDark,
          onTap: () => _push(const ModuleAssignScreen()),
        ),
        _actionCard(
          icon: Icons.analytics_outlined,
          title: 'Statistiques',
          subtitle: 'Voir les analyses',
          color: AppColors.kakiDark,
          onTap: () => _push(const FormationStatsScreen()),
        ),
      ],
    );
  }

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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
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

  // ============================================================
  // CARTE FORMATION
  // ============================================================
  Widget _buildFormationCard(Formation f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.mauve.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school, color: AppColors.mauve),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: f.isPublished
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        f.isPublished ? 'Publiee' : 'Brouillon',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: f.isPublished
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${f.totalHours}h',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildEmptyFormations() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mauve.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 40,
              color: AppColors.mauve,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucune formation',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Creez votre premiere formation',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================
  void _push(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) {
      // Recharger quand on revient
      if (mounted) _loadAll();
    });
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous vraiment vous deconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
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

// ============================================================
// WIDGET : Titre de section
// ============================================================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.mauve,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}