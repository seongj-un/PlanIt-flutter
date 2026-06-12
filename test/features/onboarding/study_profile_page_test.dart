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
import 'package:planit_flutter/features/my_page/domain/model/user_profile.dart';
import 'package:planit_flutter/features/onboarding/data/repository/study_profile_repository_impl.dart';
import 'package:planit_flutter/features/onboarding/domain/model/study_profile_input.dart';
import 'package:planit_flutter/features/onboarding/domain/repository/study_profile_repository.dart';
import 'package:planit_flutter/features/onboarding/presentation/pages/study_profile_page.dart';

void main() {
  testWidgets('hydrates current values and moves to exam plan after save', (
    tester,
  ) async {
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
        age: 17,
        schoolLevel: 'MIDDLE_SCHOOL',
        usualStudyHoursPerDay: 3,
        preferredStudyMethod: 'CONCEPT_FIRST',
        onboardingCompleted: false,
      ),
    );

    final router = GoRouter(
      initialLocation: RoutePaths.studyProfile,
      routes: [
        GoRoute(
          path: RoutePaths.studyProfile,
          builder: (context, state) => const StudyProfilePage(),
        ),
        GoRoute(
          path: RoutePaths.examPlan,
          builder: (context, state) =>
              const Scaffold(body: Text('exam-plan-route')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyProfileRepositoryProvider.overrideWithValue(repository),
          sessionControllerProvider.overrideWith((ref) => sessionController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('17'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '18');
    await tester.enterText(find.byType(TextField).at(1), '4');
    await tester.tap(find.text('고등학교'));
    await tester.tap(find.text('균형 있게'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('exam-plan-route'), findsOneWidget);
    expect(
      repository.lastInput,
      const StudyProfileInput(
        age: 18,
        schoolLevel: 'HIGH_SCHOOL',
        usualStudyHoursPerDay: 4,
        preferredStudyMethod: 'BALANCED',
      ),
    );
  });
}

class _FakeStudyProfileRepository implements StudyProfileRepository {
  StudyProfileInput? lastInput;

  @override
  Future<UserProfile> saveStudyProfile(StudyProfileInput input) async {
    lastInput = input;

    return UserProfile(
      id: 1,
      name: '김민지',
      email: 'minji@example.com',
      age: input.age,
      schoolLevel: input.schoolLevel,
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
