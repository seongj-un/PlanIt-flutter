import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/session/session_controller.dart';
import 'package:planit_flutter/core/session/session_repository.dart';
import 'package:planit_flutter/core/session/session_tokens.dart';
import 'package:planit_flutter/core/storage/preferences_service.dart';
import 'package:planit_flutter/core/storage/secure_storage_service.dart';
import 'package:planit_flutter/features/my_page/domain/model/user_profile.dart';
import 'package:planit_flutter/features/my_page/domain/repository/user_repository.dart';
import 'package:planit_flutter/features/plan_generation/domain/model/plan_generation_input.dart';
import 'package:planit_flutter/features/plan_generation/domain/model/plan_generation_status.dart';
import 'package:planit_flutter/features/plan_generation/domain/repository/plan_generation_repository.dart';
import 'package:planit_flutter/features/plan_generation/presentation/controllers/plan_generation_controller.dart';

void main() {
  group('PlanGenerationController', () {
    test(
      'starts a new job, saves job id, polls to completion, and refreshes the session user',
      () async {
        final repository = _FakePlanGenerationRepository(
          createResponse: const PlanGenerationStatus(
            jobId: 'job-123',
            status: PlanGenerationJobStatus.pending,
            estimatedSeconds: 0,
          ),
          statusResponses: [
            const PlanGenerationStatus(
              jobId: 'job-123',
              status: PlanGenerationJobStatus.running,
              progressPercent: 35,
              message: '플랜을 생성하고 있어요.',
            ),
            const PlanGenerationStatus(
              jobId: 'job-123',
              status: PlanGenerationJobStatus.completed,
              planDate: '2026-06-12',
              planId: 101,
              dashboardAvailable: true,
            ),
          ],
        );
        final userRepository = _FakeUserRepository(
          userProfile: const UserProfile(
            id: 1,
            name: '김민지',
            email: 'minji@example.com',
            preferredStudyMethod: 'BALANCED',
            usualStudyHoursPerDay: 4,
            onboardingCompleted: true,
          ),
        );
        final sessionController = _buildSessionController();
        await sessionController.save(
          tokens: _tokens,
          userProfile: const UserProfile(
            id: 1,
            name: '김민지',
            email: 'minji@example.com',
            preferredStudyMethod: 'BALANCED',
            usualStudyHoursPerDay: 4,
            onboardingCompleted: false,
          ),
        );
        final controller = PlanGenerationController(
          repository: repository,
          userRepository: userRepository,
          sessionController: sessionController,
          pollInterval: const Duration(milliseconds: 1),
        );

        await controller.initialize(
          initialInput: const PlanGenerationInput(
            subjects: [
              PlanGenerationSubjectInput(
                subjectName: '수학',
                examRange: '수열과 극한 1~3단원',
                preferredMethodNote: '개념 정리 후 대표 문제 15문제',
                difficulty: 'HIGH',
              ),
            ],
            preferredStudyMethod: 'BALANCED',
            difficultSubjects: ['수학'],
            dailyMaxStudyHours: 4,
          ),
        );
        await _waitUntil(() => controller.state.phase == PlanGenerationPhase.completed);

        expect(repository.createCallCount, 1);
        expect(repository.fetchStatusCallCount, 2);
        expect(sessionController.state.activeJobId, isNull);
        expect(sessionController.state.userProfile?.onboardingCompleted, isTrue);
        expect(controller.state.phase, PlanGenerationPhase.completed);
        expect(controller.state.jobId, 'job-123');

        controller.dispose();
      },
    );

    test('restores polling from an existing job id without creating a new job', () async {
      final repository = _FakePlanGenerationRepository(
        createResponse: const PlanGenerationStatus(
          jobId: 'unused',
          status: PlanGenerationJobStatus.pending,
        ),
        statusResponses: const [
          PlanGenerationStatus(
            jobId: 'job-999',
            status: PlanGenerationJobStatus.running,
            progressPercent: 55,
            message: '기존 작업을 이어받고 있어요.',
          ),
        ],
      );
      final sessionController = _buildSessionController();
      await sessionController.save(
        tokens: _tokens,
        activeJobId: 'job-999',
        userProfile: const UserProfile(
          id: 1,
          name: '김민지',
          email: 'minji@example.com',
          onboardingCompleted: false,
        ),
      );
      final controller = PlanGenerationController(
        repository: repository,
        userRepository: _FakeUserRepository(
          userProfile: const UserProfile(
            id: 1,
            name: '김민지',
            email: 'minji@example.com',
            onboardingCompleted: false,
          ),
        ),
        sessionController: sessionController,
        pollInterval: const Duration(days: 1),
      );

      await controller.initialize();
      await _waitUntil(() => repository.fetchStatusCallCount == 1);

      expect(repository.createCallCount, 0);
      expect(controller.state.phase, PlanGenerationPhase.polling);
      expect(controller.state.jobId, 'job-999');
      expect(controller.state.progressPercent, 55);
      expect(sessionController.state.activeJobId, 'job-999');

      controller.dispose();
    });
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

Future<void> _waitUntil(bool Function() predicate) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }

  fail('Condition was not met in time.');
}

class _FakePlanGenerationRepository implements PlanGenerationRepository {
  _FakePlanGenerationRepository({
    required this.createResponse,
    required List<PlanGenerationStatus> statusResponses,
  }) : _statusResponses = Queue<PlanGenerationStatus>.from(statusResponses);

  final PlanGenerationStatus createResponse;
  final Queue<PlanGenerationStatus> _statusResponses;

  int createCallCount = 0;
  int fetchStatusCallCount = 0;

  @override
  Future<PlanGenerationStatus> createJob(PlanGenerationInput input) async {
    createCallCount += 1;
    return createResponse;
  }

  @override
  Future<PlanGenerationStatus> fetchStatus(String jobId) async {
    fetchStatusCallCount += 1;
    return _statusResponses.removeFirst();
  }
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({required this.userProfile});

  final UserProfile userProfile;

  @override
  Future<UserProfile> getCurrentUser() async {
    return userProfile;
  }

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<void> updateAccount({
    required String name,
    required String password,
  }) async {}

  @override
  Future<void> updateNotificationSettings({
    required bool dailyReminderEnabled,
    required String dailyReminderTime,
  }) async {}

  @override
  Future<void> updateStudySettings({
    required int usualStudyHoursPerDay,
    required String preferredStudyMethod,
  }) async {}
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
