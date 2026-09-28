// =============================================================
// ChefUnitPlus - QuestionService
// Gere les questions au formateur
// =============================================================

import '../core/errors/error_handler.dart';
import 'api_client.dart';

class QuestionService {
  final ApiClient _api;

  QuestionService(this._api);

  /// Poser une question
  Future<Map<String, dynamic>> create({
    required String formationId,
    required String title,
    required String content,
    String? moduleId,
    String? trainerId,
    String priority = 'normal',
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post('/questions', body: {
        'formation_id': formationId,
        'title': title,
        'content': content,
        if (moduleId != null) 'module_id': moduleId,
        if (trainerId != null) 'trainer_id': trainerId,
        'priority': priority,
      });
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'QuestionService.create');
  }

  /// Mes questions
  Future<List<Map<String, dynamic>>> listMy() async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/questions/my');
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'QuestionService.listMy');
  }

  /// Question + reponses
  Future<Map<String, dynamic>> getById(String id) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/questions/$id');
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'QuestionService.getById');
  }

  /// Repondre
  Future<Map<String, dynamic>> answer(String id, String content) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post('/questions/$id/answer', body: {'content': content});
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'QuestionService.answer');
  }
}