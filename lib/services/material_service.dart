// =============================================================
// ChefUnitPlus - MaterialService
// Gere les PDF/Videos de formation
// =============================================================

import '../core/errors/error_handler.dart';
import 'api_client.dart';

class MaterialService {
  final ApiClient _api;

  MaterialService(this._api);

  /// Materiaux d'une formation
  Future<List<Map<String, dynamic>>> listFormationMaterials(String formationId) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/materials/formation/$formationId');
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'MaterialService.listFormationMaterials');
  }

  /// Materiaux d'un module
  Future<List<Map<String, dynamic>>> listModuleMaterials(String moduleId) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/materials/module/$moduleId');
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'MaterialService.listModuleMaterials');
  }

  /// Modules disponibles par date
  Future<List<Map<String, dynamic>>> listAvailableModules(String formationId) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/materials/formation/$formationId/modules');
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'MaterialService.listAvailableModules');
  }
}