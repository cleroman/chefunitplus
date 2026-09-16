// ChefUnitPlus - Service PasswordRequest
import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/password_request.dart';
import 'api_client.dart';

class PasswordRequestService {
  final ApiClient api;
  PasswordRequestService(this.api);

  Future<List<PasswordRequest>> listPending() async {
    return ErrorHandler.guard(() async {
      final data = await api.get(
        ApiConstants.passwordRequests,
        query: {'status': 'pending'},
      );
      final raw = data['data'] as List? ?? const [];
      return raw.map((e) => PasswordRequest.fromJson(e as Map<String, dynamic>)).toList();
    }, context: 'PasswordRequestService.listPending');
  }

  Future<List<PasswordRequest>> listAll() async {
    return ErrorHandler.guard(() async {
      final data = await api.get(ApiConstants.passwordRequests);
      final raw = data['data'] as List? ?? const [];
      return raw.map((e) => PasswordRequest.fromJson(e as Map<String, dynamic>)).toList();
    }, context: 'PasswordRequestService.listAll');
  }

  Future<void> requestReset({String? reason}) async {
    return ErrorHandler.guard(() async {
      await api.post(ApiConstants.passwordRequests, body: {
        if (reason != null) 'reason': reason,
      });
    }, context: 'PasswordRequestService.requestReset');
  }

  Future<void> approve(String id, {required String newPassword}) async {
    return ErrorHandler.guard(() async {
      await api.patch(
        ApiConstants.withId(ApiConstants.approvePasswordRequest, id),
        body: {'newPassword': newPassword},
      );
    }, context: 'PasswordRequestService.approve');
  }

  Future<void> reject(String id) async {
    return ErrorHandler.guard(() async {
      await api.patch(
        ApiConstants.withId(ApiConstants.rejectPasswordRequest, id),
        body: {},
      );
    }, context: 'PasswordRequestService.reject');
  }
}