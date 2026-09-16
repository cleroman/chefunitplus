// =============================================================
// ChefUnitPlus - Fiche utilisateur complete
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/role_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data =
          await context.read<UserService>().getFullProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleActive(User user) async {
    final ctrl = context.read<UserController>();
    final ok = user.isActive
        ? await ctrl.suspend(user.id)
        : await ctrl.reactivate(user.id);

    if (!mounted) return;
    if (ok) {
      SnackbarHelper.success(
        context,
        user.isActive ? 'Utilisateur suspendu' : 'Utilisateur reactive',
      );
      _load();
    } else {
      SnackbarHelper.error(context, ctrl.errorMessage ?? 'Erreur');
    }
  }

  Future<void> _resetPassword() async {
    final pwdCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: const Text('Reinitialiser le mot de passe'),
        content: TextField(
          controller: pwdCtrl,
          decoration: const InputDecoration(
            labelText: 'Nouveau mot de passe',
            hintText: 'Min 6 caracteres',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;
    if (pwdCtrl.text.trim().length < 6) {
      SnackbarHelper.error(context, 'Mot de passe trop court (min 6)');
      return;
    }

    final ok = await context.read<UserController>().resetPassword(
          userId: widget.userId,
          newPassword: pwdCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      SnackbarHelper.success(context, 'Mot de passe reinitialise');
    } else {
      SnackbarHelper.error(context, 'Erreur');
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: const Text('Supprimer l\'utilisateur'),
        content: Text(
          'Voulez-vous vraiment supprimer ${user.fullName} ?\n\n'
          'Cette action est irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ok = await context.read<UserController>().delete(user.id);
    if (!mounted) return;
    if (ok) {
      SnackbarHelper.success(context, 'Utilisateur supprime');
      Navigator.pop(context);
    } else {
      SnackbarHelper.error(context, 'Erreur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fiche utilisateur'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(_error ?? 'Utilisateur introuvable'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Reessayer')),
          ],
        ),
      );
    }

    final userRaw = _profile!['user'] as Map<String, dynamic>? ?? {};
    final user = User.fromJson(userRaw);
    final details = _profile!['details'] as Map<String, dynamic>? ?? {};
    final enrollments = _profile!['enrollments'] as List? ?? const [];
    final certificates = _profile!['certificates'] as List? ?? const [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(user, details),
          Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Actions rapides',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        icon: user.isActive
                            ? Icons.block
                            : Icons.check_circle_outline,
                        label: user.isActive ? 'Suspendre' : 'Reactiver',
                        color: user.isActive
                            ? AppColors.danger
                            : AppColors.success,
                        onTap: () => _toggleActive(user),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.key_outlined,
                        label: 'Reset mdp',
                        color: AppColors.warning,
                        onTap: _resetPassword,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.delete_outline,
                        label: 'Supprimer',
                        color: AppColors.danger,
                        onTap: () => _deleteUser(user),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildSection('Informations personnelles', [
            _infoRow(Icons.email_outlined, 'Email', user.email),
            _infoRow(Icons.phone_outlined, 'Telephone',
                Formatters.phoneNumber(user.phone)),
            _infoRow(Icons.location_on_outlined, 'Adresse',
                details['address'] ?? 'Non renseignee'),
            _infoRow(Icons.location_city_outlined, 'Ville',
                details['city'] ?? 'Non renseignee'),
            _infoRow(
                Icons.public_outlined, 'Pays', details['country'] ?? 'RDC'),
            if (details['birth_date'] != null)
              _infoRow(Icons.cake_outlined, 'Date de naissance',
                  details['birth_date'].toString()),
          ]),
          _buildSection('Etudes', [
            _infoRow(Icons.school_outlined, 'Niveau',
                details['education_level'] ?? 'Non renseigne'),
            _infoRow(Icons.book_outlined, 'Filiere',
                details['education_field'] ?? 'Non renseignee'),
            _infoRow(Icons.account_balance_outlined, 'Institution',
                details['education_institution'] ?? 'Non renseignee'),
          ]),
          _buildSection('Formations Scout', [
            _infoRow(Icons.workspace_premium_outlined, 'Formation',
                details['scout_formation'] ?? 'Aucune'),
            _infoRow(Icons.badge_outlined, 'Role scout',
                details['scout_role'] ?? 'Non renseigne'),
            _infoRow(Icons.groups_outlined, 'Groupe scout',
                details['group_name'] ?? 'Aucun groupe'),
          ]),
          _buildSection('Activite', [
            _infoRow(
                Icons.school_outlined, 'Inscriptions', '${enrollments.length}'),
            _infoRow(Icons.workspace_premium_outlined, 'Certificats',
                '${certificates.length}'),
            _infoRow(
                Icons.calendar_today_outlined,
                'Inscrit le',
                user.createdAt != null
                    ? Formatters.dateShort(user.createdAt!)
                    : 'N/A'),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(User user, Map<String, dynamic> details) {
    final photoUrl = details['profile_photo_url'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            user.role.color,
            user.role.color.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              image: photoUrl != null && photoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(photoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl == null || photoUrl.isEmpty
                ? Center(
                    child: Text(
                      user.initials,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: user.role.color,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(user.role.icon, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  user.role.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: user.isActive
                      ? AppColors.successLight
                      : AppColors.dangerLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                user.isActive ? 'Compte actif' : 'Compte suspendu',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.mauveSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.mauve),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                Text(value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
