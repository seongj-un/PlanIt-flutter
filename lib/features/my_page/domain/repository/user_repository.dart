import '../model/user_profile.dart';

abstract interface class UserRepository {
  Future<UserProfile> getCurrentUser();

  Future<void> updateStudySettings({
    required int usualStudyHoursPerDay,
    required String preferredStudyMethod,
  });

  Future<void> updateNotificationSettings({
    required bool dailyReminderEnabled,
    required String dailyReminderTime,
  });

  Future<void> updateAccount({
    required String name,
    required String password,
  });

  Future<void> logout(String refreshToken);
}
