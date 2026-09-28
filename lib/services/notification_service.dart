// =============================================================
// ChefUnitPlus - NotificationService
// Gestion des notifications
// =============================================================

import 'package:flutter/foundation.dart';

import 'api_client.dart';

class NotificationService extends ChangeNotifier {
  final ApiClient _api;

  NotificationService(this._api);

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  String? get error => _error;

  // ============================================================
  // CHARGER MES NOTIFICATIONS
  // ============================================================
  Future<void> loadMy() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/notifications/my');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          _notifications = data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
        _unreadCount = res['unread_count'] as int? ?? 0;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[NotificationService] loadMy error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // MARQUER COMME LUE
  // ============================================================
  Future<void> markAsRead(String id) async {
    try {
      await _api.patch('/notifications/$id/read', body: {});
      await loadMy();
    } catch (e) {
      debugPrint('[NotificationService] markAsRead error: $e');
    }
  }

  // ============================================================
  // MARQUER TOUTES COMME LUES
  // ============================================================
  Future<void> markAllAsRead() async {
    try {
      await _api.patch('/notifications/read-all', body: {});
      await loadMy();
    } catch (e) {
      debugPrint('[NotificationService] markAllAsRead error: $e');
    }
  }

  // ============================================================
  // SUPPRIMER UNE NOTIFICATION
  // ============================================================
  Future<void> remove(String id) async {
    try {
      await _api.delete('/notifications/$id');
      await loadMy();
    } catch (e) {
      debugPrint('[NotificationService] remove error: $e');
    }
  }
}