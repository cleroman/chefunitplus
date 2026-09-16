// ChefUnitPlus - Service UserDetails
import '../core/constants/api_constants.dart';
import '../core/errors/error_handler.dart';
import '../models/user_details.dart';
import 'api_client.dart';

class UserDetailsService {
  final ApiClient api;
  UserDetailsService(this.api);

  Future<Map<String, dynamic>> getFullProfile(String userId) async {
    return ErrorHandler.guard(() async {
      final data = await api.get(ApiConstants.withId(ApiConstants.userFullProfile, userId));
      return data['data'] as Map<String, dynamic>;
    }, context: 'UserDetailsService.getFullProfile');
  }

  Future<UserDetails> updateDetails(String userId, UserDetails details) async {
    return ErrorHandler.guard(() async {
      final data = await api.patch(
        '/users/$userId/details',
        body: details.toJson(),
      );
      return UserDetails.fromJson(data['data'] as Map<String, dynamic>);
    }, context: 'UserDetailsService.updateDetails');
  }

  Future<void> resetPassword(String userId, String newPassword) async {
    return ErrorHandler.guard(() async {
      await api.patch(
        ApiConstants.withId(ApiConstants.userResetPassword, userId),
        body: {'newPassword': newPassword},
      );
    }, context: 'UserDetailsService.resetPassword');
  }
}