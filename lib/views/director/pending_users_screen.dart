// =============================================================
// ChefUnitPlus - Ecran Utilisateurs en attente
// Pour le Directeur : activer les nouveaux comptes
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/role_constants.dart';
import '../../controllers/user_activation_controller.dart';
import '../../models/user.dart';
import '../../widgets/states/empty_state.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserActivationController>().loadPending(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UserActivationController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Utilisateurs en attente'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          if (ctrl.pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ctrl.pendingCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ctrl.isLoading && ctrl.pendingUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ctrl.pendingUsers.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: () => ctrl.loadPending(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.pendingUsers.length,
                    itemBuilder: (_, i) => _buildCard(context, ctrl.pendingUsers[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return const EmptyState(
      icon: Icons.check_circle_outline,
      title: 'Aucun utilisateur en attente',
      description: 'Tous les comptes sont actives.',
      color: AppColors.success,
    );
  }

  Widget _buildCard(BuildContext context, User u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header : Avatar + Nom + Email
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                  child: Text(
                    u.initials,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.fullName.isNotEmpty ? u.fullName : 'Utilisateur',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        u.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'En attente',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Role
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: u.role.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    u.role.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: u.role.color,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Inscrit le ${_formatDate(u.createdAt)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Bouton Activer
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmActivate(u),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Activer le compte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmActivate(User u) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Activer le compte'),
        content: Text(
          'Voulez-vous vraiment activer le compte de\n'
          '${u.fullName} (${u.email}) ?\n\n'
          'Il pourra alors se connecter et acceder aux formations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Activer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;
    if (!mounted) return;

    final ctrl = context.read<UserActivationController>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ctrl.activate(u.id);

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Compte active : ${u.fullName}' : 'Echec de l\'activation'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}