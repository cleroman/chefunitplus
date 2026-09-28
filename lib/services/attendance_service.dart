// =============================================================
// ChefUnitPlus - AttendanceService
// Gere le pointage de presence
// =============================================================

import '../core/errors/error_handler.dart';
import 'api_client.dart';

class AttendanceService {
  final ApiClient _api;

  AttendanceService(this._api);

  /// Pointer la presence
  Future<Map<String, dynamic>> checkIn({
    required String formationId,
    String? moduleId,
    String? sessionDate,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    return ErrorHandler.guard(() async {
      final r = await _api.post('/attendance/check-in', body: {
        'formation_id': formationId,
        if (moduleId != null) 'module_id': moduleId,
        if (sessionDate != null) 'session_date': sessionDate,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (notes != null) 'notes': notes,
      });
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'AttendanceService.checkIn');
  }

  /// Pointer la sortie
  Future<Map<String, dynamic>> checkOut(String id) async {
    return ErrorHandler.guard(() async {
      final r = await _api.patch('/attendance/$id/check-out');
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'AttendanceService.checkOut');
  }

  /// Mes presences
  Future<List<Map<String, dynamic>>> listMy({String? formationId}) async {
    return ErrorHandler.guard(() async {
      final path = formationId != null
          ? '/attendance/my?formation_id=$formationId'
          : '/attendance/my';
      final r = await _api.get(path);
      final d = r['data'] ?? r;
      if (d is List) {
        return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }, context: 'AttendanceService.listMy');
  }

  /// Stats de presence
  Future<Map<String, dynamic>> getStats(String formationId) async {
    return ErrorHandler.guard(() async {
      final r = await _api.get('/attendance/stats/$formationId');
      final d = r['data'] ?? r;
      return Map<String, dynamic>.from(d as Map);
    }, context: 'AttendanceService.getStats');
  }
}