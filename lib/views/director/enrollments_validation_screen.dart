import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/enrollment_controller.dart';
import '../../models/enrollment.dart';

class EnrollmentsValidationScreen extends StatefulWidget {
  const EnrollmentsValidationScreen({super.key});

  @override
  State<EnrollmentsValidationScreen> createState() =>
      _EnrollmentsValidationScreenState();
}

class _EnrollmentsValidationScreenState
    extends State<EnrollmentsValidationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnrollmentController>().loadPending();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<EnrollmentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Validations en attente'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.pending.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: () => ctrl.loadPending(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.pending.length,
                    itemBuilder: (_, i) => _enrollmentCard(ctrl.pending[i]),
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: AppColors.success),
            SizedBox(height: 16),
            Text(
              'Aucune inscription en attente',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enrollmentCard(Enrollment e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom + statut
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.mauveSoft,
                  child: Text(
                    _initials(e.learnerName),
                    style: const TextStyle(
                      color: AppColors.mauveDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.learnerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.formationTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'En attente',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Infos paiement
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        e.phone ?? '-',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        e.amountLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mauve,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.account_circle,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          e.accountName ?? '-',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(e),
                    icon: const Icon(Icons.close, color: AppColors.danger, size: 18),
                    label: const Text(
                      'Refuser',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showValidateDialog(e),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // ============================================================
  // DIALOG VALIDATION (avec OTP)
  // ============================================================
  Future<void> _showValidateDialog(Enrollment e) async {
    final otpCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Valider l\'inscription'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apprenant : ${e.learnerName}',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('Formation : ${e.formationTitle}',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 16),

                // OTP
                TextFormField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Code OTP de validation *',
                    hintText: '000000',
                    prefixIcon: Icon(Icons.vpn_key),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'OTP requis';
                    if (v.length < 4) return '4 chiffres minimum';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Commentaire
                TextFormField(
                  controller: commentCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Message (optionnel)',
                    prefixIcon: Icon(Icons.message_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Valider'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ctrl = context.read<EnrollmentController>();
    final ok = await ctrl.validate(
      e.id,
      otp: otpCtrl.text.trim(),
      comment: commentCtrl.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Inscription validee' : ctrl.errorMessage ?? 'Echec'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  // ============================================================
  // DIALOG REFUS
  // ============================================================
  Future<void> _showRejectDialog(Enrollment e) async {
    final reasonCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Refuser l\'inscription'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apprenant : ${e.learnerName}',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motif du refus',
                border: OutlineInputBorder(),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ctrl = context.read<EnrollmentController>();
    final ok = await ctrl.reject(e.id, comment: reasonCtrl.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Inscription refusee' : 'Echec'),
        backgroundColor: ok ? AppColors.danger : AppColors.danger,
      ),
    );
  }
}