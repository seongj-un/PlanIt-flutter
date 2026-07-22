import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/session/session_controller.dart';
import 'package:planit_flutter/core/session/session_repository.dart';
import 'package:planit_flutter/core/session/session_tokens.dart';
import 'package:planit_flutter/core/storage/preferences_service.dart';
import 'package:planit_flutter/core/storage/secure_storage_service.dart';
import 'package:planit_flutter/features/my_page/domain/model/user_profile.dart';
import 'package:planit_flutter/features/onboarding/domain/model/study_profile_input.dart';
import 'package:planit_flutter/features/onboarding/domain/repository/study_profile_repository.dart';
import 'package:planit_flutter/features/onboarding/presentation/controllers/study_profile_controller.dart';

void main() {
  group('StudyProfileController', () {
    test('validates required fields before submitting', () async {
      final repository = _FakeStudyProfileRepository();
      final sessionController = SessionController(
        SessionRepository(
          secureStorage: _MemorySecureStorageService(),
          preferencesService: _MemoryPreferencesService(),
        ),
      );
      final controller = StudyProfileController(
        repository: repository,
        sessionController: sessionController,
      );

      final result = await controller.submit(usualStudyHoursText: '');

      expect(result, isFalse);
      expect(repository.saveCallCount, 0);
      expect(controller.state.studyHoursError, '하루 공부 시간을 입력해주세요.');
      expect(controller.state.preferredMethodError, '선호 학습 방식을 선택해주세요.');
    });

    test(
      'saves study profile and updates current session user profile',
      () async {
        final repository = _FakeStudyProfileRepository();
        final sessionController = SessionController(
          SessionRepository(
            secureStorage: _MemorySecureStorageService(),
            preferencesService: _MemoryPreferencesService(),
          ),
        );
        await sessionController.save(
          tokens: _tokens,
          userProfile: const UserProfile(
            id: 1,
            name: '김민지',
            email: 'minji@example.com',
            onboardingCompleted: false,
          ),
        );

        final controller = StudyProfileController(
          repository: repository,
          sessionController: sessionController,
        );

        controller.setPreferredStudyMethod('BALANCED');

        final result = await controller.submit(usualStudyHoursText: '4');

        expect(result, isTrue);
        expect(
          repository.lastInput,
          const StudyProfileInput(
            usualStudyHoursPerDay: 4,
            preferredStudyMethod: 'BALANCED',
          ),
        );
        expect(controller.state.isSuccess, isTrue);
        expect(sessionController.state.userProfile?.usualStudyHoursPerDay, 4);
        expect(
          sessionController.state.userProfile?.preferredStudyMethod,
          'BALANCED',
        );
      },
    );
  });
}

class _FakeStudyProfileRepository implements StudyProfileRepository {
  int saveCallCount = 0;
  StudyProfileInput? lastInput;

  @override
  Future<UserProfile> saveStudyProfile(StudyProfileInput input) async {
    saveCallCount += 1;
    lastInput = input;

    return UserProfile(
      id: 1,
      name: '김민지',
      email: 'minji@example.com',
      usualStudyHoursPerDay: input.usualStudyHoursPerDay,
      preferredStudyMethod: input.preferredStudyMethod,
      onboardingCompleted: false,
    );
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
  String? _activeJobId;

  @override
  Future<void> clearActiveJobId() async {
    _activeJobId = null;
  }

  @override
  Future<String?> readActiveJobId() async {
    return _activeJobId;
  }

  @override
  Future<void> saveActiveJobId(String jobId) async {
    _activeJobId = jobId;
  }
}

final _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  expiresAt: DateTime.utc(2026, 6, 12, 12),
);
