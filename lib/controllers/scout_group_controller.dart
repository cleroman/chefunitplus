import 'package:flutter/foundation.dart';
import '../core/errors/error_handler.dart';
import '../models/scout_group.dart';
import '../services/scout_group_service.dart';

class ScoutGroupController extends ChangeNotifier {
  final ScoutGroupService _service;
  ScoutGroupController(this._service);

  // =========================================================
  // ETAT
  // =========================================================
  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  // =========================================================
  // GROUPES PUBLICS (pour inscription)
  // =========================================================
  List<ScoutGroup> _publicGroups = [];
  List<ScoutGroup> get publicGroups => _publicGroups;

  Future<void> loadPublic() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _publicGroups = await _service.listPublic();
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.loadPublic');
    }

    _loading = false;
    notifyListeners();
  }

  // =========================================================
  // TOUS LES GROUPES (admin / directeur)
  // =========================================================
  List<ScoutGroup> _groups = [];
  List<ScoutGroup> get groups => _groups;

  Future<void> loadAll({bool refresh = false}) async {
    if (!refresh && _loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await _service.listAll();
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.loadAll');
    }

    _loading = false;
    notifyListeners();
  }

  // =========================================================
  // CREER
  // =========================================================
  Future<bool> create({
    required String name,
    String? region,
    String? district,
    String? description,
  }) async {
    _error = null;
    try {
      await _service.create(
        name: name,
        region: region,
        district: district,
        description: description,
      );
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.create');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // MODIFIER
  // =========================================================
  Future<bool> update({
    required String id,
    String? name,
    String? region,
    String? district,
    String? description,
    bool? isActive,
  }) async {
    _error = null;
    try {
      await _service.update(
        id: id,
        name: name,
        region: region,
        district: district,
        description: description,
        isActive: isActive,
      );
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.update');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // SUPPRIMER
  // =========================================================
  Future<bool> delete(String id) async {
    _error = null;
    try {
      await _service.delete(id);
      _groups = _groups.where((g) => g.id != id).toList();
      notifyListeners();
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ScoutGroupController.delete');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // RESET
  // =========================================================
  void reset() {
    _publicGroups = [];
    _groups = [];
    _error = null;
    _loading = false;
    notifyListeners();
  }
}