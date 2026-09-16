// =============================================================
// ChefUnitPlus - ComplaintService (complet)
// =============================================================

import 'package:chefunitplus/core/errors/error_handler.dart';
import 'package:chefunitplus/models/complaint.dart';
import 'package:chefunitplus/services/api_client.dart';

class ComplaintService {
  final ApiClient api;
  ComplaintService(this.api);

  Future<List<Complaint>> listAll() async {
    return ErrorHandler.guard(() async {
      final data = await api.get('/complaints');
      final raw = data['complaints'] as List? ?? const [];
      return raw
          .map((e) => Complaint.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'ComplaintService.listAll');
  }

  Future<Complaint> create({
    required String subject,
    required String description,
    ComplaintPriority priority = ComplaintPriority.normal,
  }) async {
    return ErrorHandler.guard(() async {
      final data = await api.post(
        '/complaints',
        body: {
          'subject': subject,
          'description': description,
          'priority': priority.name,
        },
      );
      return Complaint.fromJson(data['complaint'] as Map<String, dynamic>);
    }, context: 'ComplaintService.create');
  }

  Future<Complaint> updateStatus({
    required String id,
    required ComplaintStatus status,
    String? response,
  }) async {
    return ErrorHandler.guard(() async {
      final data = await api.patch(
        '/complaints/$id',
        body: {
          'status': status.name,
          if (response != null) 'response': response,
        },
      );
      return Complaint.fromJson(data['complaint'] as Map<String, dynamic>);
    }, context: 'ComplaintService.updateStatus');
  }

  Future<void> delete(String id) async {
    return ErrorHandler.guard(() async {
      await api.delete('/complaints/$id');
    }, context: 'ComplaintService.delete');
  }
}