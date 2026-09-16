// =============================================================
// ChefUnitPlus - PromoteDirectorScreen
// Promouvoir un utilisateur au rle de Directeur ou Formateur
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


class PromoteDirectorScreen extends StatefulWidget {
  const PromoteDirectorScreen({super.key});

  @override
  State<PromoteDirectorScreen> createState() => _PromoteDirectorScreenState();
}

class _PromoteDirectorScreenState extends State<PromoteDirectorScreen> {
  UserRole _targetRole = UserRole.directeur;
  String? _processingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<UserController>().loadAll(),
    );
  }

  List<User> get _candidates {
    final users = context.read<UserController>().users;
    return users.where((u) => u.role.level < _targetRole.level).toList();
  }

  Future<void> _promote(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text('Promouvoir en ${_targetRole.label}'),
        content: Text(
          'Confirmer la promotion de ${user.fullName} '
          'au rle de ${_targetRole.label} ?\n\n'
          '${_targetRole.description}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _targetRole.color,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Promouvoir'),
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
        newRole: _targetRole,
        actorRole: actor ?? UserRole.admin,
      );

      if (!mounted) return;
      if (ok) {
        SnackbarHelper.success(
          context,
          '${user.fullName} est maintenant ${_targetRole.label}',
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
    final candidates = _candidates;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Promouvoir un utilisateur'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Choix du rle cible
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rle cible',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _roleChip(UserRole.directeur),
                    const SizedBox(width: 10),
                    _roleChip(UserRole.formateur),
                  ],
                ),
              ],
            ),
          ),

          // Liste des candidats
          Expanded(
            child: ctrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : candidates.isEmpty
                    ? _EmptyState(role: _targetRole)
                    : RefreshIndicator(
                        color: AppColors.mauve,
                        onRefresh: () => ctrl.loadAll(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(
                            AppSizes.screenPadding,
                          ),
                          itemCount: candidates.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final u = candidates[i];
                            return _CandidateCard(
                              user: u,
                              targetRole: _targetRole,
                              isProcessing: _processingId == u.id,
                              onPromote: () => _promote(u),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _roleChip(UserRole role) {
    final selected = _targetRole == role;
    return ChoiceChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              role.icon,
              size: 16,
              color: selected ? role.color : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(role.label),
          ],
        ),
      ),
      selected: selected,
      onSelected: (_) => setState(() => _targetRole = role),
      selectedColor: role.color.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? role.color : AppColors.textMuted,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }
}

// =============================================================
// YZ CARTE CANDIDAT
// =============================================================
class _CandidateCard extends StatelessWidget {
  final User user;
  final UserRole targetRole;
  final bool isProcessing;
  final VoidCallback onPromote;

  const _CandidateCard({
    required this.user,
    required this.targetRole,
    required this.isProcessing,
    required this.onPromote,
  });

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: user.role.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                Formatters.initials(user.fullName),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: user.role.color,
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
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
                const SizedBox(height: 6),
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
                    'Actuel : ${user.role.label}',
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
          const SizedBox(width: 8),
          isProcessing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : ElevatedButton.icon(
                  onPressed: onPromote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: targetRole.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.upgrade_outlined, size: 14),
                  label: const Text(
                    'Promouvoir',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
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
class _EmptyState extends StatelessWidget {
  final UserRole role;
  const _EmptyState({required this.role});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upgrade_outlined,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun utilisateur ligible',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun utilisateur ne peut tre promu au rle de ${role.label}.',
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