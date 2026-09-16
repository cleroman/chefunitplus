import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/enrollment_controller.dart';
import '../../models/enrollment.dart';

class MyEnrollmentsScreen extends StatefulWidget {
  const MyEnrollmentsScreen({super.key});

  @override
  State<MyEnrollmentsScreen> createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends State<MyEnrollmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnrollmentController>().loadMine();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<EnrollmentController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes inscriptions'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Actives'),
            Tab(text: 'En attente'),
            Tab(text: 'Autres'),
          ],
        ),
      ),
      body: ctrl.isLoading && ctrl.mine.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _list(ctrl.approved, 'Aucune formation active'),
                _list(ctrl.awaiting,
                    'Aucune inscription en attente de validation'),
                _list([
                  ...ctrl.pendingPayment,
                  ...ctrl.mine
                      .where((e) =>
                          e.status == EnrollmentStatus.rejected ||
                          e.status == EnrollmentStatus.failed)
                ], 'Aucune autre inscription'),
              ],
            ),
    );
  }

  Widget _list(List<Enrollment> items, String emptyMsg) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<EnrollmentController>().loadMine(refresh: true),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_outlined,
                        size: 80, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(emptyMsg,
                        style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EnrollmentController>().loadMine(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (_, i) => _card(items[i]),
      ),
    );
  }

  Widget _card(Enrollment e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(e.formationTitle,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                _statusChip(e.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money,
                    size: 16, color: AppColors.textMuted),
                Text(e.amountLabel,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted)),
                const Spacer(),
                Text(_formatDate(e.requestedAt),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            if (e.directorComment != null && e.directorComment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: AppColors.danger),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(e.directorComment!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.dangerDark)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(EnrollmentStatus s) {
    final (color, label) = switch (s) {
      EnrollmentStatus.approved => (AppColors.success, 'Validée'),
      EnrollmentStatus.pendingDirector => (AppColors.warning, 'En attente'),
      EnrollmentStatus.pendingPayment => (AppColors.kaki, 'Paiement requis'),
      EnrollmentStatus.rejected => (AppColors.danger, 'Refusée'),
      EnrollmentStatus.failed => (AppColors.danger, 'Échouée'),
      EnrollmentStatus.cancelled => (AppColors.textMuted, 'Annulée'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w700)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}