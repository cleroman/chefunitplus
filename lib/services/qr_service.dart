// =============================================================
// ChefUnitPlus - QrService
// Scan QR par formateur + modules disponibles
// =============================================================

import 'package:flutter/foundation.dart';

import 'api_client.dart';

class QrService extends ChangeNotifier {
  final ApiClient _api;

  QrService(this._api);

  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _myQrCodes = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get myQrCodes => _myQrCodes;

  // ============================================================
  // SCAN PAR FORMATEUR
  // ============================================================
  Future<Map<String, dynamic>?> scanByTrainer({
    required String code,
    required String moduleId,
    double? latitude,
    double? longitude,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.post('/qr/scan-by-trainer', body: {
        'code': code,
        'module_id': moduleId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });

      if (res['success'] == true) {
        return res['data'] as Map<String, dynamic>?;
      }
      _error = res['message'] as String? ?? 'Erreur inconnue';
      return null;
    } catch (e) {
      _error = e.toString();
      debugPrint('[QrService] scanByTrainer error: $e');
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // MODULES DISPONIBLES POUR SCAN
  // ============================================================
  Future<List<Map<String, dynamic>>> getAvailableForScan() async {
    try {
      final res = await _api.get('/modules/trainer/available-for-scan');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          return data.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('[QrService] getAvailableForScan error: $e');
      return [];
    }
  }

  // ============================================================
  // MES QR CODES (apprenant)
  // ============================================================
  Future<List<Map<String, dynamic>>> listMy() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/qr/my');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          _myQrCodes = data.map((e) => Map<String, dynamic>.from(e)).toList();
          return _myQrCodes;
        }
      }
      return [];
    } catch (e) {
      _error = e.toString();
      debugPrint('[QrService] listMy error: $e');
      return [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}