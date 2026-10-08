// =============================================================
// ChefUnitPlus - Admin : Detail des preuves d'un utilisateur
// Permet de valider ou rejeter un utilisateur
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/api_client.dart';
import '../../../services/user_service.dart';

class UserProofsDetailScreen extends StatefulWidget {
  final String userId;

  const UserProofsDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserProofsDetailScreen> createState() =>
      _UserProofsDetailScreenState();
}

class _UserProofsDetailScreenState extends State<UserProofsDetailScreen> {
  Map<String, dynamic>? _user;
  List<dynamic> _proofs = [];
  bool _loading = true;
  String? _error;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProofs();
  }

  Future<void> _loadUserProofs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Recuperer l'ApiClient PARTAGE (avec token) via Provider
      final api = context.read<ApiClient>();
      final userService = UserService(api);
      final result = await userService.getUserProofs(widget.userId);

      if (!mounted) return;

      final data = result['data'] ?? result;
      setState(() {
        _user = data['user'] as Map<String, dynamic>?;
        _proofs = (data['proofs'] as List?) ?? [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur : ' + e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _validate() async {
    final confirm = await _showConfirmDialog(
      'Valider cet utilisateur',
      'L utilisateur sera active et pourra acceder a son compte.',
      'Valider',
      AppColors.success,
    );

    if (confirm != true) return;

    setState(() => _processing = true);

    try {
      // Recuperer l'ApiClient PARTAGE (avec token) via Provider
      final api = context.read<ApiClient>();
      final userService = UserService(api);
      final result = await userService.validateUser(widget.userId);

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackbar('Utilisateur valide avec succes', AppColors.success);
        Navigator.pop(context);
      } else {
        _showSnackbar(result['message'] ?? 'Erreur', AppColors.danger);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Erreur : ' + e.toString(), AppColors.danger);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _reject() async {
    final reasonCtrl = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter cet utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'L utilisateur ne pourra pas acceder a son compte.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Raison du rejet (optionnel)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _processing = true);

    try {
      // Recuperer l'ApiClient PARTAGE (avec token) via Provider
      final api = context.read<ApiClient>();
      final userService = UserService(api);
      final result = await userService.rejectUser(
        widget.userId,
        reason: reasonCtrl.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackbar('Utilisateur rejete', AppColors.warning);
        Navigator.pop(context);
      } else {
        _showSnackbar(result['message'] ?? 'Erreur', AppColors.danger);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Erreur : ' + e.toString(), AppColors.danger);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<bool?> _showConfirmDialog(
    String title,
    String message,
    String confirmLabel,
    Color color,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail des preuves'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: (_user != null && !_loading)
          ? _buildActionBar()
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mauve),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.danger, size: 64),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserProofs,
                child: const Text('Reessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserCard(),
          const SizedBox(height: 24),
          const Text(
            'Preuves soumises',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_proofs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aucune preuve',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ..._proofs.asMap().entries.map((entry) {
              return _buildProofCard(entry.key + 1, entry.value);
            }),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    if (_user == null) return const SizedBox.shrink();

    final fullName = _user!['full_name'] ?? 'Utilisateur';
    final email = _user!['email'] ?? '';
    final fonction = _user!['fonction'] ?? 'N/A';
    final buchettes = _user!['buchettes'] ?? 0;
    final registrationCode = _user!['registration_code'] ?? '';
    final codeIsUsed = _user!['code_is_used'] == true;
    final phone = _user!['phone'] ?? '';
    final adresse = _user!['adresse'] ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.mauve,
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (registrationCode.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kakiSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.vpn_key, size: 22, color: AppColors.kaki),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Code de verification',
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        Text(
                          registrationCode,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            color: AppColors.kaki,
                          ),
                        ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          codeIsUsed ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: codeIsUsed ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          codeIsUsed ? 'Code utilise' : 'Code non utilise',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: codeIsUsed ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),

                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy, color: AppColors.kaki),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: registrationCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copie'), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: AppColors.mauve),
                  const SizedBox(width: 8),
                  Text(phone, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
            if (adresse.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.mauve),
                  const SizedBox(width: 8),
                  Expanded(child: Text(adresse, style: const TextStyle(fontSize: 14))),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                _buildInfoItem('Fonction', fonction.toString()),
                const SizedBox(width: 16),
                _buildInfoItem('Buchettes', buchettes.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofCard(int index, dynamic proof) {
    final title = proof['title'] ?? 'Preuve ' + index.toString();
    final filePath = proof['file_path'] ?? '';
    final fileSize = proof['file_size'] ?? 0;
    final mimeType = proof['mime_type'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mauveSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.mauve,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (fileSize / 1024).toStringAsFixed(1) + ' Ko - ' + mimeType,
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
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _processing ? null : _reject,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Rejeter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _processing ? null : _validate,
              icon: _processing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check, size: 18),
              label: const Text('Valider'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



