import 'package:flutter/material.dart';
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
      context.read<CertificateController>().loadMine();
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
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.list.isEmpty
              ? _empty()
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

  Widget _empty() => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium_outlined,
                  size: 100, color: AppColors.mauve),
              SizedBox(height: 20),
              Text(
                'Aucun certificat pour l\'instant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Terminez une formation et faites-la valider par un directeur pour recevoir votre certificat.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );

  Widget _certificateCard(Certificate c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.mauve, AppColors.kaki],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.workspace_premium,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.formationTitle,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('N° ${c.certificateNumber}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Délivré le ${_formatDate(c.issuedAt)}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
            if (c.hasPdf) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _download(c),
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger le PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mauve,
                    side: const BorderSide(color: AppColors.mauve),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _download(Certificate c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Téléchargement de ${c.certificateNumber}...'),
        backgroundColor: AppColors.mauve,
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}