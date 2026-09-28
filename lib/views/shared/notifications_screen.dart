// =============================================================
// ChefUnitPlus - NotificationsScreen
// Affiche toutes les notifications
// =============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().loadMy();
    });
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'A l\'instant';
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
      if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'enrollment_pending':
      case 'enrollment_validated':
        return Icons.assignment_turned_in_outlined;
      case 'module_deposit':
      case 'module_attached':
        return Icons.cloud_upload_outlined;
      case 'attendance_marked':
        return Icons.qr_code_scanner;
      case 'formation_completed':
        return Icons.celebration;
      case 'payment_request':
        return Icons.payments_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'enrollment_pending':
      case 'payment_request':
        return AppColors.warning;
      case 'enrollment_validated':
      case 'module_attached':
        return AppColors.success;
      case 'formation_completed':
        return AppColors.mauve;
      case 'attendance_marked':
        return Colors.blue;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.mauve,
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotificationService>(
            builder: (context, svc, _) {
              if (svc.unreadCount == 0) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => svc.markAllAsRead(),
                icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
                label: const Text('Tout lire', style: TextStyle(color: Colors.white, fontSize: 12)),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, svc, _) {
          if (svc.loading && svc.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (svc.notifications.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            onRefresh: () => svc.loadMy(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: svc.notifications.length,
              itemBuilder: (_, i) => _buildNotificationCard(svc.notifications[i], svc),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'Aucune notification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Vous recevrez ici les notifications importantes.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, NotificationService svc) {
    final isRead = notif['is_read'] == 1;
    final type = notif['type'] as String? ?? 'info';
    final color = _getColor(type);
    final icon = _getIcon(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : color.withValues(alpha: 0.3),
          width: isRead ? 1 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!isRead) {
              svc.markAsRead(notif['id'] as String);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif['title'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif['message'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(notif['created_at']?.toString()),
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}