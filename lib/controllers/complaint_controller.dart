// =============================================================
// ChefUnitPlus - ComplaintController (complet)
// =============================================================

import 'package:flutter/foundation.dart';

import 'package:chefunitplus/core/errors/error_handler.dart';
import 'package:chefunitplus/models/complaint.dart';
import 'package:chefunitplus/services/complaint_service.dart';

class ComplaintController extends ChangeNotifier {

  Future<void> load() => loadAll();
  final ComplaintService _service;

  ComplaintController(this._service);

  List<Complaint> _complaints = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ===========================================================
  // GETTERS
  // ===========================================================
  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get count => _complaints.length;
  int get openCount =>
      _complaints.where((c) => c.isOpen).length;
  int get pendingCount =>
      _complaints.where((c) => c.isPending).length;
  int get resolvedCount =>
      _complaints.where((c) => c.isResolved).length;
  bool get isEmpty => _complaints.isEmpty;
  bool get isNotEmpty => _complaints.isNotEmpty;

  // ===========================================================
  // CHARGEMENT
  // ===========================================================
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _complaints = await _service.listAll();
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ComplaintController.loadAll');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // CREATION
  // ===========================================================
  Future<bool> create({
    required String subject,
    required String description,
    ComplaintPriority priority = ComplaintPriority.normal,
  }) async {
    try {
      final created = await _service.create(
        subject: subject,
        description: description,
        priority: priority,
      );
      _complaints.insert(0, created);
      notifyListeners();
      return true;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ComplaintController.create');
      return false;
    }
  }

  // ===========================================================
  // REPONDRE (change le statut + ajoute une reponse)
  // ===========================================================
  Future<bool> respond({
    required String id,
    required String response,
    ComplaintStatus status = ComplaintStatus.resolved,
  }) async {
    return updateStatus(
      id: id,
      status: status,
      response: response,
    );
  }

  // ===========================================================
  // MISE A JOUR STATUT
  // ===========================================================
  Future<bool> updateStatus({
    required String id,
    required ComplaintStatus status,
    String? response,
  }) async {
    try {
      final updated = await _service.updateStatus(
        id: id,
        status: status,
        response: response,
      );
      final i = _complaints.indexWhere((c) => c.id == id);
      if (i >= 0) _complaints[i] = updated;
      notifyListeners();
      return true;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ComplaintController.updateStatus');
      return false;
    }
  }

  // ===========================================================
  // SUPPRESSION
  // ===========================================================
  Future<bool> delete(String id) async {
    try {
      await _service.delete(id);
      _complaints.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'ComplaintController.delete');
      return false;
    }
  }

  // ===========================================================
  // RECHERCHE
  // ===========================================================
  List<Complaint> search(String query) {
    if (query.trim().isEmpty) return _complaints;
    final q = query.toLowerCase();
    return _complaints
        .where((c) =>
            c.subject.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            c.userName.toLowerCase().contains(q))
        .toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}