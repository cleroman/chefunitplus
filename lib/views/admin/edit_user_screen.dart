// =============================================================
// ChefUnitPlus - EditUserScreen (Admin)
// Permet de modifier toutes les informations d'un utilisateur
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;

  const EditUserScreen({super.key, required this.userId});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controleurs
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _fonctionCtrl = TextEditingController();
  final _buchettesCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _adresseCtrl.dispose();
    _fonctionCtrl.dispose();
    _buchettesCtrl.dispose();
    super.dispose();
  }

  // ===========================================================
  // CHARGER L'UTILISATEUR
  // ===========================================================
  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ctrl = context.read<UserController>();
      final profile = await ctrl.getFullProfile(widget.userId);

      if (!mounted) return;

      if (profile != null) {
        final user = profile['user'] as Map<String, dynamic>? ?? {};
        final details = profile['details'] as Map<String, dynamic>? ?? {};

        _fullNameCtrl.text = user['full_name']?.toString() ?? '';
        _emailCtrl.text = user['email']?.toString() ?? '';
        _phoneCtrl.text = user['phone']?.toString() ?? '';
        _adresseCtrl.text = details['adresse']?.toString() ??
            details['address']?.toString() ??
            '';
        _fonctionCtrl.text = user['fonction']?.toString() ?? '';
        _buchettesCtrl.text = user['buchettes']?.toString() ?? '0';
      }

      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur : ${e.toString()}';
        _loading = false;
      });
    }
  }

  // ===========================================================
  // SAUVEGARDER
  // ===========================================================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final ctrl = context.read<UserController>();
      final ok = await ctrl.updateUser(
        widget.userId,
        {
          'full_name': _fullNameCtrl.text.trim(),
          'email': _emailCtrl.text.trim().toLowerCase(),
          'phone': _phoneCtrl.text.trim(),
          'adresse': _adresseCtrl.text.trim(),
          'fonction': _fonctionCtrl.text.trim(),
          'buchettes': int.tryParse(_buchettesCtrl.text.trim()) ?? 0,
        },
      );

      if (!mounted) return;

      if (ok) {
        SnackbarHelper.success(context, 'Utilisateur mis a jour');
        Navigator.pop(context, true);
      } else {
        SnackbarHelper.error(
          context,
          ctrl.errorMessage ?? 'Erreur lors de la mise a jour',
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.error(context, 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ===========================================================
  // BUILD
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Modifier utilisateur'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUser, child: const Text('Reessayer')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nom complet
            _buildField(
              controller: _fullNameCtrl,
              label: 'Nom complet',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
            ),
            const SizedBox(height: 16),

            // Email
            _buildField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email requis';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Telephone
            _buildField(
              controller: _phoneCtrl,
              label: 'Telephone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Adresse
            _buildField(
              controller: _adresseCtrl,
              label: 'Adresse',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            // Fonction
            _buildField(
              controller: _fonctionCtrl,
              label: 'Fonction scout',
              icon: Icons.workspace_premium_outlined,
            ),
            const SizedBox(height: 16),

            // Buchettes
            _buildField(
              controller: _buchettesCtrl,
              label: 'Buchettes',
              icon: Icons.star_outline,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // Bouton sauvegarder
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mauve,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
