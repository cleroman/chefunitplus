// =============================================================
// ChefUnitPlus - TrainerDashboard
// Tableau de bord du formateur : stats + accès rapides
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/module_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/gradients.dart';
import '../../widgets/layout/role_drawer.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final ctrl = context.read<ModuleController>();
    await ctrl.loadMine();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final modules = context.watch<ModuleController>();
    final user = auth.currentUser;

    final withTrainer = modules.modules.where((m) => m.hasTrainer).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // ---------------- HEADER ----------------
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.formateur,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Builder(
                              builder: (ctx) => IconButton(
                                onPressed: () => Scaffold.of(ctx).openDrawer(),
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.profile,
                              ),
                              icon: const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bonjour, ${user?.fullName.split(' ').first ?? ''} 👨‍🏫',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Gérez vos modules et vos étudiants',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _statChip(
                                icon: Icons.menu_book_outlined,
                                label: 'Modules',
                                value: '${modules.modules.length}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statChip(
                                icon: Icons.assignment_ind_outlined,
                                label: 'Assignés',
                                value: '$withTrainer',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ---------------- ACTIONS RAPIDES ----------------
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actions rapides',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        _actionCard(
                          icon: Icons.library_books_outlined,
                          label: AppStrings.myModules,
                          color: AppColors.mauve,
                          route: AppRoutes.trainerModules,
                        ),
                        _actionCard(
                          icon: Icons.add_box_outlined,
                          label: 'Créer un module',
                          color: AppColors.kaki,
                          route: AppRoutes.trainerModuleEditor,
                        ),
                        _actionCard(
                          icon: Icons.edit_note_outlined,
                          label: 'Créer une leçon',
                          color: AppColors.success,
                          route: AppRoutes.trainerLessonEditor,
                        ),
                        _actionCard(
                          icon: Icons.people_outline,
                          label: AppStrings.studentsList,
                          color: AppColors.danger,
                          route: AppRoutes.trainerStudents,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---------------- MES MODULES RÉCENTS ----------------
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mes modules',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.trainerModules,
                          ),
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (modules.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (modules.modules.isEmpty)
                      _emptyCard(
                        'Vous n\'avez encore aucun module',
                        Icons.menu_book_outlined,
                      )
                    else
                      ...modules.modules.take(3).map(
                            (m) => _moduleTile(
                              title: m.title,
                              subtitle: m.description ?? 'Aucune description',
                              hasTrainer: m.hasTrainer,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.trainerModuleEditor,
                                arguments: {'moduleId': m.id},
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ); // =============================================================
// ChefUnitPlus - Ajout de TOUTES les routes manquantes
// =============================================================
  }

  // ===========================================================
  // 🎯 WIDGETS
  // ===========================================================
  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleTile({
    required String title,
    required String subtitle,
    required bool hasTrainer,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.successSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            color: AppColors.success,
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        trailing: Icon(
          hasTrainer ? Icons.check_circle : Icons.pending_outlined,
          color: hasTrainer ? AppColors.success : AppColors.warning,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _emptyCard(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
