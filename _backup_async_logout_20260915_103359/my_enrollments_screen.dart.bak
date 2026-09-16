import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MyEnrollmentsScreen extends StatefulWidget {
  const MyEnrollmentsScreen({super.key});

  @override
  State<MyEnrollmentsScreen> createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends State<MyEnrollmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Demo data
  final List<Map<String, dynamic>> _active = [
    {
      'title': 'Leadership Fondamental',
      'progress': 0.65,
      'status': 'En cours',
    },
  ];
  final List<Map<String, dynamic>> _pending = [
    {
      'title': 'Gestion de Projet',
      'date': '15/09/2026',
      'status': 'En attente validation',
    },
  ];
  final List<Map<String, dynamic>> _other = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes formations'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Actives'),
            Tab(text: 'En attente'),
            Tab(text: 'Terminees'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildList(_active, 'Aucune formation active'),
          _buildList(_pending, 'Aucune inscription en attente'),
          _buildList(_other, 'Aucune formation terminee'),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, String emptyMsg) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: AppColors.textMuted.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _card(items[i]),
    );
  }

  Widget _card(Map<String, dynamic> item) {
    final hasProgress = item['progress'] != null;
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.mauve.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: AppColors.mauve,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (hasProgress) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: item['progress'],
                backgroundColor: AppColors.background,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.success),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${(item['progress'] * 100).toInt()}% complete',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            if (item['date'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Demande le ${item['date']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item['status'] == 'En cours'
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item['status'],
                    style: TextStyle(
                      fontSize: 11,
                      color: item['status'] == 'En cours'
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w700,
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
}