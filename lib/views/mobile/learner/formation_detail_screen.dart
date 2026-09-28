// ignore_for_file: use_build_context_synchronously
// ignore_for_file: dead_null_aware_expression
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unnecessary_cast
// ignore_for_file: unnecessary_null_comparison
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_const, duplicate_import, unused_element
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../controllers/enrollment_controller.dart';
import '../../../services/qr_service.dart';
import '../../../controllers/formation_controller.dart';
import '../../../services/qr_service.dart';
import '../../../models/formation.dart';
import '../../../models/module.dart';
import 'learner_payment_screen.dart';
import 'learner_formation_suivi_screen.dart';

class FormationDetailScreen extends StatefulWidget {
  final String formationId;
  const FormationDetailScreen({super.key, required this.formationId});

  @override
  State<FormationDetailScreen> createState() => _FormationDetailScreenState();
}

class _FormationDetailScreenState extends State<FormationDetailScreen> {
  Formation? _formation;
  List<Module> _modules = [];
  bool _loading = true;
  String? _error;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QrService>().listMy();
    });
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Capturer les controllers AVANT le premier await
    final fc = context.read<FormationController>();
    final ec = context.read<EnrollmentController>();

    try {
      final f = await fc.getById(widget.formationId);
      final modulesRaw = await fc.listModules(widget.formationId);
      final modules = modulesRaw
          .map((m) => Module.fromJson(m))
          .toList();

      await ec.loadMine();
      final hasAccess = ec.mine.any((e) =>
          e.formationId == widget.formationId && e.isApproved);

      if (!mounted) return;
      setState(() {
        _formation = f;
        _modules = modules;
        _hasAccess = hasAccess;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger la formation';
        _loading = false;
      });
    }
  }

  void _goToPayment() {
    final f = _formation;
    if (f == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LearnerPaymentScreen(amount: f.price, formationTitle: f.title, formationId: f.id)),
    ).then((_) => _load());
  }

  void _goToSuivi() {
    final f = _formation;
    if (f == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearnerFormationSuiviScreen(
          formationId: f.id,
          formationTitle: f.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _formation == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.mauve, foregroundColor: Colors.white),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(_error ?? 'Formation introuvable'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Reessayer')),
            ],
          ),
        ),
      );
    }

    final f = _formation!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(f),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(f),
                const SizedBox(height: 16),

                if (_hasAccess) ...[
                  _buildAccessBanner(),
                  const SizedBox(height: 16),
                  _buildDocumentsSection(f),
                  const SizedBox(height: 16),
                ],

                // QR CODE DE L'APPRENANT
                if (_hasAccess) ...[
                  _buildQrSection(context),
                  const SizedBox(height: 16),
                ],

                _buildDescription(f),
                const SizedBox(height: 20),

                _buildModulesSection(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(f),
    );
  }

  Widget _buildAppBar(Formation f) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.mauve,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          f.title,
          style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.mauve, AppColors.kaki],
            ),
          ),
          child: const Center(
            child: Icon(Icons.school, size: 90, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Formation f) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.kaki.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              f.type.label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.kakiDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Prix
          Row(
            children: [
              const Icon(Icons.attach_money, color: AppColors.mauve, size: 32),
              const SizedBox(width: 8),
              Text(f.priceLabel,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mauveDark)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          if (f.hasTrainer)
            _infoRow(Icons.person_outline, 'Formateur', f.trainerName ?? '-'),
          if (f.hasSchedule)
            _infoRow(Icons.calendar_today_outlined, 'Periode', f.scheduleLabel),
          _infoRow(Icons.schedule, 'Volume horaire', f.durationLabel),
          if (f.maxParticipants > 0)
            _infoRow(Icons.groups_outlined, 'Places',
                '${f.maxParticipants} max'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.mauve),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vous avez acces a cette formation',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(Formation f) {
    if (!f.hasPdf && !f.hasFiche) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: AppColors.mauve),
              SizedBox(width: 8),
              Text('Documents',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          if (f.hasPdf)
            _pdfButton(
              icon: Icons.picture_as_pdf,
              label: 'Support de formation',
              color: AppColors.success,
              onTap: () => _showDownloadInfo('Support telechargeable depuis l\'espace Mes formations'),
            ),
          if (f.hasFiche) ...[
            const SizedBox(height: 8),
            _pdfButton(
              icon: Icons.article_outlined,
              label: 'Fiche technique',
              color: AppColors.kaki,
              onTap: () => _showDownloadInfo('Fiche technique disponible sur le site'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pdfButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ),
            Icon(Icons.download, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(Formation f) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(f.description,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textMuted, height: 1.5)),
      ],
    );
  }

  Widget _buildModulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Programme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Spacer(),
            if (_modules.isNotEmpty)
              Text('${_modules.length} module(s)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 12),
        if (_modules.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Aucun module publie pour le moment',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          )
        else
          ..._modules.map((m) => _moduleTile(m)),
      ],
    );
  }

  Widget _moduleTile(Module m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.mauveSoft,
                  child: Text('${m.order}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mauveDark)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(m.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                if (m.hours > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.kaki.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${m.hours}h',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.kakiDark)),
                  ),
              ],
            ),
            if (m.description != null && m.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 42),
                child: Text(m.description!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
            if (m.hasTrainer || m.hasSchedule) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 42),
                child: Row(
                  children: [
                    if (m.hasTrainer) ...[
                      const Icon(Icons.person_outline,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(m.trainerName ?? '',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(width: 10),
                    ],
                    if (m.hasSchedule) ...[
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(m.scheduleLabel,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(Formation f) {
    if (_hasAccess) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('Commencer la formation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 52,
          child: _hasAccess
              ? ElevatedButton.icon(
                  onPressed: _goToSuivi,
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Suivre'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: _goToPayment,
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text('S\'inscrire pour ${f.priceLabel}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mauve,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _showDownloadInfo(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.kaki),
    );
  }

  // ============================================================
  // SECTION QR CODE
  // ============================================================
  Widget _buildQrSection(BuildContext context) {
    return Consumer<QrService>(
      builder: (context, qrSvc, _) {
        // Verifier si l'apprenant a un QR pour cette formation
        final qrCodes = qrSvc.myQrCodes.where(
          (q) => q['formation_id'] == widget.formationId,
        ).toList();

        if (qrCodes.isEmpty) {
          return const SizedBox.shrink();
        }

        final qr = qrCodes.first;
        final qrData = qr['qr_data']?.toString() ?? qr['code']?.toString() ?? '';
        final progress = qr['progress_percent'] as int? ?? 0;
        final scannedModules = qr['scanned_modules'] != null
            ? (qr['scanned_modules'] is String
                ? (qr['scanned_modules'] as String).split(',').where((e) => e.isNotEmpty).length
                : 0)
            : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mauve.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Titre
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, color: AppColors.mauve, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Mon QR Code de presence',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // QR Code
              if (qrData.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.mauveDark,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.mauve,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Code texte
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  qrData,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Progression
              _buildProgressBar(progress, scannedModules),

              const SizedBox(height: 12),

              // Message de felicitations si 100%
              if (progress >= 100)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.celebration, color: AppColors.success),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Felicitations ! Vous avez termine cette formation.',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Instructions
              const Text(
                'Presentez ce QR code au formateur pour pointer votre presence a chaque module.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // BARRE DE PROGRESSION
  // ============================================================
  Widget _buildProgressBar(int progress, int scannedModules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progression', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(
              '$progress%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: progress >= 100 ? AppColors.success : AppColors.mauve,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 100 ? AppColors.success : AppColors.mauve,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$scannedModules module(s) scanne(s)',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
