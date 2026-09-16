import 'dart:convert';
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
    return [];
  }

  List<Module> _toModules(Map<String, dynamic> r) =>
      _list(r).map((e) => Module.fromJson(Map<String, dynamic>.from(e as Map))).toList();

  // ============================================================
  // LISTES
  // ============================================================
  Future<List<Module>> listByFormation(String formationId,
      {bool onlyApproved = false}) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get(
        '${ApiConstants.modules}/by-formation/$formationId',
        query: onlyApproved ? {'onlyApproved': 'true'} : null,
      );
      return _toModules(r);
    }, context: 'ModuleService.listByFormation');
  }

  Future<List<Module>> listMyModules() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('${ApiConstants.modules}/my');
      return _toModules(r);
    }, context: 'ModuleService.listMyModules');
  }

  Future<List<Module>> listPending() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('${ApiConstants.modules}/pending');
      return _toModules(r);
    }, context: 'ModuleService.listPending');
  }

  Future<List<Module>> listAll() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('${ApiConstants.modules}/all');
      return _toModules(r);
    }, context: 'ModuleService.listAll');
  }

  // ============================================================
  // CREATION (formateur)
  // ============================================================
  Future<Module> create({
    required String formationId,
    required String title,
    String? description,
    String? pdfFilePath,
  }) async {
    return ErrorHandler.guard(() async {
      final fields = {
        'formationId': formationId,
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
      };

      final r = await _multipart(
        path: ApiConstants.modules,
        method: 'POST',
        fields: fields,
        pdfFilePath: pdfFilePath,
      );

      final d = _data(r);
      if (d is Map<String, dynamic>) return Module.fromJson(d);
      return Module.fromJson(r);
    }, context: 'ModuleService.create');
  }

  // ============================================================
  // MISE A JOUR (createur ou directeur)
  // ============================================================
  Future<Module> update({
    required String id,
    String? title,
    String? description,
    String? trainerId,
    int? order,
    int? hours,
    DateTime? startDate,
    DateTime? endDate,
    String? pdfFilePath,
  }) async {
    return ErrorHandler.guard(() async {
      final fields = <String, String>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (trainerId != null) 'trainerId': trainerId,
        if (order != null) 'order': order.toString(),
        if (hours != null) 'hours': hours.toString(),
        if (startDate != null) 'startDate': _dateStr(startDate),
        if (endDate != null) 'endDate': _dateStr(endDate),
      };

      final r = await _multipart(
        path: '${ApiConstants.modules}/$id',
        method: 'PATCH',
        fields: fields,
        pdfFilePath: pdfFilePath,
      );

      final d = _data(r);
      if (d is Map<String, dynamic>) return Module.fromJson(d);
      return Module.fromJson(r);
    }, context: 'ModuleService.update');
  }

  // ============================================================
  // VALIDATION (directeur)
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
      final r = await _api.patch(
        '${ApiConstants.modules}/$moduleId/approve',
        body: {
          'hours': hours,
          if (startDate != null) 'startDate': _dateStr(startDate),
          if (endDate != null) 'endDate': _dateStr(endDate),
          if (trainerId != null) 'trainerId': trainerId,
          if (formationId != null) 'formationId': formationId,
        },
      );

      final d = _data(r);
      if (d is Map<String, dynamic>) return Module.fromJson(d);
      return Module.fromJson(r);
    }, context: 'ModuleService.approve');
  }

  Future<Module> reject({
    required String moduleId,
    String? comment,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.patch(
        '${ApiConstants.modules}/$moduleId/reject',
        body: {if (comment != null) 'comment': comment},
      );
      final d = _data(r);
      if (d is Map<String, dynamic>) return Module.fromJson(d);
      return Module.fromJson(r);
    }, context: 'ModuleService.reject');
  }

  // ============================================================
  // SUPPRESSION
  // ============================================================
  Future<void> delete(String id) async {
    return ErrorHandler.guard(() async {
      await _api.delete('${ApiConstants.modules}/$id');
    }, context: 'ModuleService.delete');
  }

  // ============================================================
  // HELPERS
  // ============================================================
  Future<Map<String, dynamic>> _multipart({
    required String path,
    required String method,
    required Map<String, String> fields,
    String? pdfFilePath,
  }) async {
    final uri = Uri.parse('${ApiConstants.apiUrl}$path');
    final req = http.MultipartRequest(method, uri);

    final token = _api.token;
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.fields.addAll(fields);

    if (pdfFilePath != null) {
      req.files.add(await http.MultipartFile.fromPath(
        'pdf', pdfFilePath,
        contentType: MediaType('application', 'pdf'),
      ));
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 400) {
      throw Exception('Erreur : ${res.statusCode} - ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}