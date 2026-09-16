// =============================================================
// ChefUnitPlus - Gestionnaire global d'erreurs
// Convertit toute exception en message utilisateur propre
// =============================================================


import 'dart:io';

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  // ===========================================================
  // 🎯 CONVERSION PRINCIPALE
  // ===========================================================
  /// Convertit n'importe quelle exception en AppException normalisee
  static AppException normalize(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    // Erreurs reseau
    if (error is SocketException) {
      return AppException.network(error);
    }
    if (error is TimeoutException) {
      return AppException.timeout(error);
    }
    if (error is HttpException) {
      return AppException.network(error);
    }

    // Erreurs de format
    if (error is FormatException) {
      return AppException.validation('Format de donnees invalide');
    }

    // Fallback
    return AppException.unknown(error.toString(), error);
  }

  // ===========================================================
  // 📝 MESSAGE UTILISATEUR
  // ===========================================================
  static String message(Object error) {
    return normalize(error).message;
  }

  // ===========================================================
  // 🌐 GESTION DES CODES HTTP
  // ===========================================================
  static AppException fromHttpCode(int statusCode, [String? body]) {
    switch (statusCode) {
      case 400:
        return AppException.validation(body ?? 'Requete invalide');
      case 401:
        return AppException.unauthorized();
      case 403:
        return AppException.forbidden();
      case 404:
        return AppException.notFound();
      case 422:
        return AppException.validation(body ?? 'Donnees invalides');
      case 429:
        return AppException(
          message: 'Trop de requetes. Patientez un instant.',
          type: AppExceptionType.server,
          code: 429,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return AppException.server(body);
      default:
        if (statusCode >= 500) {
          return AppException.server(body);
        }
        return AppException.unknown(body);
    }
  }

  // ===========================================================
  // 🎁 MESSAGE COURT POUR SNACKBAR
  // ===========================================================
  static String shortMessage(Object error) {
    final full = message(error);
    if (full.length <= 100) return full;
    return '${full.substring(0, 97)}...';
  }

  // ===========================================================
  // 🔍 ANALYSE
  // ===========================================================
  static bool isRecoverable(Object error) {
    final e = normalize(error);
    return e.canRetry;
  }

  static bool requiresLogin(Object error) {
    return normalize(error).isAuth;
  }

  static bool isValidationError(Object error) {
    return normalize(error).isValidation;
  }

  // ===========================================================
  // 📊 LOGGING
  // ===========================================================
  /// Log structure en console (debug uniquement)
  /// Pour brancher un service de crash reporting (Sentry,
  /// Crashlytics, etc.), implementer cette methode.
  static void log(Object error, [StackTrace? stackTrace, String? context]) {
    if (kReleaseMode) {
      // En production, le log est ignore par defaut.
      // Brancher ici un service de crash reporting si necessaire.
      return;
    }

    final e = normalize(error);
    debugPrint('--------------------------------------------');
    debugPrint('ERROR${context != null ? ' [$context]' : ''}');
    debugPrint('   Type   : ${e.type.name}');
    debugPrint('   Code   : ${e.code ?? 'N/A'}');
    debugPrint('   Message: ${e.message}');
    if (e.details != null) {
      debugPrint('   Details: ${e.details}');
    }
    if (stackTrace != null) {
      debugPrint(
        '   Stack  : ${stackTrace.toString().split('\n').take(3).join('\n')}',
      );
    }
    debugPrint('--------------------------------------------');
  }

  // ===========================================================
  // 🛠️ WRAPPER ASYNC
  // ===========================================================
  /// Enveloppe une operation async pour capturer et normaliser les erreurs
  static Future<T> guard<T>(
    Future<T> Function() operation, {
    String? context,
  }) async {
    try {
      return await operation();
    } catch (e, st) {
      log(e, st, context);
      throw normalize(e, st);
    }
  }

  // ===========================================================
  // 🧪 GESTION GLOBALE FLUTTER
  // ===========================================================
  /// A appeler dans main() pour capturer les erreurs globales
  static void installGlobalHandler() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      log(details.exception, details.stack, 'FlutterError');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      log(error, stack, 'UncaughtAsync');
      return true;
    };
  }
}