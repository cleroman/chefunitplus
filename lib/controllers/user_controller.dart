import 'package:flutter/foundation.dart';

import '../core/errors/error_handler.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserController extends ChangeNotifier {
  final UserService _service;

  UserController(this._service);

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  List<User> _users = [];
  List<User> get users => _users;

  // =========================================================
  // NORMALISATION role -> String
  // =========================================================
  String? _normalizeRole(dynamic role) {
    if (role == null) return null;
    if (role is String) return role;
    // UserRole enum -> .name
    try {
      return (role as dynamic).name as String;
    } catch (_) {
      return role.toString().split('.').last;
    }
  }

  // =========================================================
  // CHARGEMENT
  // =========================================================
  Future<void> loadAll({bool refresh = false, dynamic role}) async {
    if (!refresh && _loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final roleStr = _normalizeRole(role);
      _users = await _service.listAll(role: roleStr);
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.loadAll');
    }

    _loading = false;
    notifyListeners();
  }

  // =========================================================
  // DETAILS
  // =========================================================
  Future<Map<String, dynamic>?> getFullProfile(String userId) async {
    try {
      return await _service.getFullProfile(userId);
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'UserController.getFullProfile');
      return null;
    }
  }

  // =========================================================
  // PROMOTION - accepte String OU UserRole
  // =========================================================
  Future<bool> promote({
    dynamic userId,
    dynamic newRole,
    dynamic actorRole,
    dynamic id,
    dynamic role,
  }) async {
    final targetUserId = (userId ?? id)?.toString();
    final targetRole = _normalizeRole(newRole ?? role);

    if (targetUserId == null || targetRole == null) {
      _error = 'User ID ou role manquant';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.promote(targetUserId, targetRole);
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.promote');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // SUSPEND / REACTIVATE
  // =========================================================
  Future<bool> suspend(String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.suspend(userId);
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.suspend');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> reactivate(String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.reactivate(userId);
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.reactivate');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // MOT DE PASSE - accepte String OU nomme
  // =========================================================
  Future<bool> resetPassword({
    dynamic userId,
    dynamic newPassword,
    dynamic id,
    dynamic password,
  }) async {
    final targetUserId = (userId ?? id)?.toString();
    final targetPassword = (newPassword ?? password)?.toString();

    if (targetUserId == null || targetPassword == null) {
      _error = 'User ID ou mot de passe manquant';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.resetPassword(targetUserId, targetPassword);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.resetPassword');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // PROFIL
  // =========================================================
  Future<bool> updateProfile(
      String userId, Map<String, dynamic> payload) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateProfile(userId, payload);
      await loadAll(refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.updateProfile');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // SUPPRESSION
  // =========================================================
  Future<bool> delete(String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.delete(userId);
      _users = _users.where((u) => u.id != userId).toList();
      notifyListeners();
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'UserController.delete');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // FILTRES / STATS
  // =========================================================
  List<User> get apprenants =>
      _users.where((u) => u.role == UserRole.apprenant).toList();

  List<User> get formateurs =>
      _users.where((u) => u.role == UserRole.formateur).toList();

  List<User> get directeurs =>
      _users.where((u) => u.role == UserRole.directeur).toList();

  List<User> get admins =>
      _users.where((u) => u.role == UserRole.admin).toList();

  int get totalCount => _users.length;
  int get activeCount => _users.where((u) => u.isActive).length;
  int get inactiveCount => _users.where((u) => !u.isActive).length;
  int get adminCount => admins.length;
  int get directorCount => directeurs.length;
  int get trainerCount => formateurs.length;
  int get learnerCount => apprenants.length;

  // =========================================================
  // RESET
  // =========================================================
  void reset() {
    _users = [];
    _error = null;
    _loading = false;
    notifyListeners();
  }
}