import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../controllers/enrollment_controller.dart';
import '../../controllers/formation_controller.dart';
import '../../models/enrollment.dart';

class FormationStatsScreen extends StatefulWidget {
  const FormationStatsScreen({super.key});

  @override
  State<FormationStatsScreen> createState() => _FormationStatsScreenState();
}

class _FormationStatsScreenState extends State<FormationStatsScreen> {
  String _period = '30d'; // 7d | 30d | all

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
    });
  }

  Future<void> _loadAll() async {
    final formCtrl = context.read<FormationController>();
    final enrollCtrl = context.read<EnrollmentController>();
    await Future.wait([
      formCtrl.load(all: true, refresh: true),
      enrollCtrl.loadMine(refresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final formCtrl = context.watch<FormationController>();
    final enrollCtrl = context.watch<EnrollmentController>();

    final formations = formCtrl.formations;
    final enrollments = enrollCtrl.mine;

    // Filtre par periode
    final filteredEnrollments = _filterByPeriod(enrollments);

    // Stats globales
    final totalFormations = formations.length;
    final published = formations.where((f) => f.isPublished).length;
    final totalStudents = filteredEnrollments.length;
    final approvedEnrollments =
        filteredEnrollments.where((e) => e.isApproved).toList();
    final totalRevenue = approvedEnrollments.fold<double>(
      0,
      (sum, e) => sum + e.amountPaid,
    );
    final validationRate = filteredEnrollments.isEmpty
        ? 0.0
        : (approvedEnrollments.length / filteredEnrollments.length) * 100;

    // Top formations (par nombre d'inscriptions)
    final Map<String, int> enrollmentCountByFormation = {};
    for (final e in filteredEnrollments) {
      final key = e.formationTitle.isNotEmpty ? e.formationTitle : 'Inconnu';
      enrollmentCountByFormation[key] =
          (enrollmentCountByFormation[key] ?? 0) + 1;
    }
    final topFormations = enrollmentCountByFormation.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exporter',
            onPressed: () => _exportPdf(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Filtre periode
            _buildPeriodFilter(),
            const SizedBox(height: 16),

            // Stats KPI
            _buildStatsGrid(
              totalFormations,
              published,
              totalStudents,
              totalRevenue,
              validationRate,
            ),
            const SizedBox(height: 20),

            // Graphique 1 : Inscriptions par formation
            if (topFormations.isNotEmpty) ...[
              const _SectionTitle(title: 'Inscriptions par formation'),
              const SizedBox(height: 12),
              _buildBarChart(topFormations),
              const SizedBox(height: 20),
            ],

            // Graphique 2 : Evolution (derniers 7 jours)
            _buildEvolutionSection(filteredEnrollments),
            const SizedBox(height: 20),

            // Top formations
            if (topFormations.isNotEmpty) ...[
              const _SectionTitle(title: 'Top formations'),
              const SizedBox(height: 12),
              ...topFormations
                  .take(5)
                  .map((entry) => _buildTopFormationRow(
                        entry.key,
                        entry.value,
                        filteredEnrollments.length,
                      )),
            ],

            if (formations.isEmpty && enrollments.isEmpty)
              _buildEmptyState(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FILTRE PERIODE
  // ============================================================
  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          const Text(
            'Periode :',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          _periodChip('7 jours', '7d'),
          const SizedBox(width: 6),
          _periodChip('30 jours', '30d'),
          const SizedBox(width: 6),
          _periodChip('Tout', 'all'),
        ],
      ),
    );
  }

  Widget _periodChip(String label, String value) {
    final selected = _period == value;
    return GestureDetector(
      onTap: () => setState(() => _period = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            fontSize: 11,
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Enrollment> _filterByPeriod(List<Enrollment> list) {
    if (_period == 'all') return list;
    final days = _period == '7d' ? 7 : 30;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return list.where((e) => e.requestedAt.isAfter(cutoff)).toList();
  }

  // ============================================================
  // STATS KPI
  // ============================================================
  Widget _buildStatsGrid(
    int total,
    int published,
    int students,
    double revenue,
    double validationRate,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statCard(
          '$total',
          'Formations',
          'published publiees',
          Icons.school,
          AppColors.mauve,
        ),
        _statCard(
          '$students',
          'Etudiants',
          'inscriptions totales',
          Icons.people,
          AppColors.kaki,
        ),
        _statCard(
          '\$${revenue.toStringAsFixed(0)}',
          'Revenus',
          'sur la periode',
          Icons.attach_money,
          AppColors.success,
        ),
        _statCard(
          '${validationRate.toStringAsFixed(0)}%',
          'Validation',
          'taux de validation',
          Icons.check_circle,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _statCard(
    String value,
    String label,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRAPHIQUE BARRES
  // ============================================================
  Widget _buildBarChart(List<MapEntry<String, int>> data) {
    final maxY = data.isEmpty
        ? 10.0
        : (data.map((e) => e.value).reduce((a, b) => a > b ? a : b)).toDouble() *
            1.3;

    // Limiter a 5 items
    final displayData = data.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barGroups: displayData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: AppColors.mauve,
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= displayData.length) {
                          return const SizedBox.shrink();
                        }
                        final label = displayData[idx].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label.length > 8
                                ? '${label.substring(0, 8)}...'
                                : label,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.divider, strokeWidth: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EVOLUTION (line chart)
  // ============================================================
  Widget _buildEvolutionSection(List<Enrollment> enrollments) {
    // Compter les inscriptions par jour sur les 7 derniers jours
    final now = DateTime.now();
    final Map<int, int> dayCount = {};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      dayCount[i] = 0;
      for (final e in enrollments) {
        if (e.requestedAt.year == day.year &&
            e.requestedAt.month == day.month &&
            e.requestedAt.day == day.day) {
          dayCount[i] = (dayCount[i] ?? 0) + 1;
        }
      }
    }

    final maxY = dayCount.values.isEmpty
        ? 10.0
        : (dayCount.values.reduce((a, b) => a > b ? a : b)).toDouble() * 1.5;
    final maxYFinal = maxY < 3 ? 3.0 : maxY;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Evolution (7 derniers jours)'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxYFinal,
                lineBarsData: [
                  LineChartBarData(
                    spots: dayCount.entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: AppColors.mauve,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.mauve.withValues(alpha: 0.15),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: maxYFinal < 5 ? 1 : null,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        final day = now.subtract(Duration(days: 6 - i));
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${day.day}/${day.month}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.divider, strokeWidth: 0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TOP FORMATIONS
  // ============================================================
  Widget _buildTopFormationRow(String title, int count, int total) {
    final percentage = total > 0 ? (count / total) * 100 : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$count inscription(s)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mauve,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.background,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.mauve),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}% des inscriptions',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 60, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Aucune donnee disponible',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export PDF bientot disponible'),
        backgroundColor: AppColors.kaki,
      ),
    );
  }
}

// ============================================================
// WIDGET : Titre de section
// ============================================================
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