import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planit_flutter/app/router/route_paths.dart';
import 'package:planit_flutter/core/network/network_providers.dart';
import 'package:planit_flutter/core/session/session_controller.dart';
import 'package:planit_flutter/core/session/session_repository.dart';
import 'package:planit_flutter/core/session/session_tokens.dart';
import 'package:planit_flutter/core/storage/preferences_service.dart';
import 'package:planit_flutter/core/storage/secure_storage_service.dart';
import 'package:planit_flutter/features/my_page/data/repository/user_repository_impl.dart';
import 'package:planit_flutter/features/my_page/domain/model/user_profile.dart';
import 'package:planit_flutter/features/my_page/domain/repository/user_repository.dart';
import 'package:planit_flutter/features/plan_generation/data/repository/plan_generation_repository_impl.dart';
import 'package:planit_flutter/features/plan_generation/domain/model/plan_generation_input.dart';
import 'package:planit_flutter/features/plan_generation/domain/model/plan_generation_status.dart';
import 'package:planit_flutter/features/plan_generation/domain/repository/plan_generation_repository.dart';
import 'package:planit_flutter/features/plan_generation/presentation/pages/plan_generation_loading_page.dart';

void main() {
  testWidgets('navigates to home when plan generation completes', (tester) async {
    final repository = _FakePlanGenerationRepository(
      createResponse: const PlanGenerationStatus(
        jobId: 'job-123',
        status: PlanGenerationJobStatus.completed,
        planDate: '2026-06-12',
        planId: 7,
        dashboardAvailable: true,
      ),
    );
    final userRepository = _FakeUserRepository(
      userProfile: const UserProfile(
        id: 1,
        name: '김민지',
        email: 'minji@example.com',
        onboardingCompleted: true,
      ),
    );
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
        preferredStudyMethod: 'BALANCED',
        usualStudyHoursPerDay: 4,
        onboardingCompleted: false,
      ),
    );
    final router = GoRouter(
      initialLocation: RoutePaths.planGenerationLoading,
      routes: [
        GoRoute(
          path: RoutePaths.planGenerationLoading,
          builder: (context, state) => const PlanGenerationLoadingPage(
            initialInput: PlanGenerationInput(
              subjects: [
                PlanGenerationSubjectInput(
                  subjectName: '수학',
                  examRange: '수열과 극한 1~3단원',
                  preferredMethodNote: '개념 정리 후 대표 문제',
                  difficulty: 'HIGH',
                ),
              ],
              preferredStudyMethod: 'BALANCED',
              difficultSubjects: ['수학'],
              dailyMaxStudyHours: 4,
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.home,
          builder: (context, state) =>
              const Scaffold(body: Text('home-route')),
        ),
        GoRoute(
          path: RoutePaths.subjectScope,
          builder: (context, state) =>
              const Scaffold(body: Text('subject-scope-route')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planGenerationRepositoryProvider.overrideWithValue(repository),
          userRepositoryProvider.overrideWithValue(userRepository),
          sessionControllerProvider.overrideWith((ref) => sessionController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('home-route'), findsOneWidget);
  });
}

class _FakePlanGenerationRepository implements PlanGenerationRepository {
  _FakePlanGenerationRepository({required this.createResponse});

  final PlanGenerationStatus createResponse;

  @override
  Future<PlanGenerationStatus> createJob(PlanGenerationInput input) async {
    return createResponse;
  }

  @override
  Future<PlanGenerationStatus> fetchStatus(String jobId) {
    throw UnimplementedError();
  }
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({required this.userProfile});

  final UserProfile userProfile;

  @override
  Future<UserProfile> getCurrentUser() async {
    return userProfile;
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
