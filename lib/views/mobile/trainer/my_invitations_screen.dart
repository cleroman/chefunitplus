// ignore_for_file: use_build_context_synchronously
// ignore_for_file: dead_null_aware_expression
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_null_comparison
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_const, duplicate_import, unused_element
// =============================================================
// ChefUnitPlus - MyInvitationsScreen
// Le formateur voit ses invitations et peut accepter/refuser
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/module_invitation_service.dart';
import 'attach_lesson_screen.dart';

class MyInvitationsScreen extends StatefulWidget {
  const MyInvitationsScreen({super.key});

  @override
  State<MyInvitationsScreen> createState() => _MyInvitationsScreenState();
}

class _MyInvitationsScreenState extends State<MyInvitationsScreen> {
  List<Map<String, dynamic>> _invitations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final svc = context.read<ModuleInvitationService>();
    final invitations = await svc.listMyInvitations();

    if (mounted) {
      setState(() {
        _invitations = invitations;
        _loading = false;
        if (svc.error != null) _error = svc.error;
      });
    }
  }

  Future<void> _accept(Map<String, dynamic> inv) async {
    final svc = context.read<ModuleInvitationService>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!mounted) return;
    final ok = await svc.acceptInvitation(inv['id'] as String);
    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Invitation acceptee'),
          backgroundColor: AppColors.success,
        ),
      );
      // Naviguer vers l'ecran d'attachement de lecon
      final result = await navigator.push<bool>(
        MaterialPageRoute(
          builder: (_) => AttachLessonScreen(
            moduleId: inv['id'] as String,
            moduleTitle: inv['title'] as String? ?? 'Module',
          ),
        ),
      );
      if (result == true) {
        _load();
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(svc.error ?? 'Erreur'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _decline(Map<String, dynamic> inv) async {
    final svc = context.read<ModuleInvitationService>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser l\'invitation'),
        content: const Text('Voulez-vous vraiment refuser cette invitation ?'),
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

    if (confirmed != true) return;
    if (!mounted) return;

    final ok = await svc.declineInvitation(inv['id'] as String);
    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Invitation refusee'),
          backgroundColor: AppColors.warning,
        ),
      );
      _load();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(svc.error ?? 'Erreur'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes invitations'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _invitations.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _invitations.length,
                        itemBuilder: (_, i) => _buildInvitationCard(_invitations[i]),
                      ),
                    ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Reessayer')),
          ],
        ),
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
            Icon(Icons.mail_outline, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'Aucune invitation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Vous recevrez ici les invitations des directeurs.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationCard(Map<String, dynamic> inv) {
    final status = inv['invitation_status'] as String? ?? 'pending';
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';

    final statusColor = isPending
        ? AppColors.warning
        : isAccepted
            ? AppColors.success
            : AppColors.danger;
    final statusLabel = isPending
        ? 'En attente'
        : isAccepted
            ? 'Acceptee'
            : 'Refusee';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  inv['title'] as String? ?? 'Module',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          if (inv['formation_title'] != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.school_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    inv['formation_title'] as String,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (inv['invitation_message'] != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                inv['invitation_message'] as String,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _decline(inv),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _accept(inv),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
          ],
          if (isAccepted && inv['pdf_path'] == null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttachLessonScreen(
                        moduleId: inv['id'] as String,
                        moduleTitle: inv['title'] as String? ?? 'Module',
                      ),
                    ),
                  );
                  if (result == true) _load();
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Attacher la lecon PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mauve,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
