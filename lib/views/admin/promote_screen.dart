import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/user_controller.dart';
import '../../models/role.dart';
import '../../models/user.dart';

class PromoteScreen extends StatefulWidget {
  const PromoteScreen({super.key});

  @override
  State<PromoteScreen> createState() => _PromoteScreenState();
}

class _PromoteScreenState extends State<PromoteScreen> {
  String _filter = 'all';
  String _search = '';
  final _searchCtrl = TextEditingController();
  String? _processingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserController>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UserController>();

    var users = ctrl.users;
    if (_filter != 'all') {
      users = users.where((u) => u.role.name == _filter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      users = users
          .where((u) =>
              u.fullName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Promouvoir un utilisateur'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildList(ctrl, users)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Tous', 'all'),
                const SizedBox(width: 8),
                _filterChip('Apprenants', 'apprenant'),
                const SizedBox(width: 8),
                _filterChip('Formateurs', 'formateur'),
                const SizedBox(width: 8),
                _filterChip('Directeurs', 'directeur'),
                const SizedBox(width: 8),
                _filterChip('Admins', 'admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(UserController ctrl, List<User> users) {
    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (users.isEmpty) {
      return _emptyState();
    }
    return RefreshIndicator(
      onRefresh: () => ctrl.loadAll(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (_, i) => _userCard(users[i]),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Aucun utilisateur trouve',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.mauve : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.mauve : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _userCard(User user) {
    final processing = _processingId == user.id;
    final options = _promotionOptionsFor(user.role);
    final roleColor = user.role.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: roleColor.withValues(alpha: 0.15),
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: roleColor,
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _roleBadge(user.role),
              ],
            ),
            const SizedBox(height: 12),
            if (options.isEmpty)
              _noPromotionInfo()
            else
              _promotionButtons(user, options, processing),
          ],
        ),
      ),
    );
  }

  Widget _noPromotionInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.textMuted.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Aucune promotion disponible pour ce role',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _promotionButtons(User user, List<UserRole> options, bool processing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.upgrade_outlined, size: 16, color: AppColors.success),
            SizedBox(width: 6),
            Text(
              'Promouvoir en :',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((target) {
            return ElevatedButton.icon(
              onPressed: processing ? null : () => _confirmPromotion(user, target),
              icon: processing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(target.icon, size: 16),
              label: Text(target.label),
              style: ElevatedButton.styleFrom(
                backgroundColor: target.color,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _roleBadge(UserRole role) {
    final roleColor = role.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(role.icon, size: 12, color: roleColor),
          const SizedBox(width: 4),
          Text(
            role.label,
            style: TextStyle(
              fontSize: 11,
              color: roleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  List<UserRole> _promotionOptionsFor(UserRole current) {
    switch (current) {
      case UserRole.apprenant:
        return <UserRole>[UserRole.formateur];
      case UserRole.formateur:
        return <UserRole>[UserRole.directeur];
      case UserRole.directeur:
        return <UserRole>[UserRole.admin];
      case UserRole.admin:
        return <UserRole>[];
    }
  }

  Future<void> _confirmPromotion(User user, UserRole target) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upgrade, color: target.color),
            const SizedBox(width: 8),
            const Text('Confirmer la promotion'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Utilisateur : ${user.fullName}'),
            const SizedBox(height: 4),
            Text(
              'Email : ${user.email}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            const Text('Nouveau role :'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(target.icon, size: 18, color: target.color),
                const SizedBox(width: 6),
                Text(
                  target.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: target.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette action modifie immediatement les permissions.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: target.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _processingId = user.id);

    final ctrl = context.read<UserController>();
    final ok = await ctrl.promote(userId: user.id, newRole: target);

    if (!mounted) return;
    setState(() => _processingId = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '${user.fullName} promu ${target.label}'
              : 'Echec de la promotion',
        ),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}