import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/session/session_controller.dart';
import 'package:planit_flutter/core/session/session_repository.dart';
import 'package:planit_flutter/core/session/session_snapshot.dart';
import 'package:planit_flutter/core/session/session_tokens.dart';
import 'package:planit_flutter/core/storage/preferences_service.dart';
import 'package:planit_flutter/core/storage/secure_storage_service.dart';
import 'package:planit_flutter/features/my_page/domain/model/user_profile.dart';
import 'package:planit_flutter/features/my_page/domain/repository/user_repository.dart';
import 'package:planit_flutter/features/my_page/presentation/controllers/my_page_controller.dart';

void main() {
  test('saves study settings and refreshes the current session user', () async {
    final repository = _FakeUserRepository();
    final sessionController = _buildSessionController();
    await sessionController.save(
      tokens: _tokens,
      userProfile: const UserProfile(
        id: 1,
        name: '김민지',
        email: 'minji@example.com',
        preferredStudyMethod: 'BALANCED',
        usualStudyHoursPerDay: 4,
        onboardingCompleted: true,
      ),
    );
    final controller = MyPageController(
      repository: repository,
      sessionController: sessionController,
    );

    await controller.load();
    final result = await controller.saveStudySettings(
      usualStudyHoursPerDayText: '5',
      preferredStudyMethod: 'CONCEPT_FIRST',
    );

    expect(result, isTrue);
    expect(repository.updatedStudyHours, 5);
    expect(repository.updatedStudyMethod, 'CONCEPT_FIRST');
    expect(controller.state.userProfile?.usualStudyHoursPerDay, 5);
    expect(sessionController.state.userProfile?.preferredStudyMethod, 'CONCEPT_FIRST');
  });

  test('clears session on logout even when the server request fails', () async {
    final repository = _FakeUserRepository();
    repository.logoutError = Exception('network');
    final sessionController = _buildSessionController();
    await sessionController.save(
      tokens: _tokens,
      userProfile: const UserProfile(
        id: 1,
        name: '김민지',
        email: 'minji@example.com',
        onboardingCompleted: true,
      ),
    );
    final controller = MyPageController(
      repository: repository,
      sessionController: sessionController,
    );

    final result = await controller.logout();

    expect(result, isTrue);
    expect(sessionController.state.hasSession, isFalse);
    expect(sessionController.state.status, SessionStatus.unauthenticated);
  });
}

SessionController _buildSessionController() {
  return SessionController(
    SessionRepository(
      secureStorage: _MemorySecureStorageService(),
      preferencesService: _MemoryPreferencesService(),
    ),
  );
}

class _FakeUserRepository implements UserRepository {
  int? updatedStudyHours;
  String? updatedStudyMethod;
  Object? logoutError;

  @override
  Future<UserProfile> getCurrentUser() async {
    return UserProfile(
      id: 1,
      name: '김민지',
      email: 'minji@example.com',
      preferredStudyMethod: updatedStudyMethod ?? 'BALANCED',
      usualStudyHoursPerDay: updatedStudyHours ?? 4,
      onboardingCompleted: true,
    );
  }

  @override
  Future<void> logout(String refreshToken) async {
    final error = logoutError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> updateAccount({
    required String name,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateNotificationSettings({
    required bool dailyReminderEnabled,
    required String dailyReminderTime,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateStudySettings({
    required int usualStudyHoursPerDay,
    required String preferredStudyMethod,
  }) async {
    updatedStudyHours = usualStudyHoursPerDay;
    updatedStudyMethod = preferredStudyMethod;
  }
}

class _MemorySecureStorageService implements SecureStorageService {
  SessionTokens? _tokens;

  @override
  Future<void> clearTokens() async {
    _tokens = null;
  }

  @override
  Future<SessionTokens?> readTokens() async {
    return _tokens;
  }

  @override
  Future<void> saveTokens(SessionTokens tokens) async {
    _tokens = tokens;
  }
}

class _MemoryPreferencesService implements PreferencesService {
  @override
  Future<void> clearActiveJobId() async {}

  @override
  Future<String?> readActiveJobId() async {
    return null;
  }

  @override
  Future<void> saveActiveJobId(String jobId) async {}
}

final _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  expiresAt: DateTime.utc(2026, 6, 12, 12),
);
