// =============================================================
// ChefUnitPlus - Statistiques par rôle
// Dashboard Admin / Directeur / Formateur
// =============================================================

import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import 'api_client.dart';


class StatsService {
  final ApiClient api;

  StatsService(this.api);

  // ===========================================================
  // ðŸŒ GLOBAL (admin)
  // ===========================================================
  /// Retourne un ensemble clé/valeur :
  /// { usersCount, formationsCount, paymentsCount, revenue, ... }
  Future<Map<String, dynamic>> fetchGlobal() async {
    return ErrorHandler.guard(() async {
      final data = await api.get(ApiConstants.statsGlobal);
      return data['stats'] as Map<String, dynamic>? ?? const {};
    }, context: 'StatsService.fetchGlobal');
  }

  // ===========================================================
  // ðŸŽ¬ DIRECTEUR
  // ===========================================================
  Future<Map<String, dynamic>> fetchDirector() async {
    return ErrorHandler.guard(() async {
      final data = await api.get(ApiConstants.statsDirector);
      return data['stats'] as Map<String, dynamic>? ?? const {};
    }, context: 'StatsService.fetchDirector');
  }

  // ===========================================================
  // ðŸ‘¨â€ðŸ« FORMATEUR
  // ===========================================================
  Future<Map<String, dynamic>> fetchTrainer() async {
    return ErrorHandler.guard(() async {
      final data = await api.get(ApiConstants.statsTrainer);
      return data['stats'] as Map<String, dynamic>? ?? const {};
    }, context: 'StatsService.fetchTrainer');
  }

  // ===========================================================
  // ðŸŽ“ APPRENANT
  // ===========================================================
  Future<Map<String, dynamic>> fetchLearner() async {
    return ErrorHandler.guard(() async {
      final data = await api.get('${ApiConstants.statsGlobal}/me');
      return data['stats'] as Map<String, dynamic>? ?? const {};
    }, context: 'StatsService.fetchLearner');
  }
}