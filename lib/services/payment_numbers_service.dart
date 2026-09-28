// =============================================================
// ChefUnitPlus - PaymentNumbersService
// Gere les numeros de reception Mobile Money
// =============================================================

import '../core/errors/error_handler.dart';
import 'api_client.dart';

class PaymentNumbersService {
  final ApiClient _api;

  PaymentNumbersService(this._api);

  // ============================================================
  // LIST : tous les numeros (admin)
  // ============================================================
  Future<List<Map<String, dynamic>>> list() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/payment-numbers');
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'PaymentNumbersService.list');
  }

  // ============================================================
  // LIST ACTIVE : numeros actifs (public)
  // ============================================================
  Future<List<Map<String, dynamic>>> listActive() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/payment-numbers/active');
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'PaymentNumbersService.listActive');
  }

  // ============================================================
  // GET OPERATORS : liste des operateurs
  // ============================================================
  Future<List<Map<String, dynamic>>> getOperators() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/payment-numbers/operators');
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'PaymentNumbersService.getOperators');
  }

  // ============================================================
  // CREATE
  // ============================================================
  Future<Map<String, dynamic>> create({
    required String operator,
    required String displayName,
    required String phoneNumber,
    String? referenceFormat,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post('/payment-numbers', body: {
        'operator': operator,
        'display_name': displayName,
        'phone_number': phoneNumber,
        if (referenceFormat != null) 'reference_format': referenceFormat,
      });
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'PaymentNumbersService.create');
  }

  // ============================================================
  // UPDATE
  // ============================================================
  Future<Map<String, dynamic>> update({
    required String id,
    String? operator,
    String? displayName,
    String? phoneNumber,
    String? referenceFormat,
    bool? isActive,
  }) async {
    return ErrorHandler.guard(() async {
      final body = <String, dynamic>{};
      if (operator != null) body['operator'] = operator;
      if (displayName != null) body['display_name'] = displayName;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (referenceFormat != null) body['reference_format'] = referenceFormat;
      if (isActive != null) body['is_active'] = isActive;

      final r = await _api.patch('/payment-numbers/$id', body: body);
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'PaymentNumbersService.update');
  }

  // ============================================================
  // DELETE
  // ============================================================
  Future<void> delete(String id) async {
    return ErrorHandler.guard(() async {
      await _api.delete('/payment-numbers/$id');
    }, context: 'PaymentNumbersService.delete');
  }

  // ============================================================
  // VALIDATE REFERENCE
  // ============================================================
  Future<Map<String, dynamic>> validateReference({
    required String operator,
    required String referenceNumber,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post('/payment-numbers/validate-reference', body: {
        'operator': operator,
        'reference_number': referenceNumber,
      });
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'PaymentNumbersService.validateReference');
  }
}