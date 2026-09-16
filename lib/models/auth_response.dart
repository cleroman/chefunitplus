// =============================================================
// ChefUnitPlus - Rponse d'authentification
// Renvoye par les endpoints /auth/login et /auth/register
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
  // Y FACTORIES
  // ===========================================================
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'] as Map<String, dynamic>?;
    final token = json['token'] as String?;

    return AuthResponse(
      success: json['success'] == true ||
          json['status'] == '0' ||
          json['status'] == 200,
      message: json['message'] ?? json['error'],
      token: token,
      user: rawUser != null
          ? User.fromJson({...rawUser, if (token != null) 'token': token})
          : null,
    );
  }

  // ===========================================================
  // YZ CONSTRUCTEURS RAPIDES
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
        message: message ?? 'Connexion russie',
      );

  // ===========================================================
  // Y" GETTERS
  // ===========================================================
  bool get isFailure => !success;
  bool get hasUser => user != null;
  bool get hasToken => token != null && token!.isNotEmpty;

  // ===========================================================
  // Y" S?RIALISATION
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'success': success,
        if (message != null) 'message': message,
        if (token != null) 'token': token,
        if (user != null) 'user': user!.toJson(),
      };

  @override
  String toString() =>
      'AuthResponse(success: $success, user: ${user?.email}, message: $message)';
}