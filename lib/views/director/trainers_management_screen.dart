// =============================================================
// ChefUnitPlus - TrainersManagementScreen
// Nommer / Rvoquer les formateurs (promotion depuis apprenants)
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/role.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/role_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/user.dart';


class TrainersManagementScreen extends StatefulWidget {
  const TrainersManagementScreen({super.key});

  @override
  State<TrainersManagementScreen> createState() =>
      _TrainersManagementScreenState();
}

class _TrainersManagementScreenState
    extends State<TrainersManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<UserController>().loadAll();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _promote(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: const Text('Nommer formateur'),
        content: Text(
          'Confirmer la promotion de ${user.fullName} au rle de Formateur ?\n\n'
          'Cette personne pourra crer des modules et leons, et voir ses tudiants.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nommer'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _processingId = user.id);
    final actor = context.read<AuthController>().currentUser?.role;
    final ctrl = context.read<UserController>();

    try {
      final ok = await ctrl.promote(
        userId: user.id,
        newRole: 'formateur',
        actorRole: actor ?? 'directeur',
      );
      if (!mounted) return;
      if (ok) {
        SnackbarHelper.success(
          context,
          '${user.fullName} est maintenant Formateur',
        );
      } else {
        SnackbarHelper.error(context, ctrl.errorMessage ?? 'Erreur');
      }
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _demote(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: const Text('Rvoquer le formateur'),
        content: Text(
          'Retirer le rle de Formateur  ${user.fullName} ?\n\n'
          'Cette personne redeviendra Apprenant.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rvoquer'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _processingId = user.id);
    final actor = context.read<AuthController>().currentUser?.role;
    final ctrl = context.read<UserController>();

    try {
      final ok = await ctrl.promote(
        userId: user.id,
        newRole: 'apprenant',
        actorRole: actor ?? 'directeur',
      );
      if (!mounted) return;
      if (ok) {
        SnackbarHelper.info(
          context,
          '${user.fullName} redevient Apprenant',
        );
      } else {
        SnackbarHelper.error(context, ctrl.errorMessage ?? 'Erreur');
      }
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UserController>();
    final trainers =
        ctrl.users.where((u) => u.role == UserRole.formateur).toList();
    final learners =
        ctrl.users.where((u) => u.role == UserRole.apprenant).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion des formateurs'),
        backgroundColor: AppColors.kaki,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafrachir',
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Formateurs (${trainers.length})'),
            Tab(text: 'Apprenants (${learners.length})'),
          ],
        ),
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _UserList(
                  users: trainers,
                  isTrainerList: true,
                  processingId: _processingId,
                  onPromote: _promote,
                  onDemote: _demote,
                  onRefresh: _load,
                ),
                _UserList(
                  users: learners,
                  isTrainerList: false,
                  processingId: _processingId,
                  onPromote: _promote,
                  onDemote: _demote,
                  onRefresh: _load,
                ),
              ],
            ),
    );
  }
}

// =============================================================
// Y"< LISTE UTILISATEURS
// =============================================================
class _UserList extends StatelessWidget {
  final List<User> users;
  final bool isTrainerList;
  final String? processingId;
  final ValueChanged<User> onPromote;
  final ValueChanged<User> onDemote;
  final Future<void> Function() onRefresh;

  const _UserList({
    required this.users,
    required this.isTrainerList,
    required this.processingId,
    required this.onPromote,
    required this.onDemote,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return _EmptyList(isTrainerList: isTrainerList);
    }

    return RefreshIndicator(
      color: AppColors.kaki,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final u = users[i];
          return _UserCard(
            user: u,
            isTrainer: isTrainerList,
            isProcessing: processingId == u.id,
            onPromote: () => onPromote(u),
            onDemote: () => onDemote(u),
          );
        },
      ),
    );
  }
}

// =============================================================
// YZ CARTE UTILISATEUR
// =============================================================
class _UserCard extends StatelessWidget {
  final User user;
  final bool isTrainer;
  final bool isProcessing;
  final VoidCallback onPromote;
  final VoidCallback onDemote;

  const _UserCard({
    required this.user,
    required this.isTrainer,
    required this.isProcessing,
    required this.onPromote,
    required this.onDemote,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isTrainer ? AppColors.success : AppColors.mauve;

    return Container(
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
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                Formatters.initials(user.fullName),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: user.role.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.role.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: user.role.color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action
          if (isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else if (isTrainer)
            IconButton(
              tooltip: 'Rvoquer',
              onPressed: onDemote,
              icon: const Icon(
                Icons.person_remove_outlined,
                color: AppColors.danger,
              ),
            )
          else
            IconButton(
              tooltip: 'Nommer formateur',
              onPressed: onPromote,
              icon: const Icon(
                Icons.person_add_outlined,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================
// Y" ?TAT VIDE
// =============================================================
class _EmptyList extends StatelessWidget {
  final bool isTrainerList;
  const _EmptyList({required this.isTrainerList});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTrainerList
                  ? Icons.group_outlined
                  : Icons.people_outline,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              isTrainerList
                  ? 'Aucun formateur nomm'
                  : 'Aucun apprenant disponible',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTrainerList
                  ? 'Nommez vos formateurs depuis l\'onglet "Apprenants".'
                  : 'Les apprenants apparatront aprs leur inscription.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}