import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';
import '../models/formation.dart';
import '../services/formation_service.dart';

enum LoadState { idle, loading, success, error }

class FormationController extends ChangeNotifier {
  final FormationService _service;

  FormationController(this._service);

  // =========================================================
  // ETAT
  // =========================================================
  LoadState _state = LoadState.idle;
  LoadState get state => _state;

  List<Formation> _formations = [];
  List<Formation> get formations => _formations;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  bool get isLoading => _state == LoadState.loading;
  bool get hasError => _state == LoadState.error;
  bool get hasData => _formations.isNotEmpty;

  String _search = '';
  String get search => _search;

  // =========================================================
  // CHARGEMENT
  // =========================================================
  Future<void> load({bool refresh = false, bool all = false}) async {
    if (!refresh && _state == LoadState.loading) return;

    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _formations = await _service.list(all: all);
      _state = LoadState.success;
    } on AppException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      _state = LoadState.error;
      ErrorHandler.log(e, st, 'FormationController.load');
    }

    notifyListeners();
  }

  Future<void> loadMine({bool refresh = false}) => load(refresh: refresh);

  // =========================================================
  // RECHERCHE
  // =========================================================
  Future<void> setSearch(String query) async {
    _search = query;
    await load(refresh: true);
  }

  // =========================================================
  // CREATE
  // =========================================================
  Future<bool> create({
    required String title,
    required String description,
    required double price,
    required FormationType type,
    String? trainerId,
    DateTime? startDate,
    DateTime? endDate,
    int maxParticipants = 0,
    String? pdfFilePath,
    String? ficheFilePath,
  }) async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      await _service.create(
        title: title,
        description: description,
        price: price,
        type: type,
        trainerId: trainerId,
        startDate: startDate,
        endDate: endDate,
        maxParticipants: maxParticipants,
        pdfFilePath: pdfFilePath,
        ficheFilePath: ficheFilePath,
      );
      await load(refresh: true);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'FormationController.create');
      return false;
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================
  Future<bool> update({
    required String id,
    String? title,
    String? description,
    double? price,
    FormationType? type,
    String? trainerId,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    String? pdfFilePath,
    String? ficheFilePath,
  }) async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      await _service.update(
        id: id,
        title: title,
        description: description,
        price: price,
        type: type,
        trainerId: trainerId,
        startDate: startDate,
        endDate: endDate,
        maxParticipants: maxParticipants,
        pdfFilePath: pdfFilePath,
        ficheFilePath: ficheFilePath,
      );
      await load(refresh: true);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'FormationController.update');
      return false;
    }
  }

  // =========================================================
  // DELETE
  // =========================================================
  Future<bool> delete(String id) async {
    try {
      await _service.delete(id);
      _formations = _formations.where((f) => f.id != id).toList();
      notifyListeners();
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'FormationController.delete');
      return false;
    }
  }

  // =========================================================
  // DETAILS / MODULES
  // =========================================================
  Future<Formation?> getById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e, st) {
      ErrorHandler.log(e, st, 'FormationController.getById');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> listModules(String formationId) async {
    try {
      return await _service.listModules(formationId);
    } catch (e, st) {
      ErrorHandler.log(e, st, 'FormationController.listModules');
      return [];
    }
  }

  // =========================================================
  // RESET
  // =========================================================
  // ============================================================
  // PUBLIER / DEPUBLIER
  // ============================================================
  Future<bool> publish(String id) async {
    _error = null;
    try {
      await _service.publish(id);
      await load(all: true, refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'FormationController.publish');
      return false;
    }
  }

  Future<bool> unpublish(String id) async {
    _error = null;
    try {
      await _service.unpublish(id);
      await load(all: true, refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'FormationController.unpublish');
      return false;
    }
  }

  void reset() {
    _state = LoadState.idle;
    _formations = [];
    _error = null;
    _search = '';
    notifyListeners();
  }
}