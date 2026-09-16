import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/enrollment.dart';

class StudentDetailScreen extends StatelessWidget {
  final Enrollment enrollment;

  const StudentDetailScreen({super.key, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final e = enrollment;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail etudiant'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            tooltip: 'Envoyer un message',
            onPressed: () => _sendMessage(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.mauve.withValues(alpha: 0.1),
                  AppColors.kaki.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.mauve.withValues(alpha: 0.2),
                  child: Text(
                    _initials(e.learnerName),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mauveDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  e.learnerName.isNotEmpty ? e.learnerName : 'Etudiant',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if ((e.learnerEmail ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    e.learnerEmail!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _statusBadge(e),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: 'Formation'),
                const SizedBox(height: 12),
                _infoCard(e),
                const SizedBox(height: 20),
                const _SectionTitle(title: 'Progression'),
                const SizedBox(height: 12),
                _progressCard(e),
                const SizedBox(height: 20),
                const _SectionTitle(title: 'Contact'),
                const SizedBox(height: 12),
                _contactCard(e),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(Enrollment e) {
    final (color, label) = _statusInfo(e);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  (Color, String) _statusInfo(Enrollment e) {
    if (e.isApproved) return (AppColors.success, 'Actif');
    if (e.isRejected) return (AppColors.danger, 'Refuse');
    if (e.isPending) return (AppColors.warning, 'En attente');
    return (AppColors.textMuted, 'Inconnu');
  }

  Widget _infoCard(Enrollment e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _infoRow(Icons.school_outlined, 'Formation',
              e.formationTitle.isNotEmpty ? e.formationTitle : '-'),
          _infoRow(Icons.attach_money, 'Montant', e.amountLabel),
          _infoRow(Icons.calendar_today_outlined, 'Inscrit le',
              _formatDate(e.requestedAt)),
          if (e.approvedAt != null)
            _infoRow(Icons.check_circle_outline, 'Valide le',
                _formatDate(e.approvedAt!)),
        ],
      ),
    );
  }

  Widget _progressCard(Enrollment e) {
    final progress = _computeProgress(e);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mauve,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'complete',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mauve),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Le suivi detaille sera bientot disponible.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(Enrollment e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _infoRow(Icons.email_outlined, 'Email',
              (e.learnerEmail ?? '').isNotEmpty ? e.learnerEmail! : '-'),
          _infoRow(Icons.phone_outlined, 'Telephone',
              (e.phone ?? '').isNotEmpty ? e.phone! : '-'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.mauve),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _computeProgress(Enrollment e) {
    if (e.isApproved) return 0.65;
    if (e.isRejected) return 1.0;
    if (e.isPending) return 0.2;
    return 0.0;
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _sendMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Messagerie bientot disponible'),
        backgroundColor: AppColors.kaki,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.mauve,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}