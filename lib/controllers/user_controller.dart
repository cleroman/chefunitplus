// =============================================================
// ChefUnitPlus - User Controller
// CRUD complet pour les utilisateurs
// =============================================================
import 'package:flutter/foundation.dart';
import '../core/errors/error_handler.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../services/user_service.dart';

class UserController extends ChangeNotifier {
  final UserService _service;

  UserController(this._service);

  // =========================================================
  // ETAT
  // =========================================================
  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  List<User> _users = [];
  List<User> get users => _users;

  // Compteurs
  int get adminCount => _users.where((u) => u.role.name == 'admin').length;
  int get directeurCount => _users.where((u) => u.role.name == 'directeur').length;
  int get formateurCount => _users.where((u) => u.role.name == 'formateur').length;
  int get trainerCount => formateurCount;
  int get apprenantCount => _users.where((u) => u.role.name == 'apprenant').length;
  int get activeCount => _users.where((u) => u.isActive).length;
  int get inactiveCount => _users.where((u) => !u.isActive).length;

  // =========================================================
  // CHARGER TOUS LES UTILISATEURS
  // =========================================================
  Future<void> loadAll({bool refresh = false}) async {
    if (!refresh && _loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _service.list();
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.loadAll');
    }

    _loading = false;
    notifyListeners();
  }

  // =========================================================
  // CREER
  // =========================================================
  Future<bool> create({
    required String email,
    required String fullName,
    required String password,
    required String role,
    String? phone,
  }) async {
    _error = null;
    try {
      await _service.create(
        email: email,
        fullName: fullName,
        password: password,
        role: role,
        phone: phone,
      );
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.create');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // MODIFIER
  // =========================================================
  Future<bool> update({
    required String id,
    String? fullName,
    String? phone,
    String? role,
  }) async {
    _error = null;
    try {
      await _service.update(
        id: id,
        fullName: fullName,
        phone: phone,
        role: role,
      );
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.update');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // SUPPRIMER
  // =========================================================
  Future<bool> delete(String id) async {
    _error = null;
    try {
      await _service.delete(id);
      _users = _users.where((u) => u.id != id).toList();
      notifyListeners();
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.delete');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // SUSPENDRE
  // =========================================================
  Future<bool> suspend(String id) async {
    _error = null;
    try {
      await _service.suspend(id);
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.suspend');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // REACTIVER
  // =========================================================
  Future<bool> reactivate(String id) async {
    _error = null;
    try {
      await _service.reactivate(id);
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.reactivate');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // RESET
  // =========================================================
  void reset() {
    _users = [];
    _error = null;
    _loading = false;
    notifyListeners();
  }

  // =========================================================
  // PROMOUVOIR (signature compatible avec les ecrans existants)
  // =========================================================
  Future<bool> promote({
    required String userId,
    required UserRole newRole,
    UserRole? actorRole,
  }) async {
    _error = null;
    try {
      await _service.promote(userId, newRole.name);
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.promote');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // RESET MOT DE PASSE
  // =========================================================
  Future<bool> resetPassword(String userId) async {
    _error = null;
    try {
      await _service.resetPassword(userId);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.resetPassword');
      notifyListeners();
      return false;
    }
  }

  // =========================================================
  // UPDATE PROFIL (self-service)
  // =========================================================
  Future<bool> updateProfile({
    required String id,
    String? fullName,
    String? phone,
    String? bio,
  }) async {
    _error = null;
    try {
      await _service.update(
        id: id,
        fullName: fullName,
        phone: phone,
      );
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.updateProfile');
      notifyListeners();
      return false;
    }
  }
}