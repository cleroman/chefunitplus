// =============================================================
// ChefUnitPlus - AuthController
// =============================================================

import 'package:flutter/foundation.dart';

import 'package:chefunitplus/core/errors/app_exception.dart';
import 'package:chefunitplus/core/errors/error_handler.dart';
import 'package:chefunitplus/models/auth_response.dart';
import 'package:chefunitplus/models/user.dart';
import 'package:chefunitplus/services/api_client.dart';
import 'package:chefunitplus/services/auth_service.dart';

enum AuthState {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthController extends ChangeNotifier {
  final AuthService _service;
  final ApiClient _api;

  AuthController({
    required AuthService service,
    required ApiClient api,
  })  : _service = service,
        _api = api;

  // ===========================================================
  // 🔍 ÉTAT
  // ===========================================================
  AuthState _state = AuthState.unknown;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // ===========================================================
  // 🚀 BOOTSTRAP
  // ===========================================================
  Future<void> bootstrap() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _service.restoreSession();
      if (user != null) {
        _currentUser = user;
        _api.setToken(user.token);
        _state = AuthState.authenticated;
      } else {
        _api.clearToken();
        _state = AuthState.unauthenticated;
      }
    } catch (e, st) {
      ErrorHandler.log(e, st, 'AuthController.bootstrap');
      _api.clearToken();
      _state = AuthState.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // 🔑 CONNEXION
  // ===========================================================
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.login(
        email: email,
        password: password,
      );
      return _handleAuthResponse(response);
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'AuthController.login');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // 📝 INSCRIPTION
  // ===========================================================
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      return _handleAuthResponse(response);
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'AuthController.register');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // 🚪 DÉCONNEXION
  // ===========================================================
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.logout();
    } finally {
      _api.clearToken();
      _currentUser = null;
      _state = AuthState.unauthenticated;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // 🔄 REFRESH
  // ===========================================================
  Future<void> refreshUser() async {
    try {
      final user = await _service.fetchMe();
      if (user != null) {
        _currentUser = user;
        _api.setToken(user.token);
        notifyListeners();
      }
    } catch (e, st) {
      ErrorHandler.log(e, st, 'AuthController.refreshUser');
    }
  }

  // ===========================================================
  // 🔐 MOT DE PASSE OUBLIÉ
  // ===========================================================
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.forgotPassword(email);
      return true;
    } catch (e) {
      _errorMessage = ErrorHandler.message(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================
  // 🧰 HELPERS
  // ===========================================================
  bool _handleAuthResponse(AuthResponse response) {
    if (response.success && response.user != null) {
      _currentUser = response.user;
      if (response.token != null) {
        _api.setToken(response.token);
      }
      _state = AuthState.authenticated;
      return true;
    }
    _errorMessage = response.message ?? 'Authentification échouée';
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
