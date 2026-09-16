import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';
import '../models/enrollment.dart';
import '../services/enrollment_service.dart';

class EnrollmentController extends ChangeNotifier {
  final EnrollmentService _service;

  EnrollmentController(this._service);

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  List<Enrollment> _mine = [];
  List<Enrollment> get mine => _mine;

  List<Enrollment> _pending = [];
  List<Enrollment> get pending => _pending;

  List<Enrollment> get approved =>
      _mine.where((e) => e.status == EnrollmentStatus.approved).toList();

  List<Enrollment> get awaiting =>
      _mine.where((e) => e.status == EnrollmentStatus.pendingDirector).toList();

  List<Enrollment> get pendingPayment =>
      _mine.where((e) => e.status == EnrollmentStatus.pendingPayment).toList();

  // Charger mes inscriptions
  Future<void> loadMine({bool refresh = false}) async {
    if (!refresh && _loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _mine = await _service.myEnrollments();
    } on AppException catch (e) {
      _error = e.message;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'EnrollmentController.loadMine');
    }

    _loading = false;
    notifyListeners();
  }

  // Charger pending (directeur)
  Future<void> loadPending({bool refresh = false}) async {
    if (!refresh && _loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pending = await _service.pendingForDirector();
    } on AppException catch (e) {
      _error = e.message;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'EnrollmentController.loadPending');
    }

    _loading = false;
    notifyListeners();
  }

  // Creer une inscription
  Future<Enrollment?> request(
    String formationId, {
    required String phone,
    required String accountName,
  }) async {
    _error = null;
    try {
      final enrollment = await _service.request(
        formationId,
        phone: phone,
        accountName: accountName,
      );
      await loadMine(refresh: true);
      return enrollment;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'EnrollmentController.request');
      return null;
    }
  }

  // Confirmer OTP apprenant
  Future<bool> confirmOtp(String enrollmentId, String otp) async {
    _error = null;
    try {
      await _service.confirmOtp(enrollmentId, otp);
      await loadMine(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'EnrollmentController.confirmOtp');
      return false;
    }
  }

  // Valider (directeur) avec OTP
  Future<bool> validate(
    String id, {
    String? otp,
    String? comment,
    String? reason,
  }) async {
    _error = null;
    try {
      await _service.validate(id, otp: otp ?? '', comment: comment ?? reason);
      await loadPending(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'EnrollmentController.validate');
      return false;
    }
  }

  // Refuser (directeur)
  Future<bool> reject(String id, {String? comment, String? reason}) async {
    _error = null;
    try {
      await _service.reject(id, comment: comment ?? reason);
      await loadPending(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'EnrollmentController.reject');
      return false;
    }
  }

  // Recu (avec QR data)
  Future<Map<String, dynamic>?> getReceipt(String enrollmentId) async {
    try {
      return await _service.getReceipt(enrollmentId);
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'EnrollmentController.getReceipt');
      return null;
    }
  }

  void reset() {
    _mine = [];
    _pending = [];
    _error = null;
    _loading = false;
    notifyListeners();
  }
}