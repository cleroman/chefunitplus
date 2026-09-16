// =============================================================
// ChefUnitPlus - ScoutGroupService
// =============================================================

import 'package:chefunitplus/core/errors/error_handler.dart';
import 'package:chefunitplus/models/scout_group.dart';
import 'package:chefunitplus/services/api_client.dart';

class ScoutGroupService {
  final ApiClient api;
  ScoutGroupService(this.api);

  // ===========================================================
  // HELPERS
  // ===========================================================
  dynamic _extractData(Map<String, dynamic> response) {
    return response['data'] ??
        response['group'] ??
        response['groups'] ??
        response['scoutGroups'];
  }

  Map<String, dynamic> _extractObject(Map<String, dynamic> response) {
    final data = _extractData(response);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Reponse invalide : objet attendu');
  }

  List<dynamic> _extractList(Map<String, dynamic> response) {
    final data = _extractData(response);
    if (data is List) return data;
    if (data is Map) {
      final list = data['groups'] ?? data['items'] ?? data['scoutGroups'];
      if (list is List) return list;
    }
    return [];
  }

  // ===========================================================
  // LISTE
  // ===========================================================
  Future<List<ScoutGroup>> listAll() async {
    return ErrorHandler.guard(() async {
      final response = await api.get('/scout-groups');
      final list = _extractList(response);
      return list
          .map((e) => ScoutGroup.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }, context: 'ScoutGroupService.listAll');
  }

  Future<ScoutGroup> getById(String id) async {
    return ErrorHandler.guard(() async {
      final response = await api.get('/scout-groups/$id');
      return ScoutGroup.fromJson(_extractObject(response));
    }, context: 'ScoutGroupService.getById');
  }

  // ===========================================================
  // CREATION
  // ===========================================================
  Future<ScoutGroup> create({
    required String name,
    String? description,
    String? province,
    String? ville,
    String? commune,
    String? quartier,
    String? district,
    String? region,
    String? association,
    String? branche,
    String? groupeScout,
    String? numeroAffiliation,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await api.post(
        '/scout-groups',
        body: {
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (region != null && region.isNotEmpty) 'region': region,
          if (district != null && district.isNotEmpty) 'district': district,
          if (province != null && province.isNotEmpty) 'province': province,
          if (ville != null && ville.isNotEmpty) 'ville': ville,
          if (commune != null && commune.isNotEmpty) 'commune': commune,
          if (quartier != null && quartier.isNotEmpty) 'quartier': quartier,
          if (association != null && association.isNotEmpty)
            'association': association,
          if (branche != null && branche.isNotEmpty) 'branche': branche,
          if (groupeScout != null && groupeScout.isNotEmpty)
            'groupeScout': groupeScout,
          if (numeroAffiliation != null && numeroAffiliation.isNotEmpty)
            'numeroAffiliation': numeroAffiliation,
        },
      );
      return ScoutGroup.fromJson(_extractObject(response));
    }, context: 'ScoutGroupService.create');
  }

  // ===========================================================
  // MISE A JOUR
  // ===========================================================
  Future<ScoutGroup> update({
    required String id,
    String? name,
    String? description,
    String? province,
    String? ville,
    String? commune,
    String? quartier,
    String? district,
    String? region,
    String? association,
    String? branche,
    String? groupeScout,
    String? numeroAffiliation,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await api.patch(
        '/scout-groups/$id',
        body: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (region != null) 'region': region,
          if (district != null) 'district': district,
          if (province != null) 'province': province,
          if (ville != null) 'ville': ville,
          if (commune != null) 'commune': commune,
          if (quartier != null) 'quartier': quartier,
          if (association != null) 'association': association,
          if (branche != null) 'branche': branche,
          if (groupeScout != null) 'groupeScout': groupeScout,
          if (numeroAffiliation != null)
            'numeroAffiliation': numeroAffiliation,
        },
      );
      return ScoutGroup.fromJson(_extractObject(response));
    }, context: 'ScoutGroupService.update');
  }

  // ===========================================================
  // SUPPRESSION
  // ===========================================================
  Future<void> delete(String id) async {
    return ErrorHandler.guard(() async {
      await api.delete('/scout-groups/$id');
    }, context: 'ScoutGroupService.delete');
  }

  // ===========================================================
  // ASSIGNER DIRECTEUR
  // ===========================================================
  Future<ScoutGroup> assignDirector({
    required String groupId,
    required String directorId,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await api.patch(
        '/scout-groups/$groupId/assign-director',
        body: {'directorId': directorId},
      );
      return ScoutGroup.fromJson(_extractObject(response));
    }, context: 'ScoutGroupService.assignDirector');
  }
}