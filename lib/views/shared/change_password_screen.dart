import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _saving = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDATION FORCE DU MOT DE PASSE
  // ============================================================
  double get _passwordStrength {
    final pwd = _newCtrl.text;
    if (pwd.isEmpty) return 0;
    double score = 0;
    if (pwd.length >= 8) score += 0.25;
    if (pwd.length >= 12) score += 0.15;
    if (RegExp(r'[a-z]').hasMatch(pwd)) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score += 0.15;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score += 0.15;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(pwd)) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  (Color, String) get _strengthInfo {
    final s = _passwordStrength;
    if (s < 0.3) return (AppColors.danger, 'Faible');
    if (s < 0.6) return (AppColors.warning, 'Moyen');
    if (s < 0.85) return (AppColors.kaki, 'Bon');
    return (AppColors.success, 'Excellent');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    // Integration a venir
    // Pour l'instant : simulation
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalite bientot disponible'),
        backgroundColor: AppColors.kaki,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (strengthColor, strengthLabel) = _strengthInfo;
    final user = context.read<AuthController>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.kaki.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.kaki),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vous changez le mot de passe de\n${user?.email ?? ""}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ancien mot de passe
            TextFormField(
              controller: _oldCtrl,
              obscureText: !_showOld,
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_showOld
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () => setState(() => _showOld = !_showOld),
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nouveau mot de passe
            TextFormField(
              controller: _newCtrl,
              obscureText: !_showNew,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                prefixIcon: const Icon(Icons.lock_reset),
                suffixIcon: IconButton(
                  icon: Icon(_showNew
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () => setState(() => _showNew = !_showNew),
                ),
                border: const OutlineInputBorder(),
                helperText: 'Minimum 8 caracteres',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis';
                if (v.length < 8) return 'Au moins 8 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Indicateur de force
            if (_newCtrl.text.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _passwordStrength,
                        backgroundColor: AppColors.background,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(strengthColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    strengthLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: strengthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Confirmation
            TextFormField(
              controller: _confirmCtrl,
              obscureText: !_showConfirm,
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                prefixIcon: const Icon(Icons.check_circle_outline),
                suffixIcon: IconButton(
                  icon: Icon(_showConfirm
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _showConfirm = !_showConfirm),
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis';
                if (v != _newCtrl.text) return 'Les mots de passe ne correspondent pas';
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Bouton
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving
                    ? 'Modification...'
                    : 'Changer le mot de passe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mauve,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}