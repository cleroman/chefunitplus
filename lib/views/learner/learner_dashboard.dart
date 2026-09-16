import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../controllers/formation_controller.dart';
import '../../models/enrollment.dart';
import '../../models/formation.dart';
import '../../widgets/layout/learner_drawer.dart';
import 'formation_catalog_screen.dart';
import 'my_enrollments_screen.dart';
import 'certificate_screen.dart';
import 'profile_screen.dart';
import 'formation_detail_screen.dart';

class LearnerDashboard extends StatefulWidget {
  const LearnerDashboard({super.key});

  @override
  State<LearnerDashboard> createState() => _LearnerDashboardState();
}

class _LearnerDashboardState extends State<LearnerDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
    });
  }

  Future<void> _loadAll() async {
    final enrollCtrl = context.read<EnrollmentController>();
    final formCtrl = context.read<FormationController>();

    await Future.wait([
      enrollCtrl.loadMine(refresh: true),
      formCtrl.load(refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(onRefresh: _loadAll, onSwitchTab: (i) => setState(() => _currentIndex = i)),
      const FormationCatalogScreen(),
      const MyEnrollmentsScreen(),
      const CertificateScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const LearnerDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.mauveSoft,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.mauve),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.mauve),
            label: 'Catalogue',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: AppColors.mauve),
            label: 'Formations',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium, color: AppColors.mauve),
            label: 'Certificats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.mauve),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ONGLET ACCUEIL
// ==================================================================
class _HomeTab extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final void Function(int) onSwitchTab;
  const _HomeTab({
    required this.onRefresh,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final enrollCtrl = context.watch<EnrollmentController>();
    final formCtrl = context.watch<FormationController>();

    final myEnrollments = enrollCtrl.mine;
    final activeEnrollments = myEnrollments.where((e) => e.isApproved).toList();
    final pendingEnrollments =
        myEnrollments.where((e) => e.isPending).toList();

    // Formation en cours (premiere active)
    final currentEnrollment = activeEnrollments.isNotEmpty
        ? activeEnrollments.first
        : null;

    // Formations recommandees (max 3, non deja inscrites)
    final enrolledFormationIds =
        myEnrollments.map((e) => e.formationId).toSet();
    final recommended = formCtrl.formations
        .where((f) => !enrolledFormationIds.contains(f.id))
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const LearnerDrawer(),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          slivers: [
            _buildHeader(user?.fullName ?? 'Apprenant'),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats personnelles
                  _buildStatsRow(
                    activeEnrollments.length,
                    pendingEnrollments.length,
                    enrollCtrl.approved.length, // certificats = approved
                  ),
                  const SizedBox(height: 20),

                  // Banniere "Nouvelle formation validee"
                  if (activeEnrollments.isNotEmpty) ...[
                    _buildApprovedBanner(activeEnrollments.length),
                    const SizedBox(height: 20),
                  ],

                  // Section "Continuer l'apprentissage"
                  if (currentEnrollment != null) ...[
                    const _SectionTitle(title: 'Continuer'),
                    const SizedBox(height: 12),
                    _buildContinueCard(context, currentEnrollment),
                    const SizedBox(height: 20),
                  ],

                  // Actions rapides
                  const _SectionTitle(title: 'Acces rapides'),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),

                  // Recommandations
                  if (recommended.isNotEmpty) ...[
                    const _SectionTitle(title: 'Recommandees pour vous'),
                    const SizedBox(height: 12),
                    ...recommended.map((f) => _buildRecommendationCard(context, f)),
                    const SizedBox(height: 20),
                  ],

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
  // HEADER
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
            const Text(
              'Bonjour !',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pret a apprendre aujourd\'hui ?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATS ROW
  // ============================================================
  Widget _buildStatsRow(int active, int pending, int certificates) {
    return Row(
      children: [
        _statCard('$active', 'Actives', Icons.play_circle_outline, AppColors.success),
        const SizedBox(width: 12),
        _statCard('$pending', 'En attente', Icons.hourglass_empty, AppColors.warning),
        const SizedBox(width: 12),
        _statCard('$certificates', 'Certificats', Icons.workspace_premium_outlined, AppColors.mauve),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
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
  // BANNIERE APPROVED
  // ============================================================
  Widget _buildApprovedBanner(int count) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.15),
            AppColors.success.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count formation(s) accessible(s)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Vous pouvez commencer a apprendre !',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTE "CONTINUER"
  // ============================================================
  Widget _buildContinueCard(BuildContext context, Enrollment e) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormationDetailScreen(formationId: e.formationId),
          ),
        ),
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.mauve, AppColors.kaki],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Center(
                  child: Icon(Icons.school, size: 50, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.formationTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Validee',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Commencer',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mauve,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.mauve,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIONS RAPIDES
  // ============================================================
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _quickAction(
          context,
          icon: Icons.explore_outlined,
          label: 'Catalogue',
          color: AppColors.mauve,
          tabIndex: 1,
        ),
        const SizedBox(width: 12),
        _quickAction(
          context,
          icon: Icons.assignment_outlined,
          label: 'Mes formations',
          color: AppColors.kaki,
          tabIndex: 2,
        ),
        const SizedBox(width: 12),
        _quickAction(
          context,
          icon: Icons.workspace_premium_outlined,
          label: 'Certificats',
          color: AppColors.success,
          tabIndex: 3,
        ),
      ],
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required int tabIndex,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSwitchTab(tabIndex),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARTE RECOMMANDATION
  // ============================================================
  Widget _buildRecommendationCard(BuildContext context, Formation f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormationDetailScreen(formationId: f.id),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.mauve, AppColors.kaki],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 26,
                  ),
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
                          Text(
                            f.type.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            f.priceLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mauve,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
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