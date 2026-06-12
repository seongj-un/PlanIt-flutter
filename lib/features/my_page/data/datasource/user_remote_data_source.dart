import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_providers.dart';
import '../dto/account_settings_request_dto.dart';
import '../dto/notification_settings_request_dto.dart';
import '../dto/study_settings_request_dto.dart';
import '../dto/user_profile_dto.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(apiClient: ref.watch(apiClientProvider));
});

class UserRemoteDataSource {
  const UserRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UserProfileDto> getCurrentUser() {
    return _apiClient.get<UserProfileDto>(
      '/users/me',
      parser: UserProfileDto.fromJson,
    );
  }

  Future<void> updateStudySettings(StudySettingsRequestDto request) async {
    await _apiClient.patch<bool>(
      '/users/me/study-settings',
      data: request.toJson(),
      parser: _parseUpdatedFlag,
    );
  }

  Future<void> updateNotificationSettings(
    NotificationSettingsRequestDto request,
  ) async {
    await _apiClient.patch<bool>(
      '/users/me/notification-settings',
      data: request.toJson(),
      parser: _parseUpdatedFlag,
    );
  }

  Future<void> updateAccount(AccountSettingsRequestDto request) async {
    await _apiClient.patch<bool>(
      '/users/me/account',
      data: request.toJson(),
      parser: _parseUpdatedFlag,
    );
  }

  Future<void> logout(String refreshToken) async {
    await _apiClient.post<Object?>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
      parser: (_) => null,
    );
  }
}

bool _parseUpdatedFlag(Object? json) {
  if (json is! Map) {
    throw const ApiErrorException(
      code: 'INVALID_API_RESPONSE',
      message: 'Settings response payload must be a JSON object.',
    );
  }

  final updated = Map<String, Object?>.from(json)['updated'];
  if (updated is! bool) {
    throw const ApiErrorException(
      code: 'INVALID_API_RESPONSE',
      message: 'Settings response is missing updated flag.',
    );
  }

  return updated;
}
