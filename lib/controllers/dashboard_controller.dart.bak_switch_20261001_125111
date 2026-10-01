// =============================================================
// ChefUnitPlus - DashboardController
// Statistiques par rle (admin, directeur, formateur, apprenant)
// =============================================================

import 'package:flutter/foundation.dart';

import '../core/constants/role_constants.dart';
import '../core/errors/error_handler.dart';
import '../services/stats_service.dart';


class DashboardController extends ChangeNotifier {
  final StatsService _service;

  DashboardController(this._service);

  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _errorMessage;
  UserRole? _lastRoleLoaded;

  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRole? get lastRoleLoaded => _lastRoleLoaded;

  // ===========================================================
  // YZ CHARGEMENT SELON LE R"LE
  // ===========================================================
  Future<void> loadForRole(UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    _lastRoleLoaded = role;
    notifyListeners();

    try {
      switch (role) {
        case UserRole.admin:
          _stats = await _service.fetchGlobal();
          break;
        case UserRole.directeur:
          _stats = await _service.fetchDirector();
          break;
        case UserRole.formateur:
          _stats = await _service.fetchTrainer();
          break;
        case UserRole.apprenant:
          _stats = await _service.fetchLearner();
          break;
      }
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'DashboardController.loadForRole');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // Y" REFRESH
  // ===========================================================
  Future<void> refresh() async {
    if (_lastRoleLoaded != null) {
      await loadForRole(_lastRoleLoaded!);
    }
  }

  // ===========================================================
  // Y HELPERS
  // ===========================================================
  /// Lecture type avec valeur par dfaut
  T value<T>(String key, T fallback) {
    final v = _stats[key];
    if (v is T) return v;
    if (v is num && fallback is double) return v.toDouble() as T;
    if (v is num && fallback is int) return v.toInt() as T;
    if (v is String && fallback is String) return v as T;
    return fallback;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}