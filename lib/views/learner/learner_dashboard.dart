import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../controllers/formation_controller.dart';
import '../../widgets/layout/pro_layout.dart';
import 'formation_catalog_screen.dart';
import 'my_enrollments_screen.dart';
import 'certificate_screen.dart';
import 'profile_screen.dart';
import 'formation_detail_screen.dart';
import '../shared/conversations_screen.dart';

class LearnerDashboard extends StatefulWidget {
  const LearnerDashboard({super.key});
  @override
  State<LearnerDashboard> createState() => _LearnerDashboardState();
}

class _LearnerDashboardState extends State<LearnerDashboard> {
  String _currentRoute = AppRoutes.learnerHome;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    await Future.wait([
      context.read<EnrollmentController>().loadMine(refresh: true),
      context.read<FormationController>().load(refresh: true),
    ]);
  }

  void _navigate(Widget screen, String route) {
    setState(() => _currentRoute = route);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) {
      if (mounted) {
        setState(() => _currentRoute = AppRoutes.learnerHome);
        _loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final enrollCtrl = context.watch<EnrollmentController>();
    final formCtrl = context.watch<FormationController>();

    final myEnrollments = enrollCtrl.mine;
    final active = myEnrollments.where((e) => e.isApproved).length;
    final pending = myEnrollments.where((e) => e.isPending).length;
    final certificates = active;

    final enrolledFormationIds = myEnrollments.map((e) => e.formationId).toSet();
    final recommended = formCtrl.formations
        .where((f) => !enrolledFormationIds.contains(f.id))
        .take(3)
        .toList();

    final items = [
      const ProMenuItem(
        icon: Icons.home_outlined,
        label: 'Accueil',
        route: AppRoutes.learnerHome,
        color: AppColors.mauve,
      ),
      ProMenuItem(
        icon: Icons.explore_outlined,
        label: 'Catalogue',
        route: AppRoutes.learnerCatalog,
        color: Colors.blue,
        onTap: () => _navigate(const FormationCatalogScreen(), AppRoutes.learnerCatalog),
      ),
      ProMenuItem(
        icon: Icons.assignment_outlined,
        label: 'Mes formations',
        route: AppRoutes.learnerMyEnrollments,
        color: Colors.green,
        badge: active,
        onTap: () => _navigate(const MyEnrollmentsScreen(), AppRoutes.learnerMyEnrollments),
      ),
      ProMenuItem(
        icon: Icons.hourglass_empty,
        label: 'En attente',
        route: AppRoutes.learnerMyEnrollments,
        color: Colors.orange,
        badge: pending,
        onTap: () => _navigate(const MyEnrollmentsScreen(), AppRoutes.learnerMyEnrollments),
      ),
      ProMenuItem(
        icon: Icons.workspace_premium_outlined,
        label: 'Mes certificats',
        route: AppRoutes.learnerCertificates,
        color: Colors.amber,
        badge: certificates,
        onTap: () => _navigate(const CertificateScreen(), AppRoutes.learnerCertificates),
      ),
      ProMenuItem(
        icon: Icons.person_outline,
        label: 'Mon profil',
        route: AppRoutes.learnerProfile,
        color: Colors.teal,
        onTap: () => _navigate(const ProfileScreen(), AppRoutes.learnerProfile),
      ),
      ProMenuItem(
        icon: Icons.chat_bubble_outline,
        label: 'Messages',
        route: AppRoutes.learnerMessages,
        color: Colors.cyan,
        onTap: () => _navigate(const ConversationsScreen(), AppRoutes.learnerMessages),
      ),
    ];

    return ProLayout(
      title: 'Mon espace',
      subtitle: user?.fullName ?? 'Apprenant',
      currentRoute: _currentRoute,
      items: items,
      onLogout: _logout,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _welcomeBanner(user?.fullName ?? 'Apprenant'),
            const SizedBox(height: 20),
            _statsRow(active, pending, certificates),
            const SizedBox(height: 24),
            if (active > 0) ...[
              _banner(Icons.check_circle, Colors.green,
                  '$active formation(s) accessible(s) - commencez a apprendre !',
                  () => _navigate(const MyEnrollmentsScreen(), AppRoutes.learnerMyEnrollments)),
              const SizedBox(height: 16),
            ],
            _sectionTitle('Acces rapides'),
            const SizedBox(height: 12),
            _quickActions(),
            const SizedBox(height: 24),
            if (recommended.isNotEmpty) ...[
              _sectionTitle('Recommandees pour vous'),
              const SizedBox(height: 12),
              ...recommended.map(_recommendationCard),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _welcomeBanner(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mauve, AppColors.kaki],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bonjour !',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          const Text('Pret a apprendre aujourd\'hui ?',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Row(
        children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(
              color: AppColors.mauve,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(t, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      );

  Widget _statsRow(int active, int pending, int cert) {
    return Row(children: [
      _stat('$active', 'Actives', Icons.play_circle, Colors.green),
      const SizedBox(width: 12),
      _stat('$pending', 'En attente', Icons.hourglass_empty, Colors.orange),
      const SizedBox(width: 12),
      _stat('$cert', 'Certificats', Icons.workspace_premium, Colors.amber),
    ]);
  }

  Widget _stat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                maxLines: 1, overflow: TextOverflow.ellipsis),
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
          Expanded(child: Text(text,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color))),
          Icon(Icons.arrow_forward_ios, size: 13, color: color),
        ]),
      ),
    );
  }

  Widget _quickActions() {
    return Row(children: [
      _quickCard(Icons.explore_outlined, 'Catalogue', Colors.blue,
          () => _navigate(const FormationCatalogScreen(), AppRoutes.learnerCatalog)),
      const SizedBox(width: 12),
      _quickCard(Icons.assignment_outlined, 'Formations', Colors.green,
          () => _navigate(const MyEnrollmentsScreen(), AppRoutes.learnerMyEnrollments)),
      const SizedBox(width: 12),
      _quickCard(Icons.workspace_premium_outlined, 'Certificats', Colors.amber,
          () => _navigate(const CertificateScreen(), AppRoutes.learnerCertificates)),
    ]);
  }

  Widget _quickCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _recommendationCard(dynamic f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigate(
              FormationDetailScreen(formationId: f.id), AppRoutes.learnerCatalog),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.mauve, AppColors.kaki]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.title ?? 'Formation',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(f.priceLabel ?? '',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mauve)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ]),
          ),
        ),
      ),
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