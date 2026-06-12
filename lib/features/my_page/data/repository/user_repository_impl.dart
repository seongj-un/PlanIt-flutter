import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dto/account_settings_request_dto.dart';
import '../dto/notification_settings_request_dto.dart';
import '../dto/study_settings_request_dto.dart';
import '../../domain/model/user_profile.dart';
import '../../domain/repository/user_repository.dart';
import '../datasource/user_remote_data_source.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDataSource: ref.watch(userRemoteDataSourceProvider),
  );
});

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({required UserRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> getCurrentUser() async {
    final profile = await _remoteDataSource.getCurrentUser();
    return profile.toDomain();
  }

  @override
  Future<void> logout(String refreshToken) {
    return _remoteDataSource.logout(refreshToken);
  }

  @override
  Future<void> updateAccount({
    required String name,
    required String password,
  }) {
    return _remoteDataSource.updateAccount(
      AccountSettingsRequestDto(name: name, password: password),
    );
  }

  @override
  Future<void> updateNotificationSettings({
    required bool dailyReminderEnabled,
    required String dailyReminderTime,
  }) {
    return _remoteDataSource.updateNotificationSettings(
      NotificationSettingsRequestDto(
        dailyReminderEnabled: dailyReminderEnabled,
        dailyReminderTime: dailyReminderTime,
      ),
    );
  }

  @override
  Future<void> updateStudySettings({
    required int usualStudyHoursPerDay,
    required String preferredStudyMethod,
  }) {
    return _remoteDataSource.updateStudySettings(
      StudySettingsRequestDto(
        usualStudyHoursPerDay: usualStudyHoursPerDay,
        preferredStudyMethod: preferredStudyMethod,
      ),
    );
  }
}
