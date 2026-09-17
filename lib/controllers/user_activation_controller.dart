// =============================================================
// ChefUnitPlus - User Activation Controller
// Gere l'etat des utilisateurs en attente d'activation
// =============================================================
import 'package:flutter/foundation.dart';
import '../core/errors/error_handler.dart';
import '../models/user.dart';
import '../services/user_activation_service.dart';

class UserActivationController extends ChangeNotifier {
  final UserActivationService _service;

  UserActivationController(this._service);

  // =========================================================
  // ETAT
  // =========================================================
  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  List<User> _pendingUsers = [];
  List<User> get pendingUsers => _pendingUsers;

  int get pendingCount => _pendingUsers.length;

  // =========================================================
  // CHARGER LES UTILISATEURS EN ATTENTE
  // =========================================================
  Future<void> loadPending({bool refresh = false}) async {
    if (!refresh && _loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingUsers = await _service.listPending();
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserActivationController.loadPending');
    }

    _loading = false;
    notifyListeners();
  }

  // =========================================================
  // ACTIVER UN UTILISATEUR
  // =========================================================
  Future<bool> activate(String userId) async {
    _error = null;
    try {
      await _service.activate(userId);
      // Retirer de la liste pending
      _pendingUsers = _pendingUsers.where((u) => u.id != userId).toList();
      notifyListeners();
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserActivationController.activate');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // DESACTIVER UN UTILISATEUR
  // =========================================================
  Future<bool> deactivate(String userId) async {
    _error = null;
    try {
      await _service.deactivate(userId);
      await loadPending(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserActivationController.deactivate');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // RESET
  // =========================================================
  void reset() {
    _pendingUsers = [];
    _error = null;
    _loading = false;
    notifyListeners();
  }
}