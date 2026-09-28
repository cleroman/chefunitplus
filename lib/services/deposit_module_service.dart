// =============================================================
// ChefUnitPlus - DepositModuleService
// Gestion des depots de modules par les formateurs
// =============================================================

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

class DepositModuleService extends ChangeNotifier {
  final ApiClient _api;

  DepositModuleService(this._api);

  List<Map<String, dynamic>> _myDeposits = [];
  List<Map<String, dynamic>> _availableDeposits = [];
  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> get myDeposits => _myDeposits;
  List<Map<String, dynamic>> get availableDeposits => _availableDeposits;
  bool get loading => _loading;
  String? get error => _error;

  // ============================================================
  // DEPOSER UN MODULE (formateur)
  // ============================================================
  Future<Map<String, dynamic>?> deposit({
    required String title,
    String? description,
    int? hours,
    DateTime? startDate,
    DateTime? endDate,
    PlatformFile? pdfFile,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final fields = <String, String>{
        'title': title,
        if (description != null) 'description': description,
        if (hours != null) 'hours': hours.toString(),
        if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
      };

      final res = await _api.uploadFile(
        '/modules/deposit',
        pdfFile,
        fieldName: 'pdf',
        fields: fields,
      );

      if (res['success'] == true) {
        await loadMyDeposits();
        return res['data'] as Map<String, dynamic>?;
      }
      _error = res['message'] as String? ?? 'Erreur inconnue';
      return null;
    } catch (e) {
      _error = e.toString();
      debugPrint('[DepositModuleService] deposit error: $e');
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // MES DEPOTS (formateur)
  // ============================================================
  Future<void> loadMyDeposits() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/modules/deposits/my');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          _myDeposits = data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[DepositModuleService] loadMyDeposits error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DEPOTS DISPONIBLES (directeur)
  // ============================================================
  Future<void> loadAvailableDeposits() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/modules/deposits/available');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          _availableDeposits = data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[DepositModuleService] loadAvailableDeposits error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SUPPRIMER UN DEPOT (formateur)
  // ============================================================
  Future<bool> deleteDeposit(String depositId) async {
    try {
      final res = await _api.delete('/modules/deposits/$depositId');
      if (res['success'] == true) {
        await loadMyDeposits();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[DepositModuleService] deleteDeposit error: $e');
      return false;
    }
  }

  // ============================================================
  // ATTACHER UN DEPOT A UNE FORMATION (directeur)
  // ============================================================
  Future<Map<String, dynamic>?> attachToFormation({
    required String formationId,
    required String depositId,
    int? orderIndex,
  }) async {
    try {
      final res = await _api.post('/formations/$formationId/attach-deposit', body: {
        'deposit_id': depositId,
        if (orderIndex != null) 'order_index': orderIndex,
      });

      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>?;
      }
      _error = res['message'] as String? ?? 'Erreur';
      return null;
    } catch (e) {
      _error = e.toString();
      debugPrint('[DepositModuleService] attachToFormation error: $e');
      return null;
    }
  }
}