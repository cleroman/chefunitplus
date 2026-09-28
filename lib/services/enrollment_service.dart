// =============================================================
// ChefUnitPlus - EnrollmentService
// =============================================================

import 'package:flutter/foundation.dart';

import '../models/enrollment.dart';
import 'api_client.dart';

class EnrollmentService extends ChangeNotifier {
  final ApiClient _api;

  EnrollmentService(this._api);

  List<Enrollment> _myEnrollments = [];
  List<Enrollment> _pendingPayments = [];
  bool _loading = false;
  String? _error;

  List<Enrollment> get myEnrollments => _myEnrollments;
  List<Enrollment> get pendingPayments => _pendingPayments;
  bool get loading => _loading;
  String? get error => _error;

  // ============================================================
  // MES ENROLLMENTS
  // ============================================================
  Future<List<Enrollment>> loadMyEnrollments() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/enrollments/me');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          _myEnrollments = data
              .map((e) => Enrollment.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return _myEnrollments;
    } catch (e) {
      _error = e.toString();
      debugPrint('[EnrollmentService] loadMyEnrollments error: $e');
      return [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // PAIEMENTS EN ATTENTE
  // ============================================================
  Future<List<Enrollment>> loadPending() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get('/enrollments/pending');
      if (res['success'] == true) {
        final data = res['data'] as List?;
        if (data != null) {
          _pendingPayments = data
              .map((e) => Enrollment.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return _pendingPayments;
    } catch (e) {
      _error = e.toString();
      debugPrint('[EnrollmentService] loadPending error: $e');
      return [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DEMANDER UNE INSCRIPTION (flexible: positionnel ou nomme)
  // ============================================================
  Future<Map<String, dynamic>> request(
    dynamic formationIdOrMap, {
    String? phone,
    String? accountName,
  }) async {
    String formationId;
    String? finalPhone = phone;
    String? finalAccountName = accountName;

    if (formationIdOrMap is Map) {
      formationId = formationIdOrMap['formationId']?.toString() ?? '';
      finalPhone ??= formationIdOrMap['phone']?.toString();
      finalAccountName ??= formationIdOrMap['accountName']?.toString();
    } else {
      formationId = formationIdOrMap?.toString() ?? '';
    }

    try {
      final res = await _api.post('/enrollments/request', body: {
        'formation_id': formationId,
        'phone': finalPhone ?? '',
        'account_name': finalAccountName ?? '',
      });
      return res;
    } catch (e) {
      debugPrint('[EnrollmentService] request error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============================================================
  // CONFIRMER OTP (flexible)
  // ============================================================
  Future<Map<String, dynamic>> confirmOtp(
    dynamic enrollmentIdOrMap, [
    String? otpPositional,
  ]) async {
    String enrollmentId;
    String otp;

    if (enrollmentIdOrMap is Map) {
      enrollmentId = enrollmentIdOrMap['enrollmentId']?.toString() ?? '';
      otp = enrollmentIdOrMap['otp']?.toString() ?? '';
    } else {
      enrollmentId = enrollmentIdOrMap?.toString() ?? '';
      otp = otpPositional ?? '';
    }

    try {
      final res = await _api.post('/enrollments/confirm-otp', body: {
        'enrollment_id': enrollmentId,
        'otp': otp,
      });
      return res;
    } catch (e) {
      debugPrint('[EnrollmentService] confirmOtp error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============================================================
  // VALIDER (accepte otp + comment)
  // ============================================================
  Future<bool> validate(
    String enrollmentId, {
    String? comment,
    String? otp,
  }) async {
    try {
      final res = await _api.patch('/enrollments/$enrollmentId/validate', body: {
        if (comment != null && comment.isNotEmpty) 'director_comment': comment,
        if (otp != null && otp.isNotEmpty) 'director_otp': otp,
      });
      if (res['success'] == true) {
        await loadPending();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[EnrollmentService] validate error: $e');
      return false;
    }
  }

  // ============================================================
  // REJETER (accepte comment ET reason)
  // ============================================================
  Future<bool> reject(
    String enrollmentId, {
    String? reason,
    String? comment,
  }) async {
    final text = comment ?? reason ?? '';
    try {
      final res = await _api.patch('/enrollments/$enrollmentId/reject', body: {
        if (text.isNotEmpty) 'director_comment': text,
      });
      if (res['success'] == true) {
        await loadPending();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[EnrollmentService] reject error: $e');
      return false;
    }
  }

  // ============================================================
  // RECU
  // ============================================================
  Future<Map<String, dynamic>> getReceipt(String enrollmentId) async {
    try {
      final res = await _api.get('/enrollments/$enrollmentId/receipt');
      return res;
    } catch (e) {
      debugPrint('[EnrollmentService] getReceipt error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}