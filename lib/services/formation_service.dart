import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/formation.dart';
import 'api_client.dart';


class FormationService {
  final ApiClient _api;
  FormationService(this._api);

  dynamic _data(Map<String, dynamic> r) => r['data'] ?? r['formation'];
  List<dynamic> _list(Map<String, dynamic> r) {
    final d = _data(r);
    if (d is List) return d;
    if (d is Map && d['formations'] is List) return d['formations'];
    return [];
  }

  Future<List<Formation>> list({bool all = false}) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get(
        ApiConstants.formations,
        query: all ? {'all': 'true'} : null,
      );
      return _list(r).map((e) => Formation.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }, context: 'FormationService.list');
  }

  Future<Formation> getById(String id) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get(ApiConstants.formationById.replaceAll('{id}', id));
      final d = _data(r);
      if (d is Map<String, dynamic>) return Formation.fromJson(d);
      return Formation.fromJson(r);
    }, context: 'FormationService.getById');
  }

  Future<List<Map<String, dynamic>>> listModules(String formationId) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get(
        ApiConstants.modulesByFormation.replaceAll('{id}', formationId),
      );
      final d = _data(r);
      if (d is List) return d.cast<Map<String, dynamic>>();
      return [];
    }, context: 'FormationService.listModules');
  }

  // ============================================================
  // CREER une formation (avec 2 PDFs optionnels - Web compatible)
  // ============================================================
  Future<Formation> create({
    required String title,
    required String description,
    required double price,
    FormationType type = FormationType.training,
    String? trainerId,
    DateTime? startDate,
    DateTime? endDate,
    int maxParticipants = 0,
    Uint8List? pdfBytes,
    String? pdfFileName,
    Uint8List? ficheBytes,
    String? ficheFileName,
  }) async {
    return ErrorHandler.guard(() async {
      final fields = <String, String>{
        'title': title,
        'description': description,
        'price': price.toString(),
        'type': type.value,
        if (trainerId != null) 'trainerId': trainerId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        'maxParticipants': maxParticipants.toString(),
      };

      final r = await _multipart(
        path: ApiConstants.formations,
        method: 'POST',
        fields: fields,
        pdfBytes: pdfBytes,
        pdfFileName: pdfFileName,
        ficheBytes: ficheBytes,
        ficheFileName: ficheFileName,
      );

      final d = _data(r);
      if (d is Map<String, dynamic>) return Formation.fromJson(d);
      return Formation.fromJson(r);
    }, context: 'FormationService.create');
  }

  // ============================================================
  // MODIFIER une formation
  // ============================================================
  Future<Formation> update({
    required String id,
    String? title,
    String? description,
    double? price,
    FormationType? type,
    String? trainerId,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    Uint8List? pdfBytes,
    String? pdfFileName,
    Uint8List? ficheBytes,
    String? ficheFileName,
  }) async {
    return ErrorHandler.guard(() async {
      final fields = <String, String>{};
      if (title != null) fields['title'] = title;
      if (description != null) fields['description'] = description;
      if (price != null) fields['price'] = price.toString();
      if (type != null) fields['type'] = type.value;
      if (trainerId != null) fields['trainerId'] = trainerId;
      if (startDate != null) fields['startDate'] = startDate.toIso8601String();
      if (endDate != null) fields['endDate'] = endDate.toIso8601String();
      if (maxParticipants != null) fields['maxParticipants'] = maxParticipants.toString();

      final r = await _multipart(
        path: '${ApiConstants.formations}/$id',
        method: 'PATCH',
        fields: fields,
        pdfBytes: pdfBytes,
        pdfFileName: pdfFileName,
        ficheBytes: ficheBytes,
        ficheFileName: ficheFileName,
      );

      final d = _data(r);
      if (d is Map<String, dynamic>) return Formation.fromJson(d);
      return Formation.fromJson(r);
    }, context: 'FormationService.update');
  }

  Future<void> delete(String id) async {
    return ErrorHandler.guard(() async {
      await _api.delete(ApiConstants.formationById.replaceAll('{id}', id));
    }, context: 'FormationService.delete');
  }

  String getPdfUrl(String formationId) =>
      '${ApiConstants.apiUrl}${ApiConstants.formations}/$formationId/pdf';

  String getFicheUrl(String formationId) =>
      '${ApiConstants.apiUrl}${ApiConstants.formations}/$formationId/fiche-technique';

  // ============================================================
  // PUBLIER / DEPUBLIER
  // ============================================================
  Future<void> publish(String id) async {
    return ErrorHandler.guard(() async {
      await _api.patch(
        '${ApiConstants.formations}/$id/publish',
      );
    }, context: 'FormationService.publish');
  }

  Future<void> unpublish(String id) async {
    return ErrorHandler.guard(() async {
      await _api.patch(
        '${ApiConstants.formations}/$id/unpublish',
      );
    }, context: 'FormationService.unpublish');
  }

  // ============================================================
  // MULTIPART (compatible Web + natif)
  // ============================================================
  Future<Map<String, dynamic>> _multipart({
    required String path,
    required String method,
    required Map<String, String> fields,
    Uint8List? pdfBytes,
    String? pdfFileName,
    Uint8List? ficheBytes,
    String? ficheFileName,
  }) async {
    final uri = Uri.parse('${ApiConstants.apiUrl}$path');
    final req = http.MultipartRequest(method, uri);

    final token = _api.token;
    if (token != null) {
      req.headers['Authorization'] = 'Bearer $token';
    }

    req.fields.addAll(fields);

    if (pdfBytes != null && pdfBytes.isNotEmpty) {
      req.files.add(http.MultipartFile.fromBytes(
        'pdf',
        pdfBytes,
        filename: pdfFileName ?? 'support.pdf',
        contentType: MediaType('application', 'pdf'),
      ));
    }

    if (ficheBytes != null && ficheBytes.isNotEmpty) {
      req.files.add(http.MultipartFile.fromBytes(
        'ficheTechnique',
        ficheBytes,
        filename: ficheFileName ?? 'fiche.pdf',
        contentType: MediaType('application', 'pdf'),
      ));
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode >= 400) {
      throw Exception('Erreur upload : ${res.statusCode} - ${res.body}');
    }
    if (res.body.isEmpty) {
      return <String, dynamic>{'success': true, 'data': null};
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}