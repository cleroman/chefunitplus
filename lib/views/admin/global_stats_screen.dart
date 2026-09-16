// =============================================================
// ChefUnitPlus - GlobalStatsScreen
// Statistiques globales de la plateforme
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/formation_controller.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/role_constants.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/cards/stats_card.dart';


class GlobalStatsScreen extends StatefulWidget {
  const GlobalStatsScreen({super.key});

  @override
  State<GlobalStatsScreen> createState() => _GlobalStatsScreenState();
}

class _GlobalStatsScreenState extends State<GlobalStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await Future.wait([
      context.read<UserController>().loadAll(),
      context.read<FormationController>().loadMine(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserController>().users;
    final formations = context.watch<FormationController>().formations;

    final totalUsers = users.length;
    final totalFormations = formations.length;
    final publishedFormations =
        formations.where((f) => f.isPublished).length;
    final totalEnrolled =
        formations.fold<int>(0, (s, f) => s + f.enrolledCount);
    final totalRevenue = formations.fold<double>(
      0,
      (s, f) => s + (f.price * f.enrolledCount),
    );
    final avgPrice = formations.isEmpty
        ? 0.0
        : formations.fold<double>(0, (s, f) => s + f.price) /
            formations.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques globales'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafrachir',
            onPressed: _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.mauve,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          children: [
            // KPIs principaux
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                StatsCard(
                  label: 'Utilisateurs',
                  value: '$totalUsers',
                  icon: Icons.people_outline,
                  color: AppColors.mauve,
                ),
                StatsCard(
                  label: 'Formations',
                  value: '$totalFormations',
                  icon: Icons.school_outlined,
                  color: AppColors.kaki,
                ),
                StatsCard(
                  label: 'Publies',
                  value: '$publishedFormations',
                  icon: Icons.public,
                  color: AppColors.success,
                ),
                StatsCard(
                  label: 'Inscriptions',
                  value: '$totalEnrolled',
                  icon: Icons.assignment_turned_in_outlined,
                  color: AppColors.warning,
                ),
                StatsCard(
                  label: 'Revenus',
                  value: Formatters.moneyCompact(totalRevenue),
                  icon: Icons.attach_money,
                  color: AppColors.danger,
                ),
                StatsCard(
                  label: 'Prix moyen',
                  value: Formatters.moneyCompact(avgPrice),
                  icon: Icons.trending_up,
                  color: AppColors.mauveDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rpartition par rle
            const Text(
              'Rpartition par rle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _BreakdownCard(users: users),
            const SizedBox(height: 24),

            // Top formations
            const Text(
              'Top formations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _TopFormations(formations: formations),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// Y"S BREAKDOWN PAR R"LE
// =============================================================
class _BreakdownCard extends StatelessWidget {
  final List users;
  const _BreakdownCard({required this.users});

  int _count(UserRole role) =>
      users.where((u) => u.role == role).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          ...UserRole.values.map((role) {
            final count = _count(role);
            final percent = users.isEmpty ? 0.0 : count / users.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(role.icon, size: 16, color: role.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          role.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: role.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor:
                          role.color.withValues(alpha: 0.12),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(role.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================
// Y? TOP FORMATIONS
// =============================================================
class _TopFormations extends StatelessWidget {
  final List formations;
  const _TopFormations({required this.formations});

  @override
  Widget build(BuildContext context) {
    final sorted = List.from(formations)
      ..sort((a, b) => b.enrolledCount.compareTo(a.enrolledCount));
    final top = sorted.take(5).toList();

    if (top.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 8),
            Text(
              'Aucune formation',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      children: top.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final f = entry.value;
        final revenue = f.price * f.enrolledCount;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.mauve, AppColors.kaki],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${f.enrolledCount} inscrits  ${Formatters.money(revenue)}',
                      style: const TextStyle(
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
      }).toList(),
    );
  }
}