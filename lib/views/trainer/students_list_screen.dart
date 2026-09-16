import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/enrollment_controller.dart';
import '../../models/enrollment.dart';
import 'student_detail_screen.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
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
    List<Enrollment> all = ctrl.mine;

    // Recherche
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      all = all
          .where((e) =>
              e.learnerName.toLowerCase().contains(q) ||
              e.formationTitle.toLowerCase().contains(q) ||
              (e.learnerEmail ?? '').toLowerCase().contains(q))
          .toList();
    }

    final approved = all.where((e) => e.isApproved).toList();
    final pending = all.where((e) => e.isPending).toList();
    final rejected = all.where((e) => e.isRejected).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes etudiants'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Tous (${all.length})'),
            Tab(text: 'Actifs (${approved.length})'),
            Tab(text: 'En attente (${pending.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStats(all.length, approved.length, rejected.length),
          _buildSearchBar(),
          Expanded(
            child: ctrl.isLoading && all.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildList(all),
                      _buildList(approved),
                      _buildList(pending),
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
  Widget _buildStats(int total, int approved, int rejected) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _statCard('$total', 'Total', Icons.people, AppColors.mauve),
          const SizedBox(width: 10),
          _statCard('$approved', 'Actifs', Icons.check_circle, AppColors.success),
          const SizedBox(width: 10),
          _statCard('$rejected', 'Refuses', Icons.cancel, AppColors.danger),
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
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
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
  // RECHERCHE
  // ============================================================
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: Colors.white,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Rechercher un etudiant...',
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
              Icon(Icons.people_outline, size: 64, color: AppColors.textMuted),
              SizedBox(height: 12),
              Text(
                'Aucun etudiant',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<EnrollmentController>().loadMine(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildCard(list[i]),
      ),
    );
  }

  Widget _buildCard(Enrollment e) {
    final progress = _computeProgress(e);

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
          onTap: () => _openDetail(e),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar avec initiales
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.mauve.withValues(alpha: 0.15),
                  child: Text(
                    _initials(e.learnerName),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mauveDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.learnerName.isNotEmpty ? e.learnerName : 'Etudiant',
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
                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.background,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _progressColor(e),
                                ),
                                minHeight: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _progressColor(e),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Statut icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _progressColor(e).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon(e),
                    color: _progressColor(e),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  double _computeProgress(Enrollment e) {
    if (e.isApproved) return 0.65;
    if (e.isRejected) return 1.0;
    if (e.isPending) return 0.2;
    return 0.0;
  }

  Color _progressColor(Enrollment e) {
    if (e.isApproved) return AppColors.success;
    if (e.isRejected) return AppColors.danger;
    if (e.isPending) return AppColors.warning;
    return AppColors.textMuted;
  }

  IconData _statusIcon(Enrollment e) {
    if (e.isApproved) return Icons.check;
    if (e.isRejected) return Icons.close;
    if (e.isPending) return Icons.hourglass_empty;
    return Icons.help_outline;
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  void _openDetail(Enrollment e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentDetailScreen(enrollment: e)),
    );
  }
}