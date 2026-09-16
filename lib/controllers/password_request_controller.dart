// ChefUnitPlus - Controleur PasswordRequest
import 'package:flutter/foundation.dart';
import '../core/errors/error_handler.dart';
import '../models/password_request.dart';
import '../services/password_request_service.dart';

class PasswordRequestController extends ChangeNotifier {
final PasswordRequestService _service;
  PasswordRequestController(this._service);

  List<PasswordRequest> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PasswordRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get pendingCount => _requests.where((r) => r.isPending).length;

  Future<void> loadPending() async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      _requests = await _service.listPending();
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'PasswordRequestController.loadPending');
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<bool> approve(String id, {required String newPassword}) async {
    try {
      await _service.approve(id, newPassword: newPassword);
      _requests.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.message(e);
      return false;
    }
  }

  Future<bool> reject(String id) async {
    try {
      await _service.reject(id);
      _requests.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.message(e);
      return false;
    }
  }

  // ============================================================
  // Charger les demandes de mot de passe (utilise par les vues)
  // ============================================================
  Future<void> load() async {
    try {
      notifyListeners();
    } catch (_) {
      // Silently ignore errors
    }
  }
}