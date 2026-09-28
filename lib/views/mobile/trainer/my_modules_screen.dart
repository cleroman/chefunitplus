// =============================================================
// ChefUnitPlus - MyModulesScreen (formateur)
// SOURCE : ModuleController -> ModuleService -> API /modules/my
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../controllers/module_controller.dart';
import '../../../models/module.dart';

class MyModulesScreen extends StatefulWidget {
  const MyModulesScreen({super.key});

  @override
  State<MyModulesScreen> createState() => _MyModulesScreenState();
}

class _MyModulesScreenState extends State<MyModulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final ctrl = context.read<ModuleController>();
    await ctrl.loadMyModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes modules'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraichir',
            onPressed: _load,
          ),
        ],
      ),
      body: Consumer<ModuleController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: AppColors.danger),
                    const SizedBox(height: 16),
                    Text(
                      ctrl.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text('Reessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (ctrl.myModules.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open,
                        size: 64, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text(
                      'Aucun module disponible',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vos modules apparaitront ici une fois crees.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.myModules.length,
              itemBuilder: (_, i) => _buildModuleCard(ctrl.myModules[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModuleCard(Module m) {
    Color statusColor;
    String statusLabel;

    switch (m.status) {
      case ModuleStatus.approved:
        statusColor = AppColors.success;
        statusLabel = 'Approuve';
        break;
      case ModuleStatus.rejected:
        statusColor = AppColors.danger;
        statusLabel = 'Rejete';
        break;
      case ModuleStatus.pending:
        statusColor = AppColors.warning;
        statusLabel = 'En attente';
        break;
    }

    final description = m.description ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  m.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${m.hours} h',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}