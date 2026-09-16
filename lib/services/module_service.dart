import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/module.dart';
import 'api_client.dart';

class ModuleService {
  final ApiClient _api;
  ModuleService(this._api);

  dynamic _data(Map<String, dynamic> r) => r['data'] ?? r['module'];
  List<dynamic> _list(Map<String, dynamic> r) {
    final d = _data(r);
    if (d is List) return d;
    if (r['modules'] is List) return r['modules'] as List;
    return [];
  }

  // ============================================================
  // LISTER par formation
  // ============================================================
  Future<List<Module>> listByFormation(
    String formationId, {
    bool onlyApproved = false,
  }) async {
    return ErrorHandler.guard(() async {
      final q = onlyApproved ? '?onlyApproved=true' : '';
      final r = await _api.get(
          '${ApiConstants.formations}/$formationId/modules$q');
      return _list(r)
          .map((e) => Module.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }, context: 'ModuleService.listByFormation');
  }

  // ============================================================
  // LISTER en attente
  // ============================================================
  Future<List<Module>> listPending() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('${ApiConstants.modules}/pending');
      return _list(r)
          .map((e) => Module.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }, context: 'ModuleService.listPending');
  }

  // ============================================================
  // LISTER mes modules (formateur)
  // ============================================================
  Future<List<Module>> listMyModules() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('${ApiConstants.modules}/mine');
      return _list(r)
          .map((e) => Module.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }, context: 'ModuleService.listMyModules');
  }

  // ============================================================
  // LISTER tous (admin)
  // ============================================================
  Future<List<Module>> listAll() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('${ApiConstants.modules}?all=true');
      return _list(r)
          .map((e) => Module.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }, context: 'ModuleService.listAll');
  }

  // ============================================================
  // CREER (compatible Web + natif)
  // ============================================================
  Future<Module> create({
    required String formationId,
    required String title,
    String? description,
    String? trainerId,
    int order = 0,
    int hours = 0,
    DateTime? startDate,
    DateTime? endDate,
    Uint8List? pdfBytes,
    String? pdfFileName,
  }) async {
    return ErrorHandler.guard(() async {
      final fields = <String, String>{
        'formationId': formationId,
        'title': title,
        if (description != null) 'description': description,
        if (trainerId != null) 'trainerId': trainerId,
        'order': order.toString(),
        'hours': hours.toString(),
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      final r = await _multipart(
        path: '${ApiConstants.modules}',
        method: 'POST',
        fields: fields,
        pdfBytes: pdfBytes,
        pdfFileName: pdfFileName,
      );
      final d = _data(r);
      if (d is Map<String, dynamic>) return Module.fromJson(d);
      return Module.fromJson(r);
    }, context: 'ModuleService.create');
  }

  // ============================================================
  // MODIFIER (compatible Web + natif)
  // ============================================================
  Future<Module> update({
    required String id,
    String? formationId,
    String? title,
    String? description,
    String? trainerId,
    int? order,
    int? hours,
    DateTime? startDate,
    DateTime? endDate,
    Uint8List? pdfBytes,
    String? pdfFileName,
  }) async {
    return ErrorHandler.guard(() async {
      final fields = <String, String>{};
      if (title != null) fields['title'] = title;
      if (description != null) fields['description'] = description;
      if (trainerId != null) fields['trainerId'] = trainerId;
      if (order != null) fields['order'] = order.toString();
      if (hours != null) fields['hours'] = hours.toString();
      if (startDate != null) fields['startDate'] = startDate.toIso8601String();
      if (endDate != null) fields['endDate'] = endDate.toIso8601String();

      final r = await _multipart(
        path: '${ApiConstants.modules}/$id',
        method: 'PATCH',
        fields: fields,
        pdfBytes: pdfBytes,
        pdfFileName: pdfFileName,
      );
      final d = _data(r);
      if (d is Map<String, dynamic>) return Module.fromJson(d);
      return Module.fromJson(r);
    }, context: 'ModuleService.update');
  }

  // ============================================================
  // SUPPRIMER
  // ============================================================
  Future<void> delete(String id) async {
    return ErrorHandler.guard(() async {
      await _api.delete('${ApiConstants.modules}/$id');
    }, context: 'ModuleService.delete');
  }

  // ============================================================
  // APPROUVER (directeur)
  // ============================================================
  Future<Module> approve({
    required String moduleId,
    required int hours,
    DateTime? startDate,
    DateTime? endDate,
    String? trainerId,
    String? formationId,
  }) async {
    return ErrorHandler.guard(() async {
      final body = <String, dynamic>{
        'hours': hours,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (trainerId != null) 'trainerId': trainerId,
        if (formationId != null) 'formationId': formationId,
      };
      final r = await _api.patch(
        '${ApiConstants.modules}/$moduleId/approve',
        body: body,
      );
      final d = _data(r);
      if (d is Map<String, dynamic>) return Module.fromJson(d);
      return Module.fromJson(r);
    }, context: 'ModuleService.approve');
  }

  // ============================================================
  // REFUSER (directeur)
  // ============================================================
  Future<Module> reject({
    required String moduleId,
    String? comment,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.patch(
        '${ApiConstants.modules}/$moduleId/reject',
        body: {
          if (comment != null) 'comment': comment,
          'reason': comment ?? '',
        },
      );
      final d = _data(r);
      if (d is Map<String, dynamic>) return Module.fromJson(d);
      return Module.fromJson(r);
    }, context: 'ModuleService.reject');
  }

  // ============================================================
  // HELPER multipart (Web + natif)
  // ============================================================
  Future<Map<String, dynamic>> _multipart({
    required String path,
    required String method,
    required Map<String, String> fields,
    Uint8List? pdfBytes,
    String? pdfFileName,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
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

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode >= 400) {
      throw Exception('Erreur ${res.statusCode} : ${res.body}');
    }
    if (res.body.isEmpty) {
      return <String, dynamic>{'success': true};
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}