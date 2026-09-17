// =============================================================
// ChefUnitPlus - User Service
// CRUD complet pour les utilisateurs
// =============================================================
import '../core/errors/error_handler.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  // ============================================================
  // LIST : tous les utilisateurs
  // ============================================================
  Future<List<User>> list({bool refresh = false}) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/users');
      final d = r['data'] ?? r;
      if (d is List) {
        return d
            .map((e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    }, context: 'UserService.list');
  }

  // ============================================================
  // READ : un utilisateur par ID
  // ============================================================
  Future<User> getById(String id) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/users/$id');
      final d = r['data'] ?? r;
      return User.fromJson(Map<String, dynamic>.from(d as Map));
    }, context: 'UserService.getById');
  }

  // ============================================================
  // CREATE : nouveau utilisateur
  // ============================================================
  Future<User> create({
    required String email,
    required String fullName,
    required String password,
    required String role,
    String? phone,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post('/users', body: {
        'email': email,
        'full_name': fullName,
        'password': password,
        'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      final d = r['data'] ?? r;
      return User.fromJson(Map<String, dynamic>.from(d as Map));
    }, context: 'UserService.create');
  }

  // ============================================================
  // UPDATE : modifier un utilisateur
  // ============================================================
  Future<User> update({
    required String id,
    String? fullName,
    String? phone,
    String? role,
  }) async {
    return ErrorHandler.guard(() async {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (phone != null) body['phone'] = phone;
      if (role != null) body['role'] = role;

      final r = await _api.patch('/users/$id', body: body);
      final d = r['data'] ?? r;
      return User.fromJson(Map<String, dynamic>.from(d as Map));
    }, context: 'UserService.update');
  }

  // ============================================================
  // DELETE : supprimer un utilisateur
  // ============================================================
  Future<void> delete(String id) async {
    return ErrorHandler.guard(() async {
      await _api.delete('/users/$id');
    }, context: 'UserService.delete');
  }

  // ============================================================
  // PROMOTE : promouvoir (apprenant -> formateur -> directeur)
  // ============================================================
  Future<User> promote(String id, String newRole) async {
    return ErrorHandler.guard(() async {
      final r = await _api.patch('/users/$id/promote', body: {'role': newRole});
      final d = r['data'] ?? r;
      return User.fromJson(Map<String, dynamic>.from(d as Map));
    }, context: 'UserService.promote');
  }

  // ============================================================
  // SUSPEND : suspendre un compte
  // ============================================================
  Future<void> suspend(String id) async {
    return ErrorHandler.guard(() async {
      await _api.patch('/users/$id/suspend');
    }, context: 'UserService.suspend');
  }

  // ============================================================
  // REACTIVATE : reactiver un compte
  // ============================================================
  Future<void> reactivate(String id) async {
    return ErrorHandler.guard(() async {
      await _api.patch('/users/$id/reactivate');
    }, context: 'UserService.reactivate');
  }

  // ============================================================
  // RESET MOT DE PASSE
  // ============================================================
  Future<void> resetPassword(String id) async {
    return ErrorHandler.guard(() async {
      await _api.patch('/users/$id/reset-password');
    }, context: 'UserService.resetPassword');
  }

  // ============================================================
  // GET FULL PROFILE (user + details)
  // ============================================================
  Future<Map<String, dynamic>> getFullProfile(String id) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/users/$id/full-profile');
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'UserService.getFullProfile');
  }
}