// =============================================================
// ChefUnitPlus - MessageService
// =============================================================

import 'package:flutter/foundation.dart';

import 'api_client.dart';

class MessageService extends ChangeNotifier {
  final ApiClient _api;

  MessageService(this._api);

  List<Map<String, dynamic>> _myMessages = [];
  List<Map<String, dynamic>> _sentMessages = [];
  List<Map<String, dynamic>> _contacts = [];
  int _unreadCount = 0;
  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> get myMessages => _myMessages;
  List<Map<String, dynamic>> get sentMessages => _sentMessages;
  List<Map<String, dynamic>> get contacts => _contacts;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadMy() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/messages/my');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          _myMessages = data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
        _unreadCount = res['unread_count'] as int? ?? 0;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[MessageService] loadMy error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadSent() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/messages/sent');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          _sentMessages = data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadContacts() async {
    try {
      final res = await _api.get('/messages/contacts');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          _contacts = data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('[MessageService] loadContacts error: $e');
    }
  }

  Future<bool> send({
    required String receiverId,
    required String content,
    String? subject,
  }) async {
    try {
      final res = await _api.post('/messages', body: {
        'receiver_id': receiverId,
        'content': content,
        if (subject != null && subject.isNotEmpty) 'subject': subject,
      });
      if (res['success'] == true) {
        await loadMy();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[MessageService] send error: $e');
      return false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _api.patch('/messages/$id/read', body: {});
      await loadMy();
    } catch (e) {
      debugPrint('[MessageService] markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.patch('/messages/read-all', body: {});
      await loadMy();
    } catch (e) {
      debugPrint('[MessageService] markAllAsRead error: $e');
    }
  }

  Future<void> remove(String id) async {
    try {
      await _api.delete('/messages/$id');
      await loadMy();
    } catch (e) {
      debugPrint('[MessageService] remove error: $e');
    }
  }
}