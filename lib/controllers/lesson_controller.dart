import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';
import '../models/lesson.dart';
import '../services/lesson_service.dart';

class LessonController extends ChangeNotifier {
  final LessonService _service;
  LessonController(this._service);

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  List<Lesson> _lessons = [];
  List<Lesson> get lessons => _lessons;

  String _currentModuleId = '';

  Future<void> loadByModule(String moduleId, {bool refresh = false}) async {
    if (!refresh && _loading) return;
    _currentModuleId = moduleId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _lessons = await _service.listByModule(moduleId);
    } on AppException catch (e) {
      _error = e.message;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      ErrorHandler.log(e, st, 'LessonController.loadByModule');
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> create({
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
    _error = null;
    try {
      await _service.create(
        moduleId: moduleId,
        title: title,
        description: description,
        content: content,
        videoUrl: videoUrl,
        duration: duration,
        order: order,
        quiz: quiz,
        pdfFilePath: pdfFilePath,
      );
      await loadByModule(moduleId, refresh: true);
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'LessonController.create');
      return false;
    }
  }

  Future<bool> update({
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
    _error = null;
    try {
      await _service.update(
        id: id,
        title: title,
        description: description,
        content: content,
        videoUrl: videoUrl,
        duration: duration,
        order: order,
        quiz: quiz,
        pdfFilePath: pdfFilePath,
      );
      if (_currentModuleId.isNotEmpty) {
        await loadByModule(_currentModuleId, refresh: true);
      }
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'LessonController.update');
      return false;
    }
  }

  Future<bool> delete(String id) async {
    _error = null;
    try {
      await _service.delete(id);
      _lessons = _lessons.where((l) => l.id != id).toList();
      notifyListeners();
      return true;
    } catch (e, st) {
      _error = ErrorHandler.message(e);
      notifyListeners();
      ErrorHandler.log(e, st, 'LessonController.delete');
      return false;
    }
  }

  void reset() {
    _lessons = [];
    _error = null;
    _loading = false;
    notifyListeners();
  }
}