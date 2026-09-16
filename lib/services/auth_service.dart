// =============================================================
// ChefUnitPlus - AuthService
// Login / Register / Logout / Restauration de session
// =============================================================

import 'package:chefunitplus/core/constants/api_constants.dart';
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
  // 🔑 CONNEXION
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
  // 📝 INSCRIPTION
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
  // 🚪 DÉCONNEXION
  // ===========================================================
  Future<void> logout() async {
    try {
      if (api.isAuthenticated) {
        await api.post(ApiConstants.logout);
      }
    } catch (_) {
      // On ignore les erreurs réseau côté logout
    } finally {
      await storage.clearSession();
      api.clearToken();
    }
  }

  // ===========================================================
  // 🔄 RESTAURATION DE SESSION
  // ===========================================================
  Future<User?> restoreSession() async {
    final user = await storage.getUser();
    if (user == null) return null;
    api.setToken(user.token);
    return user;
  }

  // ===========================================================
  // 👤 PROFIL COURANT (refresh serveur)
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
  // 🔐 MOT DE PASSE OUBLIÉ
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
}
