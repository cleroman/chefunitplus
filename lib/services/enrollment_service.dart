import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/enrollment.dart';
import 'api_client.dart';

class EnrollmentService {
  final ApiClient _api;

  EnrollmentService(this._api);

  dynamic _extractData(Map<String, dynamic> r) =>
      r['data'] ?? r['enrollment'] ?? r['enrollments'];

  // Creation avec phone + accountName
  Future<Enrollment> request(
    String formationId, {
    required String phone,
    required String accountName,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await _api.post(
        ApiConstants.enrollments,
        body: {
          'formationId': formationId,
          'phone': phone,
          'accountName': accountName,
        },
      );
      final data = _extractData(response);
      if (data is Map<String, dynamic>) {
        return Enrollment.fromJson(data);
      }
      return Enrollment.fromJson(response);
    }, context: 'EnrollmentService.request');
  }

  // Confirmation OTP
  Future<void> confirmOtp(String enrollmentId, String otp) async {
    return ErrorHandler.guard(() async {
      await _api.patch(
        '${ApiConstants.enrollments}/$enrollmentId/confirm-otp',
        body: {'otp': otp},
      );
    }, context: 'EnrollmentService.confirmOtp');
  }

  // Mes inscriptions
  Future<List<Enrollment>> myEnrollments() async {
    return ErrorHandler.guard(() async {
      final response = await _api.get(ApiConstants.myEnrollments);
      final data = _extractData(response);
      if (data is List) {
        return data
            .map((e) => Enrollment.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return <Enrollment>[];
    }, context: 'EnrollmentService.myEnrollments');
  }

  // Pending directeur
  Future<List<Enrollment>> pendingForDirector() async {
    return ErrorHandler.guard(() async {
      final response = await _api.get(ApiConstants.pendingEnrollments);
      final data = _extractData(response);
      if (data is List) {
        return data
            .map((e) => Enrollment.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return <Enrollment>[];
    }, context: 'EnrollmentService.pendingForDirector');
  }

  // Valider avec OTP
  Future<void> validate(String enrollmentId, {required String otp, String? comment}) async {
    return ErrorHandler.guard(() async {
      await _api.patch(
        ApiConstants.validateEnrollment.replaceAll('{id}', enrollmentId),
        body: {
          'otp': otp,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
    }, context: 'EnrollmentService.validate');
  }

  // Refuser
  Future<void> reject(String enrollmentId, {String? comment}) async {
    return ErrorHandler.guard(() async {
      await _api.patch(
        ApiConstants.rejectEnrollment.replaceAll('{id}', enrollmentId),
        body: {
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
    }, context: 'EnrollmentService.reject');
  }

  // Recu (avec QR data)
  Future<Map<String, dynamic>> getReceipt(String enrollmentId) async {
    return ErrorHandler.guard(() async {
      final response = await _api.get(
        '${ApiConstants.enrollments}/$enrollmentId/receipt',
      );
      final data = _extractData(response);
      if (data is Map<String, dynamic>) return data;
      return response;
    }, context: 'EnrollmentService.getReceipt');
  }
}