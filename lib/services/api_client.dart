// =============================================================
// ChefUnitPlus - Client HTTP centralise
// Gere les headers, tokens, timeouts, erreurs normalisees
// =============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';

class ApiClient {
  final http.Client _client;
  String? _token;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // ===========================================================
  // GESTION DU TOKEN
  // ===========================================================
  void setToken(String? token) => _token = token;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  void clearToken() => _token = null;

  // ===========================================================
  // HEADERS
  // ===========================================================
  Map<String, String> get _headers => {
        ApiConstants.contentType: ApiConstants.applicationJson,
        'Accept': ApiConstants.applicationJson,
        if (_token != null)
          ApiConstants.authorization: '${ApiConstants.bearerPrefix}$_token',
      };

  // ===========================================================
  // METHODES HTTP
  // ===========================================================
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    return _request(() => _client.get(uri, headers: _headers));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path);
    return _request(() => _client.post(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path);
    return _request(() => _client.put(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path);
    return _request(() => _client.patch(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = _buildUri(path);
    return _request(() => _client.delete(uri, headers: _headers));
  }

  // ===========================================================
  // HELPERS INTERNES
  // ===========================================================
  Uri _buildUri(String path, [Map<String, String>? query]) {
    final fullPath = path.startsWith('http')
        ? path
        : '${ApiConstants.apiUrl}$path';
    final uri = Uri.parse(fullPath);
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...query,
    });
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(
        const Duration(seconds: ApiConstants.receiveTimeout),
      );

      // Corps vide (204, 205...)
      if (response.body.isEmpty) {
        if (response.statusCode < 400) {
          return {'success': true};
        }
        _logHttpError(response);
        throw ErrorHandler.fromHttpCode(response.statusCode);
      }

      // Decodage JSON
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw AppException.server('Reponse invalide du serveur');
      }

      // Succes
      if (response.statusCode < 400) {
        if (decoded is Map<String, dynamic>) return decoded;
        return {'success': true, 'data': decoded};
      }

      // ===========================================================
      // ERROR LOGGING — affiche le body complet AVANT le throw
      // ===========================================================
      _logHttpError(response, decoded);

      // Erreur HTTP : extraire le message
      final message = decoded is Map<String, dynamic>
          ? (decoded['message'] ?? decoded['error'])
          : null;
      throw ErrorHandler.fromHttpCode(response.statusCode, message);
    } on AppException {
      rethrow;
    } on TimeoutException catch (e, st) {
      ErrorHandler.log(e, st, 'ApiClient.timeout');
      throw AppException.timeout(e);
    } on SocketException catch (e, st) {
      ErrorHandler.log(e, st, 'ApiClient.socket');
      throw AppException.network(e);
    } on HttpException catch (e, st) {
      ErrorHandler.log(e, st, 'ApiClient.http');
      throw AppException.network(e);
    } catch (e, st) {
      ErrorHandler.log(e, st, 'ApiClient.unknown');
      throw ErrorHandler.normalize(e, st);
    }
  }

  // ===========================================================
  // LOGGING DES ERREURS HTTP
  // Affiche le body complet + détail des erreurs de validation
  // ===========================================================
  void _logHttpError(http.Response response, [dynamic decoded]) {
    // ignore: avoid_print
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    // ignore: avoid_print
    print('🚨 HTTP ERROR ${response.statusCode}');
    // ignore: avoid_print
    print('📥 BODY : ${response.body}');

    // Detail des erreurs (Laravel, Node, Django, etc.)
    if (decoded is Map<String, dynamic>) {
      final errors = decoded['errors'];
      if (errors != null) {
        // ignore: avoid_print
        print('📥 DETAILS DES ERREURS :');
        if (errors is Map) {
          errors.forEach((field, msgs) {
            // ignore: avoid_print
            print('   • $field : $msgs');
          });
        } else {
          // ignore: avoid_print
          print('   $errors');
        }
      }
    }
    // ignore: avoid_print
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // ===========================================================
  // LIBERATION
  // ===========================================================
  void dispose() => _client.close();
}