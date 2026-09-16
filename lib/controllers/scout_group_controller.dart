// =============================================================
// ChefUnitPlus - ScoutGroupController (complet)
// =============================================================

import 'package:flutter/foundation.dart';

import 'package:chefunitplus/core/errors/error_handler.dart';
import 'package:chefunitplus/models/scout_group.dart';
import 'package:chefunitplus/services/scout_group_service.dart';

class ScoutGroupController extends ChangeNotifier {
  final ScoutGroupService _service;

  ScoutGroupController(this._service);

  List<ScoutGroup> _groups = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ===========================================================
  // GETTERS
  // ===========================================================
  List<ScoutGroup> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get count => _groups.length;
  bool get isEmpty => _groups.isEmpty;
  bool get isNotEmpty => _groups.isNotEmpty;

  // ===========================================================
  // CHARGEMENT
  // ===========================================================
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await _service.listAll();
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.loadAll');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // CREATION - TOUS les parametres acceptes
  // ===========================================================
  Future<bool> create({
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
    try {
      final created = await _service.create(
        name: name,
        description: description,
        province: province,
        ville: ville,
        commune: commune,
        quartier: quartier,
        district: district,
        region: region,
        association: association,
        branche: branche,
        groupeScout: groupeScout,
        numeroAffiliation: numeroAffiliation,
      );

      _groups.insert(0, created);
      notifyListeners();
      return true;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.create');
      return false;
    }
  }

  // ===========================================================
  // MISE A JOUR
  // ===========================================================
  Future<bool> update({
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
    try {
      final updated = await _service.update(
        id: id,
        name: name,
        description: description,
        province: province,
        ville: ville,
        commune: commune,
        quartier: quartier,
        district: district,
        region: region,
        association: association,
        branche: branche,
        groupeScout: groupeScout,
        numeroAffiliation: numeroAffiliation,
      );

      final index = _groups.indexWhere((g) => g.id == id);
      if (index >= 0) {
        _groups[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.update');
      return false;
    }
  }

  // ===========================================================
  // SUPPRESSION
  // ===========================================================
  Future<bool> delete(String id) async {
    try {
      await _service.delete(id);
      _groups.removeWhere((g) => g.id == id);
      notifyListeners();
      return true;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.delete');
      return false;
    }
  }

  // ===========================================================
  // ASSIGNER DIRECTEUR
  // ===========================================================
  Future<bool> assignDirector({
    required String groupId,
    required String directorId,
  }) async {
    try {
      final updated = await _service.assignDirector(
        groupId: groupId,
        directorId: directorId,
      );

      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index >= 0) {
        _groups[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.assignDirector');
      return false;
    }
  }

  // ===========================================================
  // RECHERCHE
  // ===========================================================
  List<ScoutGroup> search(String query) {
    if (query.trim().isEmpty) return _groups;
    final q = query.toLowerCase();
    return _groups
        .where((g) =>
            g.name.toLowerCase().contains(q) ||
            (g.district?.toLowerCase().contains(q) ?? false) ||
            (g.region?.toLowerCase().contains(q) ?? false) ||
            (g.ville?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}