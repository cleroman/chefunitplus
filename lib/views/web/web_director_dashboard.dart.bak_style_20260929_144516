// =============================================================
// ChefUnitPlus - WebDirectorDashboard (VERSION PRO)
// -------------------------------------------------------------
// - Garde WebLayout, controleurs, routes, KPIs et paiements
// - Theme Admin (mauve) applique via DirectorThemeAdapter
// - Header gradient, KPIs modernes, etat vide soigne
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/director_theme_adapter.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/enrollment_controller.dart';
import '../../controllers/formation_controller.dart';
import 'web_layout.dart';

class WebDirectorDashboard extends StatefulWidget {
  const WebDirectorDashboard({super.key});

  @override
  State<WebDirectorDashboard> createState() => _WebDirectorDashboardState();
}

class _WebDirectorDashboardState extends State<WebDirectorDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EnrollmentController>().loadMine();
      context.read<FormationController>().load(all: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebLayout(
      title: 'Tableau de bord',
      selectedIndex: 0,
      menuItems: const [
        WebMenuItem(
          icon: Icons.dashboard,
          label: 'Tableau de bord',
          route: AppRoutes.directorHome,
        ),
        WebMenuItem(
          icon: Icons.check_circle_outline,
          label: 'Inscriptions a valider',
          route: AppRoutes.directorEnrollments,
        ),
        WebMenuItem(
          icon: Icons.school,
          label: 'Formations',
          route: AppRoutes.directorFormations,
        ),
        WebMenuItem(
          icon: Icons.people,
          label: 'Formateurs',
          route: AppRoutes.directorTrainers,
        ),
        WebMenuItem(
          icon: Icons.analytics,
          label: 'Statistiques',
          route: AppRoutes.directorStats,
        ),
      ],
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Consumer2<EnrollmentController, FormationController>(
      builder: (context, enrollCtrl, formCtrl, _) {
        final formations = formCtrl.formations;
        final pending = enrollCtrl.pending;
        final approved =
            enrollCtrl.mine.where((e) => e.status == 'approved').toList();
        final totalRevenue = enrollCtrl.mine.fold<double>(
          0,
          (sum, e) => sum + e.amountPaid,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(DirectorThemeAdapter.gapLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: DirectorThemeAdapter.gapLg),
              _buildStats(
                formations.length,
                pending.length,
                approved.length,
                totalRevenue,
              ),
              const SizedBox(height: DirectorThemeAdapter.gapLg),
              _buildPendingPayments(pending),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Header gradient mauve
  // ------------------------------------------------------------
  Widget _buildHeader() {
    final user = context.read<AuthController>().currentUser;
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
                radius: 26,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 30),
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
                      user?.fullName ?? 'Directeur',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
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
  // 4 KPIs modernes
  // ------------------------------------------------------------
  Widget _buildStats(int formations, int pending, int approved, double revenue) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Formations',
            value: '$formations',
            subtitle: 'Catalogue total',
            icon: Icons.school,
            color: DirectorThemeAdapter.primary,
          ),
        ),
        const SizedBox(width: DirectorThemeAdapter.gapMd),
        Expanded(
          child: _StatCard(
            label: 'Paiements en attente',
            value: '$pending',
            subtitle: 'A valider',
            icon: Icons.hourglass_empty,
            color: DirectorThemeAdapter.warning,
          ),
        ),
        const SizedBox(width: DirectorThemeAdapter.gapMd),
        Expanded(
          child: _StatCard(
            label: 'Valides',
            value: '$approved',
            subtitle: 'Inscriptions',
            icon: Icons.check_circle,
            color: DirectorThemeAdapter.success,
          ),
        ),
        const SizedBox(width: DirectorThemeAdapter.gapMd),
        Expanded(
          child: _StatCard(
            label: 'Revenus',
            value: '${revenue.toStringAsFixed(0)} USD',
            subtitle: 'Total encaisse',
            icon: Icons.attach_money,
            color: DirectorThemeAdapter.tertiary,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // Bloc Paiements en attente
  // ------------------------------------------------------------
  Widget _buildPendingPayments(List<dynamic> pending) {
    return Container(
      padding: const EdgeInsets.all(DirectorThemeAdapter.gapLg),
      decoration: DirectorThemeAdapter.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DirectorThemeAdapter.warning.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(DirectorThemeAdapter.radiusSm),
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  color: DirectorThemeAdapter.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: DirectorThemeAdapter.gapMd),
              const Expanded(
                child: Text(
                  'Paiements en attente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DirectorThemeAdapter.textPrimary,
                  ),
                ),
              ),
              if (pending.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DirectorThemeAdapter.warning,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${pending.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DirectorThemeAdapter.gapMd),
          if (pending.isEmpty)
            _buildEmptyPayments()
          else
            ...pending.take(5).map(_buildPaymentRow),
        ],
      ),
    );
  }

  Widget _buildEmptyPayments() {
    return Padding(
      padding: const EdgeInsets.all(DirectorThemeAdapter.gapLg),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: DirectorThemeAdapter.success.withValues(alpha: 0.5),
          ),
          const SizedBox(height: DirectorThemeAdapter.gapMd),
          const Text(
            'Aucun paiement en attente',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DirectorThemeAdapter.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tous les paiements ont ete traites',
            style: TextStyle(
              fontSize: 13,
              color: DirectorThemeAdapter.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(dynamic e) {
    return Container(
      margin: const EdgeInsets.only(bottom: DirectorThemeAdapter.gapSm),
      padding: const EdgeInsets.all(DirectorThemeAdapter.gapMd),
      decoration: BoxDecoration(
        color: DirectorThemeAdapter.background,
        borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusMd),
        border: Border.all(color: DirectorThemeAdapter.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                DirectorThemeAdapter.warning.withValues(alpha: 0.15),
            child: const Icon(
              Icons.hourglass_empty,
              color: DirectorThemeAdapter.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: DirectorThemeAdapter.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${e.learnerName ?? "Apprenant"}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DirectorThemeAdapter.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${e.formationTitle ?? "Formation"}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DirectorThemeAdapter.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${e.amountPaid.toStringAsFixed(0)} USD',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: DirectorThemeAdapter.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Carte statistique moderne
// ============================================================
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DirectorThemeAdapter.gapLg),
      decoration: DirectorThemeAdapter.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(DirectorThemeAdapter.radiusSm),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: color.withValues(alpha: 0.5),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: DirectorThemeAdapter.gapMd),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
          ),
        ],
      ),
    );
  }
}

