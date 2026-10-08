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
  // Ã°Å¸â€Â Ãƒâ€°TAT
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
  // Ã°Å¸Å¡â‚¬ BOOTSTRAP
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

        // Rafraichir depuis l'API pour avoir le statut a jour
        try {
          final fresh = await _service.fetchMe();
          if (fresh != null) {
            _currentUser = fresh;
            if (fresh.token != null) _api.setToken(fresh.token);
          }
        } catch (_) {
          // Si fetch echoue, garder le user local
        }
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
  // Ã°Å¸â€â€˜ CONNEXION
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
  // Ã°Å¸â€œÂ INSCRIPTION
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
  // VERIFICATION DU CODE D'INSCRIPTION
  // ===========================================================
  Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final result = await _service.verifyCode(
        email: email,
        code: code,
      );

      if (result['success'] == true) {
        await bootstrap();
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur : ${e.toString()}',
      };
    }
  }

  // ===========================================================
  // RENVOYER LE CODE D'INSCRIPTION
  // ===========================================================
  Future<Map<String, dynamic>> resendCode({
    required String email,
  }) async {
    try {
      return await _service.resendCode(email: email);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur : ${e.toString()}',
      };
    }
  }

  // ===========================================================
  // Ã°Å¸Å¡Âª DÃƒâ€°CONNEXION
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
  // Ã°Å¸â€â€ž REFRESH
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
  // Ã°Å¸â€Â MOT DE PASSE OUBLIÃƒâ€°
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
  // Ã°Å¸Â§Â° HELPERS
  // ===========================================================
  // ===========================================================
  // WIZARD - Statut d'inscription
  // ===========================================================
  /// Compte actif ET valide -> peut utiliser l'app normalement
  /// Compte actif ET valide -> peut utiliser l'app normalement
  bool get canUseApp {
    final u = _currentUser;
    if (u == null) return false;
    // Compte valide explicitement
    if (u.validatedAt != null) return true;
    if (u.statut == 'validated') return true;
    if (u.statut == 'active') return true;
    // is_active = 1 ET role admin/directeur/formateur (comptes systeme)
    if (u.isActive &&
        (u.role.name == 'admin' ||
         u.role.name == 'directeur' ||
         u.role.name == 'formateur')) {
      return true;
    }
    return false;
  }

  /// Etape du wizard d'inscription
  /// Aligne sur les valeurs reelles du backend :
  ///   statut = 'pending'          -> inscription en cours
  ///   code_is_used = false        -> code a saisir
  ///   code_is_used = true         -> preuves a soumettre
  ///   proofs_submitted_at != null -> en attente validation admin
  ///   validated_at != null        -> compte actif
  /// Etape du wizard d'inscription
  String get registrationStage {
    final u = _currentUser;
    if (u == null) return 'none';

    // 0. LES COMPTES SYSTEME SONT TOUJOURS ACTIFS
    final role = u.role.name;
    if (role == 'admin' || role == 'directeur' || role == 'formateur') {
      return 'active';
    }

    // 1. Compte suspendu / revoque
    if (!u.isActive ||
        u.statut == 'revoked' ||
        u.statut == 'revoque' ||
        u.statut == 'suspended' ||
        u.statut == 'suspendu') {
      return 'suspended';
    }

    // 2. Compte valide par admin -> page utilisateur
    if (u.validatedAt != null) return 'active';
    if (u.statut == 'validated' || u.statut == 'active') return 'active';

    // 3. Preuves soumises -> attente validation admin
    if (u.proofsSubmittedAt != null) return 'awaiting_validation';
    if (u.statut == 'proofs_submitted') return 'awaiting_validation';

    // 4. Code verifie -> wizard preuves
    if (u.codeIsUsed == true) return 'proofs_pending';
    if (u.statut == 'proofs_pending') return 'proofs_pending';

    // 5. Fallback : code a 6 chiffres
    return 'email_verification';
  }
  bool _handleAuthResponse(AuthResponse response) {
    if (response.success && response.user != null) {
      _currentUser = response.user;
      if (response.token != null) {
        _api.setToken(response.token);
      }
      _state = AuthState.authenticated;
      return true;
    }
    _errorMessage = response.message ?? 'Authentification ÃƒÂ©chouÃƒÂ©e';
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================
  Future<bool> updateProfile({
    String? fullName,
    String? prenom,
    String? postNom,
    String? phone,
    String? sexe,
    DateTime? dateNaissance,
    String? lieuNaissance,
    String? adresse,
    String? totem,
    String? avatarUrl,
  }) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _service.updateProfile(
        fullName: fullName,
        prenom: prenom,
        postNom: postNom,
        phone: phone,
        sexe: sexe,
        dateNaissance: dateNaissance,
        lieuNaissance: lieuNaissance,
        adresse: adresse,
        totem: totem,
        avatarUrl: avatarUrl,
      );

      if (updated != null) {
        _currentUser = updated;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Echec de la mise a jour';
      return false;
    } catch (e, st) {
      _errorMessage = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'AuthController.updateProfile');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}



