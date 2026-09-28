// =============================================================
// ChefUnitPlus - PaymentRequestService
// Gere les demandes de paiement Mobile Money
// =============================================================

import '../core/errors/error_handler.dart';
import 'api_client.dart';

class PaymentRequestService {
  final ApiClient _api;

  PaymentRequestService(this._api);

  /// Soumettre une demande de paiement
  Future<Map<String, dynamic>> create({
    required String paymentNumberId,
    required double amount,
    required String referenceNumber,
    required String senderName,
    required String senderPhone,
    String? formationId,
    String? enrollmentId,
    String currency = 'USD',
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post('/payment-requests', body: {
        'payment_number_id': paymentNumberId,
        'amount': amount,
        'currency': currency,
        'reference_number': referenceNumber,
        'sender_name': senderName,
        'sender_phone': senderPhone,
        if (formationId != null) 'formation_id': formationId,
        if (enrollmentId != null) 'enrollment_id': enrollmentId,
      });
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'PaymentRequestService.create');
  }

  /// Mes paiements (apprenant)
  Future<List<Map<String, dynamic>>> listMy() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/payment-requests/my');
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'PaymentRequestService.listMy');
  }

  /// Tous les paiements (admin/directeur)
  Future<List<Map<String, dynamic>>> list({String? status}) async {
    return ErrorHandler.guard(() async {
      final path = status != null
          ? '/payment-requests?status=$status'
          : '/payment-requests';
      final r = await _api.get(path);
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'PaymentRequestService.list');
  }

  /// Valider un paiement
  Future<Map<String, dynamic>> validate(String id) async {
    return ErrorHandler.guard(() async {
      final r = await _api.patch('/payment-requests/$id/validate');
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'PaymentRequestService.validate');
  }

  /// Refuser un paiement
  Future<Map<String, dynamic>> reject(String id, {String? reason}) async {
    return ErrorHandler.guard(() async {
      final r = await _api.patch('/payment-requests/$id/reject', body: {
        if (reason != null) 'reason': reason,
      });
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'PaymentRequestService.reject');
  }
}