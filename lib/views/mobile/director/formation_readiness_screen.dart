// =============================================================
// ChefUnitPlus - FormationReadinessScreen
// Le directeur verifie si tous les modules sont prets
// =============================================================

import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/api_client.dart';

class FormationReadinessScreen extends StatefulWidget {
  final String formationId;
  final String formationTitle;

  const FormationReadinessScreen({
    super.key,
    required this.formationId,
    required this.formationTitle,
  });

  @override
  State<FormationReadinessScreen> createState() =>
      _FormationReadinessScreenState();
}

class _FormationReadinessScreenState extends State<FormationReadinessScreen> {
  Map<String, dynamic>? _readiness;
  bool _isPublished = false;
  bool _loading = true;
  bool _publishing = false;
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

    final api = context.read<ApiClient>();
    if (!mounted) return;
    try {
      final res = await api.get('/formations/${widget.formationId}/readiness');
      if (!mounted) return;

      // Charger aussi la formation pour connaitre is_published
      bool isPublished = false;
      try {
        final formationRes = await api.get('/formations/${widget.formationId}');
        if (formationRes['success'] == true) {
          final data = formationRes['data'] as Map<String, dynamic>?;
          if (data != null) {
            final pub = data['is_published'];
            isPublished = pub == 1 || pub == true || pub == '1';
          }
        }
      } catch (_) {}

      if (!mounted) return;
      if (res['success'] == true) {
        setState(() {
          _readiness = res['data'] as Map<String, dynamic>?;
          _isPublished = isPublished;
          _loading = false;
        });
      } else {
        setState(() {
          _error = res['message'] as String? ?? 'Erreur';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _publish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publier la formation'),
        content: const Text(
          'Une fois publiee, la formation sera visible par les apprenants. '
          'Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Publier'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _publishing = true);

    final api = context.read<ApiClient>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final res = await api.patch('/formations/${widget.formationId}/publish', body: {});
      if (!mounted) return;

      if (res['success'] == true) {
        setState(() => _isPublished = true);  // <-- AJOUT CRITIQUE : cache le bouton immediatement
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Formation publiee avec succes'),
            backgroundColor: AppColors.success,
          ),
        );
        navigator.pop(true);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(res['message'] as String? ?? 'Erreur'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
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
        ),        title: const Text('Verification de la formation'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Rafraichir',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(),
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

  Widget _buildContent() {
    final r = _readiness ?? {};
    final isReady = r['is_ready'] as bool? ?? false;
    final expected = r['expected_modules'] as int? ?? 0;
    final actual = r['actual_modules'] as int? ?? 0;
    final withTrainer = r['modules_with_trainer'] as int? ?? 0;
    final withPdf = r['modules_with_pdf'] as int? ?? 0;
    final issues = (r['issues'] as List?)?.cast<String>() ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(isReady),
        const SizedBox(height: 20),

        const Text(
          'Etat des modules',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),

        _buildCheckItem(
          'Modules crees',
          '$actual / $expected',
          actual >= expected,
        ),
        _buildCheckItem(
          'Modules avec formateur',
          '$withTrainer / $expected',
          withTrainer >= expected,
        ),
        _buildCheckItem(
          'Modules avec PDF',
          '$withPdf / $expected',
          withPdf >= expected,
        ),

        if (issues.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Points a corriger',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...issues.map((issue) => _buildIssue(issue)),
        ],

        const SizedBox(height: 24),

        // Message "deja publiee" OU bouton Publier
        if (_isPublished)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success, width: 1.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Formation deja publiee',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Les apprenants peuvent deja voir cette formation.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else if (isReady)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _publishing ? null : _publish,
              icon: _publishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.public),
              label: Text(
                _publishing ? 'Publication...' : 'Publier la formation',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'La formation ne peut pas etre publiee tant que '
                    'tous les modules ne sont pas prets.',
                    style: TextStyle(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(bool isReady) {
    final color = isReady ? AppColors.success : AppColors.warning;
    final icon = isReady ? Icons.check_circle : Icons.hourglass_empty;
    final title = isReady
        ? 'Formation prete a publier'
        : 'Formation en attente';
    final subtitle = isReady
        ? 'Tous les modules sont prets.'
        : 'Certains modules ne sont pas encore prets.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.formationTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, String value, bool ok) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (ok ? AppColors.success : AppColors.warning)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.error_outline,
            color: ok ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: ok ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssue(String issue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, color: AppColors.danger, size: 20),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              issue,
              style: const TextStyle(fontSize: 13, color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

