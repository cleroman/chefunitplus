// =============================================================
// ChefUnitPlus - ScoutVideosScreen
// Page des videos scouts publiees par l'administrateur
// =============================================================

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ScoutVideosScreen extends StatefulWidget {
  const ScoutVideosScreen({super.key});

  @override
  State<ScoutVideosScreen> createState() => _ScoutVideosScreenState();
}

class _ScoutVideosScreenState extends State<ScoutVideosScreen> {
  // Liste locale (a remplacer plus tard par un appel API)
  final List<Map<String, String>> _videos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Videos Scout'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
      ),
      body: _videos.isEmpty ? _buildEmpty() : _buildGrid(),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 16),
            Text(
              'Aucune video disponible',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Les videos publiees par l\'administrateur apparaitront ici.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return _videoCard(video);
      },
    );
  }

  Widget _videoCard(Map<String, String> video) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vignette
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.mauve.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 48,
                color: AppColors.mauve,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video['title'] ?? 'Sans titre',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  video['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}