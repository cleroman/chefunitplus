import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MyModulesScreen extends StatelessWidget {
  const MyModulesScreen({super.key});

  final List<Map<String, dynamic>> _modules = const [
    {
      'title': 'Introduction au Leadership',
      'lessons': 5,
      'students': 12,
      'progress': 0.85,
    },
    {
      'title': 'Communication Efficace',
      'lessons': 4,
      'students': 8,
      'progress': 0.60,
    },
    {
      'title': 'Gestion de Projet',
      'lessons': 6,
      'students': 15,
      'progress': 0.40,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes modules'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau module'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _modules.length,
        itemBuilder: (_, i) => _card(_modules[i]),
      ),
    );
  }

  Widget _card(Map<String, dynamic> m) {
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
                    Icons.book_outlined,
                    color: AppColors.mauve,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _info(Icons.play_lesson, '${m['lessons']} lecons'),
                const SizedBox(width: 16),
                _info(Icons.people, '${m['students']} etudiants'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: m['progress'],
              backgroundColor: AppColors.background,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}