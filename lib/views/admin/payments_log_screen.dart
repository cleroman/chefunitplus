import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/enrollment_controller.dart';
import '../../models/enrollment.dart';

class PaymentsLogScreen extends StatefulWidget {
  const PaymentsLogScreen({super.key});

  @override
  State<PaymentsLogScreen> createState() => _PaymentsLogScreenState();
}

class _PaymentsLogScreenState extends State<PaymentsLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();

  String _query = '';
  String _period = 'all'; // all | 7d | 30d

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnrollmentController>().loadMine(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<EnrollmentController>();
    final all = ctrl.mine;

    // Filtres
    List<Enrollment> filtered = all;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      filtered = filtered
          .where((e) =>
              e.learnerName.toLowerCase().contains(q) ||
              e.formationTitle.toLowerCase().contains(q) ||
              (e.receiptNumber ?? '').toLowerCase().contains(q))
          .toList();
    }

    if (_period != 'all') {
      final days = _period == '7d' ? 7 : 30;
      final cutoff = DateTime.now().subtract(Duration(days: days));
      filtered = filtered
          .where((e) => e.requestedAt.isAfter(cutoff))
          .toList();
    }

    // Stats
    final totalPaid = filtered
        .where((e) => e.isApproved)
        .fold<double>(0, (sum, e) => sum + e.amountPaid);
    final pendingCount = filtered.where((e) => e.isPending).length;
    final approvedCount = filtered.where((e) => e.isApproved).length;
    final rejectedCount = filtered.where((e) => e.isRejected).length;

    // Séparer par onglets
    final pending = filtered.where((e) => e.isPending).toList();
    final approved = filtered.where((e) => e.isApproved).toList();
    final rejected = filtered.where((e) => e.isRejected).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journal des paiements'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exporter CSV',
            onPressed: () => _exportCsv(filtered),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: 'Tous (${filtered.length})'),
            Tab(text: 'En attente ($pendingCount)'),
            Tab(text: 'Valides ($approvedCount)'),
            Tab(text: 'Refuses ($rejectedCount)'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStats(totalPaid, approvedCount, pendingCount),
          _buildSearchAndFilters(),
          Expanded(
            child: ctrl.isLoading && all.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildList(filtered),
                      _buildList(pending),
                      _buildList(approved),
                      _buildList(rejected),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================
  Widget _buildStats(double totalPaid, int approved, int pending) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _statCard(
            '\$${totalPaid.toStringAsFixed(2)}',
            'Encaisse',
            Icons.attach_money,
            AppColors.success,
          ),
          const SizedBox(width: 10),
          _statCard('$approved', 'Valides', Icons.check_circle, AppColors.mauve),
          const SizedBox(width: 10),
          _statCard('$pending', 'En attente', Icons.hourglass_empty, AppColors.warning),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECHERCHE + FILTRES
  // ============================================================
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Rechercher (nom, formation, recu)...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                _periodChip('Tout', 'all'),
                const SizedBox(width: 8),
                _periodChip('7 jours', '7d'),
                const SizedBox(width: 8),
                _periodChip('30 jours', '30d'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodChip(String label, String value) {
    final selected = _period == value;
    return GestureDetector(
      onTap: () => setState(() => _period = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.mauve : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.mauve : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LISTE
  // ============================================================
  Widget _buildList(List<Enrollment> list) {
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
              SizedBox(height: 12),
              Text(
                'Aucun paiement',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EnrollmentController>().loadMine(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildPaymentCard(list[i]),
      ),
    );
  }

  Widget _buildPaymentCard(Enrollment e) {
    final (statusColor, statusLabel, statusIcon) = _statusInfo(e);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showDetail(e),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icone statut
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.learnerName.isNotEmpty ? e.learnerName : 'Utilisateur',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.formationTitle.isNotEmpty
                            ? e.formationTitle
                            : 'Formation',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
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
                          if (e.receiptNumber != null) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                e.receiptNumber!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Montant
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      e.amountLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mauve,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(e.requestedAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, String, IconData) _statusInfo(Enrollment e) {
    if (e.isApproved) {
      return (AppColors.success, 'Valide', Icons.check_circle);
    } else if (e.isRejected) {
      return (AppColors.danger, 'Refuse', Icons.cancel);
    } else if (e.isPending) {
      return (AppColors.warning, 'En attente', Icons.hourglass_empty);
    }
    return (AppColors.textMuted, 'Inconnu', Icons.help_outline);
  }

  // ============================================================
  // DETAIL TRANSACTION
  // ============================================================
  void _showDetail(Enrollment e) {
    final (statusColor, statusLabel, statusIcon) = _statusInfo(e);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                        if (e.receiptNumber != null)
                          Text(
                            e.receiptNumber!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 30),
              // Details
              _detailRow('Apprenant', e.learnerName.isNotEmpty ? e.learnerName : '-'),
              _detailRow('Formation', e.formationTitle.isNotEmpty ? e.formationTitle : '-'),
              _detailRow('Montant', e.amountLabel),
              _detailRow('Telephone', e.phone ?? '-'),
              _detailRow('Nom du compte', e.accountName ?? '-'),
              _detailRow('Demande le', _formatDateTime(e.requestedAt)),
              if (e.paidAt != null) _detailRow('Paye le', _formatDateTime(e.paidAt!)),
              if (e.approvedAt != null)
                _detailRow('Valide le', _formatDateTime(e.approvedAt!)),
              if (e.directorComment != null && e.directorComment!.isNotEmpty)
                _detailRow('Commentaire', e.directorComment!),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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

  // ============================================================
  // EXPORT CSV
  // ============================================================
  void _exportCsv(List<Enrollment> list) {
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune donnee a exporter'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Construction du CSV
    final buffer = StringBuffer();
    buffer.writeln('Receipt,Apprenant,Formation,Montant,Statut,Date');
    for (final e in list) {
      final line = [
        e.receiptNumber ?? '-',
        e.learnerName,
        e.formationTitle,
        e.amountPaid.toStringAsFixed(2),
        e.status.name,
        _formatDate(e.requestedAt),
      ].map((s) => '"${s.replaceAll('"', '""')}"').join(',');
      buffer.writeln(line);
    }

    // Affichage (le vrai download necessiterait path_provider + file_picker)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export CSV'),
        content: SingleChildScrollView(
          child: Text(
            '${list.length} lignes preparees.\n\n'
            'Copie ce contenu et enregistre-le en .csv :\n\n'
            '${buffer.toString().substring(0, buffer.toString().length > 500 ? 500 : buffer.toString().length)}...',
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatDateTime(DateTime d) =>
      '${_formatDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}