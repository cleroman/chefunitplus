// =============================================================
// ChefUnitPlus - User Activation Service
// Gere l'activation / desactivation des comptes utilisateurs
// =============================================================
import '../core/errors/error_handler.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserActivationService {
  final ApiClient _api;

  UserActivationService(this._api);

  // ============================================================
  // LISTER LES UTILISATEURS EN ATTENTE D'ACTIVATION
  // ============================================================
  Future<List<User>> listPending() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/auth/pending-users');
      final d = r['data'] ?? r;
      if (d is List) {
        return d
            .map((e) => User.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    }, context: 'UserActivationService.listPending');
  }

  // ============================================================
  // ACTIVER UN UTILISATEUR
  // ============================================================
  Future<void> activate(String userId) async {
    return ErrorHandler.guard(() async {
      await _api.patch('/auth/activate/$userId');
    }, context: 'UserActivationService.activate');
  }

  // ============================================================
  // DESACTIVER UN UTILISATEUR
  // ============================================================
  Future<void> deactivate(String userId) async {
    return ErrorHandler.guard(() async {
      await _api.patch('/auth/deactivate/$userId');
    }, context: 'UserActivationService.deactivate');
  }
}