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
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chefunitplus/services/storage_service.dart';

class AuthService {
  final ApiClient api;
  final StorageService storage;

  AuthService({
    required this.api,
    required this.storage,
  });

  // ===========================================================
  // ÃƒÂ°Ã…Â¸Ã¢â‚¬ÂÃ¢â‚¬Ëœ CONNEXION
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
  // ÃƒÂ°Ã…Â¸Ã¢â‚¬Å“Ã‚Â INSCRIPTION
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
  // ÃƒÂ°Ã…Â¸Ã…Â¡Ã‚Âª DÃƒÆ’Ã¢â‚¬Â°CONNEXION
  // ===========================================================
  // ===========================================================
  // VERIFICATION CODE INSCRIPTION
  // ===========================================================
  Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    return ErrorHandler.guard(() async {
      return await api.post(
        ApiConstants.verifyCode,
        body: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
        },
      );
    }, context: 'AuthService.verifyCode');
  }

  // ===========================================================
  // RENVOYER LE CODE D'INSCRIPTION
  // ===========================================================
  Future<Map<String, dynamic>> resendCode({
    required String email,
  }) async {
    return ErrorHandler.guard(() async {
      return await api.post(
        ApiConstants.resendCode,
        body: {
          'email': email.trim().toLowerCase(),
        },
      );
    }, context: 'AuthService.resendCode');
  }

  // ===========================================================
  // SOUMISSION DES PREUVES (multipart, multi-fichiers)
  // proofs = [{title, filePath, fileName, bytes}]
  // ===========================================================
  Future<Map<String, dynamic>> submitProofs({
    required List<Map<String, dynamic>> proofs,
    int? buchettes,
  }) async {
    return ErrorHandler.guard(() async {
      if (proofs.isEmpty) {
        throw Exception('Aucune preuve a soumettre');
      }

      final uri = Uri.parse('${ApiConstants.apiUrl}${ApiConstants.submitProofs}');
      final req = http.MultipartRequest('POST', uri);

      // Token JWT
      final token = api.token;
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }

      // Chaque preuve = 1 fichier + titre dans fields
      for (var i = 0; i < proofs.length; i++) {
        final p = proofs[i];
        final bytes = p['bytes'] as List<int>?;
        final filePath = p['filePath'] as String?;
        final fileName = p['fileName'] as String? ?? 'proof_$i.pdf';
        final title = p['title'] as String? ?? 'Preuve ${i + 1}';

        req.fields['titles[$i]'] = title;

        if (bytes != null && bytes.isNotEmpty) {
          req.files.add(http.MultipartFile.fromBytes(
            'proofs',
            bytes,
            filename: fileName,
          ));
        } else if (filePath != null && filePath.isNotEmpty) {
          req.files.add(await http.MultipartFile.fromPath(
            'proofs',
            filePath,
            filename: fileName,
          ));
        }
      }

      // Ajouter les buchettes
      if (buchettes != null) {
        req.fields['buchettes'] = buchettes.toString();
      }

      final streamed = await req.send().timeout(
        const Duration(seconds: ApiConstants.receiveTimeout),
      );
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode >= 400) {
        throw Exception('Erreur ${res.statusCode} : ${res.body}');
      }

      if (res.body.isEmpty) return {'success': true};
      return jsonDecode(res.body) as Map<String, dynamic>;
    }, context: 'AuthService.submitProofs');
  }

  Future<void> logout() async {
    try {
      if (api.isAuthenticated) {
        await api.post(ApiConstants.logout);
      }
    } catch (_) {
      // On ignore les erreurs rÃƒÆ’Ã‚Â©seau cÃƒÆ’Ã‚Â´tÃƒÆ’Ã‚Â© logout
    } finally {
      await storage.clearSession();
      api.clearToken();
    }
  }

  // ===========================================================
  // ÃƒÂ°Ã…Â¸Ã¢â‚¬ÂÃ¢â‚¬Å¾ RESTAURATION DE SESSION
  // ===========================================================
  Future<User?> restoreSession() async {
    final user = await storage.getUser();
    if (user == null) return null;
    api.setToken(user.token);
    return user;
  }

  // ===========================================================
  // ÃƒÂ°Ã…Â¸Ã¢â‚¬ËœÃ‚Â¤ PROFIL COURANT (refresh serveur)
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
  // ÃƒÂ°Ã…Â¸Ã¢â‚¬ÂÃ‚Â MOT DE PASSE OUBLIÃƒÆ’Ã¢â‚¬Â°
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
