// ============================================================
// ChefUnitPlus - Inscriptions a valider (VERSION PRO)
// ------------------------------------------------------------
// - Garde TOUTE la logique (controleur, OTP, refus, etc.)
// - Theme Admin (mauve) via DirectorThemeAdapter
// - Header gradient via DirectorPageHeader
// - Cartes modernes + etat vide soigne
// ============================================================

// ignore_for_file: use_build_context_synchronously
// ignore_for_file: dead_null_aware_expression
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_null_comparison
// ignore_for_file: unchecked_use_of_nullable_value
// ignore_for_file: argument_type_not_assignable
// ignore_for_file: invalid_assignment

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/director_theme_adapter.dart';
import '../../core/theme/director_page_header.dart';
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
      backgroundColor: DirectorThemeAdapter.background,
      body: SafeArea(
        child: Column(
          children: [
            DirectorPageHeader(
              title: 'Validations en attente',
              subtitle: ctrl.pending.isEmpty
                  ? 'Aucune inscription a valider'
                  : '${ctrl.pending.length} inscription(s) a traiter',
              icon: Icons.assignment_turned_in_outlined,
              showBack: true,
              actions: [
                if (ctrl.pending.isNotEmpty)
                  IconButton(
                    tooltip: 'Rafraichir',
                    onPressed: () => ctrl.loadPending(refresh: true),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
              ],
            ),
            Expanded(
              child: ctrl.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: DirectorThemeAdapter.primary,
                      ),
                    )
                  : ctrl.pending.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: DirectorThemeAdapter.primary,
                          onRefresh: () => ctrl.loadPending(refresh: true),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(
                                DirectorThemeAdapter.gapMd),
                            itemCount: ctrl.pending.length,
                            itemBuilder: (_, i) =>
                                _buildEnrollmentCard(ctrl.pending[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Etat vide
  // ------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DirectorThemeAdapter.gapXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DirectorThemeAdapter.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 56,
                color: DirectorThemeAdapter.success,
              ),
            ),
            const SizedBox(height: DirectorThemeAdapter.gapLg),
            const Text(
              'Aucune inscription en attente',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: DirectorThemeAdapter.textPrimary,
              ),
            ),
            const SizedBox(height: DirectorThemeAdapter.gapSm),
            const Text(
              'Toutes les inscriptions ont ete traitees',
              style: TextStyle(
                fontSize: 13,
                color: DirectorThemeAdapter.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Carte inscription
  // ------------------------------------------------------------
  Widget _buildEnrollmentCard(Enrollment e) {
    return Container(
      margin: const EdgeInsets.only(bottom: DirectorThemeAdapter.gapMd),
      padding: const EdgeInsets.all(DirectorThemeAdapter.gapMd),
      decoration: DirectorThemeAdapter.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- En-tete : avatar + nom + formation + statut
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    DirectorThemeAdapter.primary.withValues(alpha: 0.15),
                child: Text(
                  _initials(e.learnerName),
                  style: const TextStyle(
                    color: DirectorThemeAdapter.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: DirectorThemeAdapter.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.learnerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DirectorThemeAdapter.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.formationTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: DirectorThemeAdapter.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  color: DirectorThemeAdapter.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'En attente',
                  style: TextStyle(
                    fontSize: 11,
                    color: DirectorThemeAdapter.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DirectorThemeAdapter.gapMd),

          // --- Infos paiement
          Container(
            padding: const EdgeInsets.all(DirectorThemeAdapter.gapMd),
            decoration: BoxDecoration(
              color: DirectorThemeAdapter.background,
              borderRadius:
                  BorderRadius.circular(DirectorThemeAdapter.radiusMd),
              border: Border.all(color: DirectorThemeAdapter.divider),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 15,
                      color: DirectorThemeAdapter.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      e.phone ?? '-',
                      style: const TextStyle(
                        fontSize: 13,
                        color: DirectorThemeAdapter.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      e.amountLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: DirectorThemeAdapter.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 15,
                      color: DirectorThemeAdapter.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.accountName ?? '-',
                        style: const TextStyle(
                          fontSize: 13,
                          color: DirectorThemeAdapter.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DirectorThemeAdapter.gapMd),

          // --- Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(e),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Refuser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DirectorThemeAdapter.danger,
                    side: const BorderSide(
                      color: DirectorThemeAdapter.danger,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DirectorThemeAdapter.radiusMd),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DirectorThemeAdapter.gapMd),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showValidateDialog(e),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Valider'),
                  style: DirectorThemeAdapter.directorPrimaryButtonStyle(),
                ),
              ),
            ],
          ),
        ],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusLg),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: DirectorThemeAdapter.success),
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
                Text(
                  'Apprenant : ${e.learnerName}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Formation : ${e.formationTitle}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: DirectorThemeAdapter.gapLg),

                TextFormField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  decoration: DirectorThemeAdapter.directorInputDecoration(
                    label: 'Code OTP de validation *',
                    hint: '000000',
                    icon: Icons.vpn_key,
                  ).copyWith(counterText: ''),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'OTP requis';
                    if (v.length < 4) return '4 chiffres minimum';
                    return null;
                  },
                ),
                const SizedBox(height: DirectorThemeAdapter.gapMd),

                TextFormField(
                  controller: commentCtrl,
                  maxLines: 2,
                  decoration: DirectorThemeAdapter.directorInputDecoration(
                    label: 'Message (optionnel)',
                    icon: Icons.message_outlined,
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
            style: DirectorThemeAdapter.directorPrimaryButtonStyle(),
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
        backgroundColor:
            ok ? DirectorThemeAdapter.success : DirectorThemeAdapter.danger,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DirectorThemeAdapter.radiusLg),
        ),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: DirectorThemeAdapter.danger),
            SizedBox(width: 8),
            Text('Refuser l\'inscription'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apprenant : ${e.learnerName}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: DirectorThemeAdapter.gapMd),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: DirectorThemeAdapter.directorInputDecoration(
                label: 'Motif du refus',
                icon: Icons.note_outlined,
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
            style: DirectorThemeAdapter.directorDangerButtonStyle(),
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
        backgroundColor: DirectorThemeAdapter.danger,
      ),
    );
  }
}
