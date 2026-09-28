// =============================================================
// ChefUnitPlus - AuthService
// Login / Register / Logout / Restauration de session
// =============================================================

import 'package:chefunitplus/core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:chefunitplus/core/errors/error_handler.dart';
import 'package:chefunitplus/models/auth_response.dart';
import 'package:chefunitplus/models/user.dart';
import 'package:chefunitplus/services/api_client.dart';
import 'package:chefunitplus/services/storage_service.dart';

class AuthService {
  final ApiClient api;
  final StorageService storage;

  AuthService({
    required this.api,
    required this.storage,
  });

  // ===========================================================
  // Ã°Å¸â€â€˜ CONNEXION
  // ===========================================================
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return ErrorHandler.guard(() async {
      final data = await api.post(
        ApiConstants.login,
        body: {
          'email': email.trim(),
          'password': password,
        },
      );

      final response = AuthResponse.fromJson(data);

      if (response.success && response.user != null && response.token != null) {
        final user = response.user!.copyWith(token: response.token);
        await storage.saveUser(user);
        api.setToken(response.token);
      }

      return response;
    }, context: 'AuthService.login');
  }

  // ===========================================================
  // Ã°Å¸â€œÂ INSCRIPTION
  // ===========================================================
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return ErrorHandler.guard(() async {
      final data = await api.post(
        ApiConstants.register,
        body: {
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
          'password': password,
        },
      );

      final response = AuthResponse.fromJson(data);

      if (response.success && response.user != null && response.token != null) {
        final user = response.user!.copyWith(token: response.token);
        await storage.saveUser(user);
        api.setToken(response.token);
      }

      return response;
    }, context: 'AuthService.register');
  }

  // ===========================================================
  // Ã°Å¸Å¡Âª DÃƒâ€°CONNEXION
  // ===========================================================
  Future<void> logout() async {
    try {
      if (api.isAuthenticated) {
        await api.post(ApiConstants.logout);
      }
    } catch (_) {
      // On ignore les erreurs rÃƒÂ©seau cÃƒÂ´tÃƒÂ© logout
    } finally {
      await storage.clearSession();
      api.clearToken();
    }
  }

  // ===========================================================
  // Ã°Å¸â€â€ž RESTAURATION DE SESSION
  // ===========================================================
  Future<User?> restoreSession() async {
    final user = await storage.getUser();
    if (user == null) return null;
    api.setToken(user.token);
    return user;
  }

  // ===========================================================
  // Ã°Å¸â€˜Â¤ PROFIL COURANT (refresh serveur)
  // ===========================================================
  Future<User?> fetchMe() async {
    return ErrorHandler.guard(() async {
      if (!api.isAuthenticated) return null;

      final data = await api.get(ApiConstants.me);
      final raw = data['user'] as Map<String, dynamic>?;
      if (raw == null) return null;

      final refreshed = User.fromJson({
        ...raw,
        'token': api.token,
      });
      await storage.saveUser(refreshed);
      return refreshed;
    }, context: 'AuthService.fetchMe');
  }

  // ===========================================================
  // Ã°Å¸â€Â MOT DE PASSE OUBLIÃƒâ€°
  // ===========================================================
  Future<void> forgotPassword(String email) async {
    return ErrorHandler.guard(() async {
      await api.post(
        ApiConstants.forgotPassword,
        body: {'email': email.trim()},
      );
    }, context: 'AuthService.forgotPassword');
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return ErrorHandler.guard(() async {
      await api.post(
        ApiConstants.resetPassword,
        body: {
          'token': token,
          'password': newPassword,
        },
      );
    }, context: 'AuthService.resetPassword');
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================
  Future<User?> updateProfile({
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
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName;
      if (prenom != null) body['prenom'] = prenom;
      if (postNom != null) body['postNom'] = postNom;
      if (phone != null) body['phone'] = phone;
      if (sexe != null) body['sexe'] = sexe;
      if (dateNaissance != null) {
        body['dateNaissance'] = dateNaissance.toIso8601String();
      }
      if (lieuNaissance != null) body['lieuNaissance'] = lieuNaissance;
      if (adresse != null) body['adresse'] = adresse;
      if (totem != null) body['totem'] = totem;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

      final res = await api.put('/users/me', body: body);

      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>?;
        if (data != null) {
          return User.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[AuthService] updateProfile error: $e');
      rethrow;
    }
  }
}