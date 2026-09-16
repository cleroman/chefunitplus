// =============================================================
// ChefUnitPlus - RegisterService
// Envoie le payload COMPLET (single payload)
// =============================================================

import 'package:flutter/foundation.dart';

import 'package:chefunitplus/core/constants/api_constants.dart';
import 'package:chefunitplus/core/errors/error_handler.dart';
import 'package:chefunitplus/models/auth_response.dart';
import 'package:chefunitplus/services/api_client.dart';
import 'package:chefunitplus/services/storage_service.dart';

class RegisterService {
  final ApiClient api;
  final StorageService storage;

  RegisterService({required this.api, required this.storage});

  /// Inscription complete : recoit UN SEUL payload.
  Future<AuthResponse> registerComplete({
    required Map<String, dynamic> payload,
  }) async {
    return ErrorHandler.guard(() async {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════');
      debugPrint('📦 PAYLOAD ENVOYE AU BACKEND :');
      debugPrint(payload.toString());
      debugPrint('═══════════════════════════════════════════');

      final data = await api.post(
        ApiConstants.register,
        body: payload,
      );

      final response = AuthResponse.fromJson(data);

      if (response.success &&
          response.user != null &&
          response.token != null) {
        final user = response.user!.copyWith(token: response.token);
        await storage.saveUser(user);
        api.setToken(response.token);
      }

      return response;
    }, context: 'RegisterService.registerComplete');
  }
}