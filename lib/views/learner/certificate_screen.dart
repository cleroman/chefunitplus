import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/certificate_controller.dart';
import '../../models/certificate.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CertificateController>().loadMine(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CertificateController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes certificats'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ctrl.isLoading && ctrl.list.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ctrl.list.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: () =>
                      ctrl.loadMine(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ctrl.list.length,
                    itemBuilder: (_, i) => _certificateCard(ctrl.list[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mauve.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                size: 72,
                color: AppColors.mauve,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun certificat pour l\'instant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Terminez une formation et faites-la valider par un directeur pour recevoir votre certificat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _certificateCard(Certificate cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.mauve, AppColors.kaki],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert.formationTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'N° ${cert.certificateNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Delivre le ${_formatDate(cert.issuedAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _preview(cert),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Apercu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mauve,
                      side: const BorderSide(color: AppColors.mauve),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _download(cert),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Telecharger'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mauve,
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

  // ============================================================
  // ACTIONS
  // ============================================================
  Future<void> _preview(Certificate cert) async {
    final ctrl = context.read<CertificateController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final bytes = await ctrl.generatePdf(cert);

    if (!mounted) return;
    Navigator.pop(context);

    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur generation PDF'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: 'Certificat_${cert.certificateNumber}.pdf',
    );
  }

  Future<void> _download(Certificate cert) async {
    final ctrl = context.read<CertificateController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final bytes = await ctrl.generatePdf(cert);

    if (!mounted) return;
    Navigator.pop(context);

    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur generation PDF'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Certificat_${cert.certificateNumber}.pdf',
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}