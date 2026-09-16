import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/module_controller.dart';
import '../../models/module.dart';
import 'trainer_create_module_screen.dart';

class TrainerMyModulesScreen extends StatefulWidget {
  const TrainerMyModulesScreen({super.key});

  @override
  State<TrainerMyModulesScreen> createState() => _TrainerMyModulesScreenState();
}

class _TrainerMyModulesScreenState extends State<TrainerMyModulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModuleController>().loadMyModules(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ModuleController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes modules'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TrainerCreateModuleScreen(),
            ),
          );
          if (result == true && mounted) {
            ctrl.loadMyModules(refresh: true);
          }
        },
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Proposer un module'),
      ),
      body: ctrl.isLoading && ctrl.myModules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ctrl.myModules.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: () => ctrl.loadMyModules(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.myModules.length,
                    itemBuilder: (_, i) => _moduleCard(ctrl.myModules[i]),
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.mauve.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.library_books_outlined,
                  size: 60, color: AppColors.mauve),
            ),
            const SizedBox(height: 20),
            const Text('Aucun module pour l\'instant',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Proposez votre premier module au directeur',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(Module m) {
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
            Row(
              children: [
                Expanded(
                  child: Text(m.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                _statusChip(m.status),
              ],
            ),
            const SizedBox(height: 6),
            if (m.formationTitle != null)
              Row(
                children: [
                  const Icon(Icons.school_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(m.formationTitle!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            if (m.description != null) ...[
              const SizedBox(height: 8),
              Text(m.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted, height: 1.4)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _info(Icons.schedule, m.hoursLabel),
                const SizedBox(width: 12),
                if (m.hasPdf) _info(Icons.picture_as_pdf, 'PDF'),
              ],
            ),
            if (m.isRejected && m.directorComment != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Motif : ${m.directorComment}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.danger)),
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

  Widget _statusChip(ModuleStatus status) {
    final (color, label) = switch (status) {
      ModuleStatus.pending => (AppColors.warning, 'En attente'),
      ModuleStatus.approved => (AppColors.success, 'Valide'),
      ModuleStatus.rejected => (AppColors.danger, 'Refuse'),
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

  Widget _info(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}