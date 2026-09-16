// =============================================================
// ChefUnitPlus - Exception applicative
// Modèle unifié pour toutes les erreurs de l'application
// =============================================================

import 'package:flutter/foundation.dart';

/// Types d'erreurs métier
enum AppExceptionType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unknown,
}

class AppException implements Exception {
  final String message;
  final AppExceptionType type;
  final int? code;
  final String? details;
  final Object? original;

  AppException({
    required this.message,
    this.type = AppExceptionType.unknown,
    this.code,
    this.details,
    this.original,
  });

  // ===========================================================
  // 🏭 CONSTRUCTEURS NOMMÉS
  // ===========================================================
  factory AppException.network([Object? original]) => AppException(
        message: 'Problème de connexion. Vérifiez votre réseau.',
        type: AppExceptionType.network,
        original: original,
      );

  factory AppException.timeout([Object? original]) => AppException(
        message: 'Le serveur met trop de temps à répondre.',
        type: AppExceptionType.timeout,
        original: original,
      );

  factory AppException.unauthorized([String? message]) => AppException(
        message: message ?? 'Session expirée. Veuillez vous reconnecter.',
        type: AppExceptionType.unauthorized,
        code: 401,
      );

  factory AppException.forbidden([String? message]) => AppException(
        message: message ?? 'Accès non autorisé.',
        type: AppExceptionType.forbidden,
        code: 403,
      );

  factory AppException.notFound([String? message]) => AppException(
        message: message ?? 'Ressource introuvable.',
        type: AppExceptionType.notFound,
        code: 404,
      );

  factory AppException.validation(String message) => AppException(
        message: message,
        type: AppExceptionType.validation,
        code: 422,
      );

  factory AppException.server([String? message, Object? original]) =>
      AppException(
        message: message ?? 'Erreur serveur. Réessayez plus tard.',
        type: AppExceptionType.server,
        code: 500,
        original: original,
      );

  factory AppException.unknown([String? message, Object? original]) =>
      AppException(
        message: message ?? 'Une erreur est survenue.',
        type: AppExceptionType.unknown,
        original: original,
      );

  // ===========================================================
  // 🏷️ HELPERS
  // ===========================================================
  bool get isNetwork => type == AppExceptionType.network;
  bool get isAuth => type == AppExceptionType.unauthorized;
  bool get isForbidden => type == AppExceptionType.forbidden;
  bool get isNotFound => type == AppExceptionType.notFound;
  bool get isValidation => type == AppExceptionType.validation;
  bool get isServer => type == AppExceptionType.server;

  /// Indique si l'utilisateur peut réessayer
  bool get canRetry =>
      type == AppExceptionType.network ||
      type == AppExceptionType.timeout ||
      type == AppExceptionType.server;

  // ===========================================================
  // 📤 SÉRIALISATION
  // ===========================================================
  Map<String, dynamic> toJson() => {
        'message': message,
        'type': type.name,
        'code': code,
        'details': details,
      };

  factory AppException.fromJson(Map<String, dynamic> json) => AppException(
        message: json['message'] ?? 'Erreur inconnue',
        type: AppExceptionType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => AppExceptionType.unknown,
        ),
        code: json['code'],
        details: json['details'],
      );

  // ===========================================================
  // 🧾 AFFICHAGE
  // ===========================================================
  @override
  String toString() {
    if (kReleaseMode) return message;
    final buffer = StringBuffer('AppException(${type.name}');
    if (code != null) buffer.write(', code: $code');
    buffer.write('): $message');
    if (details != null) buffer.write('\nDetails: $details');
    return buffer.toString();
  }
}