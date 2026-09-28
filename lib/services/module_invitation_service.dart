// =============================================================
// ChefUnitPlus - ModuleInvitationService
// Gestion des invitations formateur
// =============================================================

import 'package:flutter/foundation.dart';

import 'api_client.dart';

class ModuleInvitationService extends ChangeNotifier {
  final ApiClient _api;

  ModuleInvitationService(this._api);

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  // ============================================================
  // INVITER UN FORMATEUR (directeur)
  // ============================================================
  Future<Map<String, dynamic>?> inviteTrainer({
    required String moduleId,
    required String trainerId,
    String? message,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.post('/modules/$moduleId/invite-trainer', body: {
        'trainer_id': trainerId,
        if (message != null) 'message': message,
      });

      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>?;
      }
      _error = res['message'] as String? ?? 'Erreur inconnue';
      return null;
    } catch (e) {
      _error = e.toString();
      debugPrint('[ModuleInvitationService] inviteTrainer error: $e');
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // MES INVITATIONS (formateur)
  // ============================================================
  Future<List<Map<String, dynamic>>> listMyInvitations() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/modules/invitations/my');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      _error = e.toString();
      debugPrint('[ModuleInvitationService] listMyInvitations error: $e');
      return [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ACCEPTER UNE INVITATION (formateur)
  // ============================================================
  Future<bool> acceptInvitation(String moduleId) async {
    try {
      final res = await _api.patch('/modules/$moduleId/accept-invitation', body: {});
      return res['success'] == true;
    } catch (e) {
      debugPrint('[ModuleInvitationService] acceptInvitation error: $e');
      return false;
    }
  }

  // ============================================================
  // REFUSER UNE INVITATION (formateur)
  // ============================================================
  Future<bool> declineInvitation(String moduleId) async {
    try {
      final res = await _api.patch('/modules/$moduleId/decline-invitation', body: {});
      return res['success'] == true;
    } catch (e) {
      debugPrint('[ModuleInvitationService] declineInvitation error: $e');
      return false;
    }
  }
}