// ChefUnitPlus - Ecran des demandes de reinitialisation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/password_request_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/snackbar_helper.dart';

class PasswordRequestsScreen extends StatefulWidget {
  const PasswordRequestsScreen({super.key});

  @override
  State<PasswordRequestsScreen> createState() => _PasswordRequestsScreenState();
}

class _PasswordRequestsScreenState extends State<PasswordRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PasswordRequestController>().loadPending();
    });
  }

  Future<void> _approve(String id) async {
    final ctrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        title: const Text('Approuver la demande'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Nouveau mot de passe',
            hintText: 'Min 6 caracteres',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approuver'),
          ),
        ],
      ),
    );

    if (result != true || !mounted) return;
    if (ctrl.text.trim().length < 6) {
      SnackbarHelper.error(context, 'Mot de passe trop court (min 6)');
      return;
    }

    final ok = await context.read<PasswordRequestController>()
        .approve(id, newPassword: ctrl.text.trim());

    if (!mounted) return;
    if (ok) {
      SnackbarHelper.success(context, 'Mot de passe reinitialise');
    } else {
      SnackbarHelper.error(context, 'Erreur');
    }
  }

  Future<void> _reject(String id) async {
    final ok = await context.read<PasswordRequestController>().reject(id);
    if (!mounted) return;
    if (ok) SnackbarHelper.info(context, 'Demande refusee');
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PasswordRequestController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Demandes de mot de passe'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ctrl.loadPending()),
        ],
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.requests.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: AppColors.success),
                      SizedBox(height: 16),
                      Text('Aucune demande en attente', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ctrl.loadPending(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    itemCount: ctrl.requests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final r = ctrl.requests[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: AppColors.warningSoft,
                                    child: Icon(Icons.key, color: AppColors.warning),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.userName ?? 'Utilisateur',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(r.userEmail ?? '',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  Text(Formatters.dateShort(r.createdAt),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                              if (r.reason != null && r.reason!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Raison : ${r.reason}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _reject(r.id),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.danger,
                                        side: const BorderSide(color: AppColors.danger),
                                      ),
                                      icon: const Icon(Icons.close, size: 16),
                                      label: const Text('Refuser'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _approve(r.id),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Approuver'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}