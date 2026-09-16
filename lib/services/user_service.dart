import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  // =========================================================
  // LECTURE
  // =========================================================
  Future<List<User>> listAll({String? role}) async {
    try {
      final data = await _api.get(
        ApiConstants.users,
        query: role != null ? {'role': role} : null,
      );
      final list = data['users'] as List? ?? data['data'] as List? ?? [];
      return list
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      ErrorHandler.log(e, st, 'UserService.listAll');
      rethrow;
    }
  }

  Future<User> getById(String id) async {
    try {
      final data = await _api.get(
        ApiConstants.userProfile.replaceAll('{id}', id),
      );
      return User.fromJson(
        (data['user'] ?? data['data'] ?? data) as Map<String, dynamic>,
      );
    } catch (e, st) {
      ErrorHandler.log(e, st, 'UserService.getById');
      rethrow;
    }
  }

  /// Profil complet (user + details + emergency contacts)
  Future<Map<String, dynamic>> getFullProfile(String id) async {
    try {
      final data = await _api.get(
        '${ApiConstants.userProfile.replaceAll('{id}', id)}/full',
      );
      return data;
    } catch (e, st) {
      ErrorHandler.log(e, st, 'UserService.getFullProfile');
      // Fallback : essayer juste /users/:id
      try {
        final user = await getById(id);
        return {'user': user.toJson()};
      } catch (_) {
        rethrow;
      }
    }
  }

  // =========================================================
  // PROMOTION / SUSPENSION
  // =========================================================
  Future<User> promote(String userId, String newRole) async {
    try {
      final data = await _api.patch(
        ApiConstants.promoteUser.replaceAll('{id}', userId),
        body: {'role': newRole},
      );
      return User.fromJson(
        (data['user'] ?? data['data'] ?? data) as Map<String, dynamic>,
      );
    } catch (e, st) {
      ErrorHandler.log(e, st, 'UserService.promote');
      rethrow;
    }
  }

  Future<void> suspend(String userId) async {
    try {
      await _api.patch(
        ApiConstants.suspendUser.replaceAll('{id}', userId),
      );
    } catch (e, st) {
      ErrorHandler.log(e, st, 'UserService.suspend');
      rethrow;
    }
  }

  Future<void> reactivate(String userId) async {
    try {
      await _api.patch(
        '${ApiConstants.users}/$userId/reactivate',
      );
    } catch (e, st) {
      ErrorHandler.log(e, st, 'UserService.reactivate');
      rethrow;
    }
  }

  // =========================================================
  // MOT DE PASSE / PROFIL
  // =========================================================
  Future<void> resetPassword(String userId, String newPassword) async {
    try {
      await _api.patch(
        '${ApiConstants.users}/$userId/reset-password',
        body: {'password': newPassword},
      );
    } catch (e, st) {
      ErrorHandler.log(e, st, 'UserService.resetPassword');
      rethrow;
    }
  }

  Future<User> updateProfile(String userId, Map<String, dynamic> payload) async {
    try {
      final data = await _api.patch(
        ApiConstants.userProfile.replaceAll('{id}', userId),
        body: payload,
      );
      return User.fromJson(
        (data['user'] ?? data['data'] ?? data) as Map<String, dynamic>,
      );
    } catch (e, st) {
      ErrorHandler.log(e, st, 'UserService.updateProfile');
      rethrow;
    }
  }

  // =========================================================
  // SUPPRESSION
  // =========================================================
  Future<void> delete(String userId) async {
    try {
      await _api.delete(ApiConstants.userProfile.replaceAll('{id}', userId));
    } catch (e, st) {
      ErrorHandler.log(e, st, 'UserService.delete');
      rethrow;
    }
  }
}