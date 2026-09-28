// =============================================================
// ChefUnitPlus - EnrollmentController
// =============================================================

import 'package:flutter/foundation.dart';

import '../models/enrollment.dart';
import '../services/enrollment_service.dart';

class EnrollmentController extends ChangeNotifier {
  final EnrollmentService _service;

  EnrollmentController(this._service);

  List<Enrollment> _mine = [];
  List<Enrollment> _pending = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastEnrollment;

  List<Enrollment> get mine => _mine;
  List<Enrollment> get pending => _pending;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastEnrollment => _lastEnrollment;

  List<Enrollment> get approved => _mine.where((e) => e.isApproved).toList();
  List<Enrollment> get awaiting => _mine.where((e) => e.isAwaiting).toList();

  // ============================================================
  // CHARGER MES ENROLLMENTS
  // ============================================================
  Future<void> loadMine({bool refresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mine = await _service.loadMyEnrollments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CHARGER LES PAIEMENTS EN ATTENTE
  // ============================================================
  Future<void> loadPending({bool refresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pending = await _service.loadPending();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DEMANDER INSCRIPTION (flexible)
  // ============================================================
  Future<Enrollment?> request(
    dynamic formationIdOrMap, {
    String? phone,
    String? accountName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _service.request(
        formationIdOrMap,
        phone: phone,
        accountName: accountName,
      );
      if (res['success'] == true) {
        final data = res['data'];
        if (data is Map) {
          final enrollment = Enrollment.fromMap(Map<String, dynamic>.from(data));
          _lastEnrollment = enrollment.toMap();
          return enrollment;
        }
      }
      _errorMessage = res['message'] as String? ?? 'Erreur';
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CONFIRMER OTP (flexible)
  // ============================================================
  Future<bool> confirmOtp(
    dynamic enrollmentIdOrMap, [
    String? otpPositional,
  ]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _service.confirmOtp(
        enrollmentIdOrMap,
        otpPositional,
      );
      if (res['success'] == true) return true;
      _errorMessage = res['message'] as String? ?? 'Erreur';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // VALIDER
  // ============================================================
  Future<bool> validate(
    String enrollmentId, {
    String? comment,
    String? otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ok = await _service.validate(enrollmentId, comment: comment, otp: otp);
      if (ok) await loadPending();
      return ok;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // REJETER
  // ============================================================
  Future<bool> reject(
    String enrollmentId, {
    String? reason,
    String? comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ok = await _service.reject(enrollmentId, reason: reason, comment: comment);
      if (ok) await loadPending();
      return ok;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // RECU
  // ============================================================
  Future<Map<String, dynamic>?> getReceipt(String enrollmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _service.getReceipt(enrollmentId);
      if (res['success'] == true) {
        return Map<String, dynamic>.from(res['data'] ?? {});
      }
      _errorMessage = res['message'] as String? ?? 'Erreur';
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}