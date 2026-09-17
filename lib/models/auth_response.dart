// =============================================================
// ChefUnitPlus - AuthResponse
// =============================================================

import 'user.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final User? user;

  const AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.user,
  });

  // ===========================================================
  // FACTORY : parsing tolerant (data.user / data.token OU user / token)
  // ===========================================================
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Chercher d'abord dans json['data'] (format backend)
    // Puis fallback sur json directement
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    // --- User ---
    final rawUser = data['user'] as Map<String, dynamic>?;

    // --- Token ---
    final token = (data['token'] ?? json['token']) as String?;

    // --- Success ---
    final success = json['success'] == true ||
        data['success'] == true ||
        json['status'] == '0' ||
        json['status'] == 200;

    // --- Message ---
    final message = json['message'] ??
        json['error'] ??
        data['message'] ??
        data['error'];

    return AuthResponse(
      success: success,
      message: message,
      token: token,
      user: rawUser != null
          ? User.fromJson({
              ...rawUser,
              if (token != null) 'token': token,
            })
          : null,
    );
  }

  // ===========================================================
  // CONSTRUCTEURS RAPIDES
  // ===========================================================
  factory AuthResponse.failure(String message) =>
      AuthResponse(success: false, message: message);

  factory AuthResponse.success({
    required User user,
    required String token,
    String? message,
  }) =>
      AuthResponse(
        success: true,
        user: user,
        token: token,
        message: message ?? 'Connexion reussie',
      );

  // ===========================================================
  // GETTERS
  // ===========================================================
  bool get isFailure => !success;
  bool get hasUser => user != null;
  bool get hasToken => token != null && token!.isNotEmpty;
}