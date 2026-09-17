import '../core/errors/error_handler.dart';
import '../models/scout_group.dart';
import 'api_client.dart';

class ScoutGroupService {
  final ApiClient _api;
  ScoutGroupService(this._api);

  // ============================================================
  // LISTE PUBLIQUE (pour inscription - pas d'auth requise)
  // ============================================================
  Future<List<ScoutGroup>> listPublic() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/scout-groups/public');
      final d = r['data'] ?? r;
      if (d is List) {
        return d
            .map((e) => ScoutGroup.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    }, context: 'ScoutGroupService.listPublic');
  }

  // ============================================================
  // LISTE COMPLETE (admin / directeur)
  // ============================================================
  Future<List<ScoutGroup>> listAll() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/scout-groups');
      final d = r['data'] ?? r;
      if (d is List) {
        return d
            .map((e) => ScoutGroup.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    }, context: 'ScoutGroupService.listAll');
  }

  // ============================================================
  // CREER
  // ============================================================
  Future<ScoutGroup> create({
    required String name,
    String? region,
    String? district,
    String? description,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post('/scout-groups', body: {
        'name': name,
        if (region != null) 'region': region,
        if (district != null) 'district': district,
        if (description != null) 'description': description,
      });
      final d = r['data'] ?? r;
      return ScoutGroup.fromJson(Map<String, dynamic>.from(d as Map));
    }, context: 'ScoutGroupService.create');
  }

  // ============================================================
  // MODIFIER
  // ============================================================
  Future<void> update({
    required String id,
    String? name,
    String? region,
    String? district,
    String? description,
    bool? isActive,
  }) async {
    return ErrorHandler.guard(() async {
      await _api.patch('/scout-groups/$id', body: {
        if (name != null) 'name': name,
        if (region != null) 'region': region,
        if (district != null) 'district': district,
        if (description != null) 'description': description,
        if (isActive != null) 'is_active': isActive ? 1 : 0,
      });
    }, context: 'ScoutGroupService.update');
  }

  // ============================================================
  // SUPPRIMER
  // ============================================================
  Future<void> delete(String id) async {
    return ErrorHandler.guard(() async {
      await _api.delete('/scout-groups/$id');
    }, context: 'ScoutGroupService.delete');
  }
}