// ignore_for_file: use_build_context_synchronously
// ignore_for_file: dead_null_aware_expression
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_null_comparison
// =============================================================
// ChefUnitPlus - PendingPaymentsScreen
// Liste des paiements en attente de validation
// =============================================================

import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import '../../../models/enrollment.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/enrollment_service.dart';

class PendingPaymentsScreen extends StatefulWidget {
  const PendingPaymentsScreen({super.key});

  @override
  State<PendingPaymentsScreen> createState() => _PendingPaymentsScreenState();
}

class _PendingPaymentsScreenState extends State<PendingPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnrollmentService>().loadPending();
    });
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Accueil',
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.homeForRole(context.read<AuthController>().currentUser?.role ?? 'learner'),
            (route) => false,
          ),
        ),        title: const Text('Paiements en attente'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: Consumer<EnrollmentService>(
        builder: (context, svc, _) {
          if (svc.loading && svc.pendingPayments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (svc.pendingPayments.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            onRefresh: () => svc.loadPending(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: svc.pendingPayments.length,
              itemBuilder: (_, i) => _buildCard(svc.pendingPayments[i], svc),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
            SizedBox(height: 16),
            Text(
              'Aucun paiement en attente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Tous les paiements ont ete traites.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Enrollment item, EnrollmentService svc) {
    final amount = item.amountPaid ?? 0;
    final learnerName = item.learnerName ?? 'Apprenant';
    final formationTitle = item.formationTitle ?? 'Formation';
    final paymentRef = item.paymentRef ?? '';
    final phone = item.phone ?? '';
    final accountName = item.accountName ?? '';
    final paidAt = _formatDate(item.paidAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header : montant + badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$amount USD',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  paidAt,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Apprenant
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: AppColors.mauve),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    learnerName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Formation
            Row(
              children: [
                const Icon(Icons.school_outlined, size: 18, color: AppColors.mauve),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    formationTitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),

            // Infos paiement
            if (paymentRef.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.receipt_outlined, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Ref : $paymentRef',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    phone,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
            if (accountName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.account_circle_outlined, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    accountName,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(item, svc),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _validate(item, svc),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
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

  Future<void> _validate(Enrollment item, EnrollmentService svc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Valider le paiement'),
        content: Text(
          'Confirmer la validation du paiement de ${item.learnerName} '
          'pour "${item.formationTitle}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final ok = await svc.validate(item.id as String);

    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Paiement valide' : 'Erreur de validation'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _showRejectDialog(Enrollment item, EnrollmentService svc) async {
    final commentCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser le paiement'),
        content: TextField(
          controller: commentCtrl,
          decoration: const InputDecoration(
            labelText: 'Raison (optionnel)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
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

    commentCtrl.dispose();

    if (confirmed != true) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final ok = await svc.validate(item.id as String, comment: 'REFUSE: ${commentCtrl.text}');

    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Paiement traite' : 'Erreur'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }
}

