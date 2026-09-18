import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import 'api_client.dart';

class RegisterService {
  final ApiClient _api;
  RegisterService(this._api);

  // ============================================================
  // INSCRIPTION STANDARD (paramÃ¨tres individuels)
  // ============================================================
  Future<Map<String, dynamic>> register({
    String? nom,
    String? postNom,
    String? prenom,
    String? sexe,
    String? dateNaissance,
    String? lieuNaissance,
    String? numeroAffiliation,
    String? association,
    String? branche,
    String? dateEntreeScout,
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? scoutGroupId,
    String? customGroupName,
    String? region,
    String? district,
    String? scoutFunction,
    Uint8List? photoBytes,
    String? photoFileName,
    String? bio,
    bool acceptedTerms = true,
  }) async {
    return ErrorHandler.guard(() async {
      final uri = Uri.parse('${ApiConstants.baseUrl}/auth/register-scout');
      final req = http.MultipartRequest('POST', uri);

      req.fields['fullName'] = fullName;
      if (nom != null) req.fields['nom'] = nom;
      if (postNom != null) req.fields['postNom'] = postNom;
      if (prenom != null) req.fields['prenom'] = prenom;
      if (sexe != null) req.fields['sexe'] = sexe;
      if (dateNaissance != null) req.fields['dateNaissance'] = dateNaissance;
      if (lieuNaissance != null) req.fields['lieuNaissance'] = lieuNaissance;
      if (numeroAffiliation != null) req.fields['numeroAffiliation'] = numeroAffiliation;
      if (association != null) req.fields['association'] = association;
      if (branche != null) req.fields['branche'] = branche;
      if (dateEntreeScout != null) req.fields['dateEntreeScout'] = dateEntreeScout;
      req.fields['email'] = email;
      req.fields['password'] = password;
      req.fields['phone'] = phone;
      req.fields['role'] = role;
      if (scoutGroupId != null) req.fields['scoutGroupId'] = scoutGroupId;
      if (customGroupName != null && customGroupName.isNotEmpty) req.fields['customGroupName'] = customGroupName;
      if (region != null) req.fields['region'] = region;
      if (district != null) req.fields['district'] = district;
      if (scoutFunction != null) req.fields['scoutFunction'] = scoutFunction;
      if (bio != null && bio.isNotEmpty) req.fields['bio'] = bio;
      req.fields['acceptedTerms'] = acceptedTerms.toString();

      if (photoBytes != null && photoBytes.isNotEmpty) {
        req.files.add(http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: photoFileName ?? 'photo.jpg',
        ));
      }

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode >= 400) {
        throw Exception('Erreur ${res.statusCode} : ${res.body}');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    }, context: 'RegisterService.register');
  }

  // ============================================================
  // INSCRIPTION COMPLETE (payload JSON - pour le wizard)
  // ============================================================
  Future<Map<String, dynamic>> registerComplete({
    required Map<String, dynamic> payload,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post('/auth/register-scout', body: payload);
      return r;
    }, context: 'RegisterService.registerComplete');
  }

  // ============================================================
  // LISTER LES GROUPES SCOUTS
  // ============================================================
  Future<List<Map<String, dynamic>>> listScoutGroups() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/scout-groups/public');
      final d = r['data'] ?? r;
      if (d is List) return d.cast<Map<String, dynamic>>();
      return [];
    }, context: 'RegisterService.listScoutGroups');
  }

  // ============================================================
  // VERIFICATION EMAIL
  // ============================================================
  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post(
        '/auth/verify-email',
        body: {'email': email, 'code': code},
      );
      return r['success'] == true;
    }, context: 'RegisterService.verifyEmail');
  }

  Future<bool> resendVerificationCode(String email) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post(
        '/auth/resend-verification',
        body: {'email': email},
      );
      return r['success'] == true;
    }, context: 'RegisterService.resendVerificationCode');
  }
}


