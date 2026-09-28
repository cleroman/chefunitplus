// =============================================================
// ChefUnitPlus - StatsService
// Consomme les endpoints /api/stats/*
// Retourne des Map<String, dynamic> pour DashboardController
// =============================================================

import 'package:flutter/foundation.dart';

import 'api_client.dart';

class StatsService extends ChangeNotifier {
  final ApiClient _api;

  StatsService(this._api);

  Map<String, dynamic> _stats = {};
  bool _loading = false;
  String? _error;

  Map<String, dynamic> get stats => _stats;
  bool get loading => _loading;
  String? get error => _error;

  // ============================================================
  // ADMIN / GLOBAL
  // ============================================================
  Future<Map<String, dynamic>> fetchGlobal() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/stats/global');
      if (res['success'] == true) {
        _stats = Map<String, dynamic>.from(res['data'] as Map);
        return _stats;
      } else {
        _error = res['error'] as String? ?? 'Erreur inconnue';
        return {};
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[StatsService] fetchGlobal error: $e');
      return {};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DIRECTEUR / ADMIN
  // ============================================================
  Future<Map<String, dynamic>> fetchDirector() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/stats/admin');
      if (res['success'] == true) {
        // Aplatir les groupes en un seul Map
        final data = res['data'] as Map<String, dynamic>;
        final flat = <String, dynamic>{};
        data.forEach((groupKey, groupValue) {
          if (groupValue is Map<String, dynamic>) {
            groupValue.forEach((k, v) {
              if (k != 'source') {
                flat['${groupKey}_$k'] = v;
              }
            });
            flat['${groupKey}_source'] = groupValue['source'] ?? groupKey;
          } else {
            flat[groupKey] = groupValue;
          }
        });
        _stats = flat;
        return _stats;
      } else {
        _error = res['error'] as String? ?? 'Erreur inconnue';
        return {};
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[StatsService] fetchDirector error: $e');
      return {};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // FORMATEUR
  // ============================================================
  Future<Map<String, dynamic>> fetchTrainer() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/stats/trainer');
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final flat = <String, dynamic>{};
        data.forEach((groupKey, groupValue) {
          if (groupValue is Map<String, dynamic>) {
            groupValue.forEach((k, v) {
              if (k != 'source') {
                flat['${groupKey}_$k'] = v;
              }
            });
            flat['${groupKey}_source'] = groupValue['source'] ?? groupKey;
          } else {
            flat[groupKey] = groupValue;
          }
        });
        _stats = flat;
        return _stats;
      } else {
        _error = res['error'] as String? ?? 'Erreur inconnue';
        return {};
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[StatsService] fetchTrainer error: $e');
      return {};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // APPRENANT
  // ============================================================
  Future<Map<String, dynamic>> fetchLearner() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/stats/learner');
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final flat = <String, dynamic>{};
        data.forEach((groupKey, groupValue) {
          if (groupValue is Map<String, dynamic>) {
            groupValue.forEach((k, v) {
              if (k != 'source') {
                flat['${groupKey}_$k'] = v;
              }
            });
            flat['${groupKey}_source'] = groupValue['source'] ?? groupKey;
          } else {
            flat[groupKey] = groupValue;
          }
        });
        _stats = flat;
        return _stats;
      } else {
        _error = res['error'] as String? ?? 'Erreur inconnue';
        return {};
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[StatsService] fetchLearner error: $e');
      return {};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // FORMATION SPECIFIQUE
  // ============================================================
  Future<Map<String, dynamic>> fetchFormation(String formationId) async {
    try {
      final res = await _api.get('/stats/formation/$formationId');
      if (res['success'] == true) {
        return Map<String, dynamic>.from(res['data'] as Map);
      }
    } catch (e) {
      debugPrint('[StatsService] fetchFormation error: $e');
    }
    return {};
  }
}