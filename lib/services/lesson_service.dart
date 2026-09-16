import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/lesson.dart';
import 'api_client.dart';

class LessonService {
  final ApiClient _api;
  LessonService(this._api);

  dynamic _data(Map<String, dynamic> r) => r['data'] ?? r['lesson'];

  List<dynamic> _list(Map<String, dynamic> r) {
    final d = _data(r);
    if (d is List) return d;
    return [];
  }

  Future<List<Lesson>> listByModule(String moduleId) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('${ApiConstants.modules}/$moduleId/lessons');
      return _list(r)
          .map((e) => Lesson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }, context: 'LessonService.listByModule');
  }

  Future<Lesson> create({
    required String moduleId,
    required String title,
    String? description,
    String? content,
    String? videoUrl,
    int duration = 0,
    int order = 0,
    List<QuizQuestion> quiz = const [],
    String? pdfFilePath,
  }) async {
    return ErrorHandler.guard(() async {
      final fields = {
        'moduleId': moduleId,
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        if (content != null && content.isNotEmpty) 'content': content,
        if (videoUrl != null && videoUrl.isNotEmpty) 'videoUrl': videoUrl,
        'duration': duration.toString(),
        'order': order.toString(),
        if (quiz.isNotEmpty) 'quiz': jsonEncode(quiz.map((q) => q.toJson()).toList()),
      };

      final r = await _multipart(
        path: '${ApiConstants.modules}/$moduleId/lessons',
        method: 'POST',
        fields: fields,
        pdfFilePath: pdfFilePath,
      );
      final d = _data(r);
      if (d is Map<String, dynamic>) return Lesson.fromJson(d);
      return Lesson.fromJson(r);
    }, context: 'LessonService.create');
  }

  Future<Lesson> update({
    required String id,
    String? title,
    String? description,
    String? content,
    String? videoUrl,
    int? duration,
    int? order,
    List<QuizQuestion>? quiz,
    String? pdfFilePath,
  }) async {
    return ErrorHandler.guard(() async {
      final fields = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (content != null) 'content': content,
        if (videoUrl != null) 'videoUrl': videoUrl,
        if (duration != null) 'duration': duration.toString(),
        if (order != null) 'order': order.toString(),
        if (quiz != null) 'quiz': jsonEncode(quiz.map((q) => q.toJson()).toList()),
      };

      final r = await _multipart(
        path: '${ApiConstants.modules.replaceAll(RegExp(r"$"), "")}/lessons/$id',
        method: 'PATCH',
        fields: fields,
        pdfFilePath: pdfFilePath,
      );
      final d = _data(r);
      if (d is Map<String, dynamic>) return Lesson.fromJson(d);
      return Lesson.fromJson(r);
    }, context: 'LessonService.update');
  }

  Future<void> delete(String id) async {
    return ErrorHandler.guard(() async {
      await _api.delete('${ApiConstants.modules}/lessons/$id');
    }, context: 'LessonService.delete');
  }

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
        'pdf',
        pdfFilePath,
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
}