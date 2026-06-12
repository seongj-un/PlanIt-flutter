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
import 'package:planit_flutter/features/exam_plan/data/repository/exam_plan_repository_impl.dart';
import 'package:planit_flutter/features/exam_plan/domain/model/exam_plan_input.dart';
import 'package:planit_flutter/features/exam_plan/domain/model/subject_scope_input.dart';
import 'package:planit_flutter/features/exam_plan/domain/repository/exam_plan_repository.dart';
import 'package:planit_flutter/features/exam_plan/presentation/pages/exam_plan_page.dart';
import 'package:planit_flutter/features/exam_plan/presentation/pages/subject_scope_page.dart';
import 'package:planit_flutter/features/my_page/domain/model/user_profile.dart';

void main() {
  testWidgets('saves exam plan and moves to subject scope page', (
    tester,
  ) async {
    final repository = _FakeExamPlanRepository();
    final sessionController = SessionController(
      SessionRepository(
        secureStorage: _MemorySecureStorageService(),
        preferencesService: _MemoryPreferencesService(),
      ),
    );
    await sessionController.save(
      tokens: _tokens,
      userProfile: UserProfile(
        id: 1,
        name: '김민지',
        email: 'minji@example.com',
        targetExamType: 'CSAT',
        targetExamLabel: '수능',
        examDate: DateTime(2026, 11, 19),
        onboardingCompleted: false,
      ),
    );

    final router = GoRouter(
      initialLocation: RoutePaths.examPlan,
      routes: [
        GoRoute(
          path: RoutePaths.examPlan,
          builder: (context, state) => const ExamPlanPage(),
        ),
        GoRoute(
          path: RoutePaths.subjectScope,
          builder: (context, state) => const SubjectScopePage(),
        ),
        GoRoute(
          path: RoutePaths.planGenerationLoading,
          builder: (context, state) =>
              const Scaffold(body: Text('plan-generation-route')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examPlanRepositoryProvider.overrideWithValue(repository),
          sessionControllerProvider.overrideWith((ref) => sessionController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026-11-19'), findsWidgets);

    await tester.tap(find.text('모의고사'));
    await tester.enterText(find.byType(TextField).at(0), '6월 모의평가');
    await tester.enterText(find.byType(TextField).at(1), '2026-06-30');
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('저장하고 계속'), findsOneWidget);
    expect(
      repository.lastExamPlanInput,
      const ExamPlanInput(
        targetExamType: 'MOCK_EXAM',
        targetExamLabel: '6월 모의평가',
        examDate: '2026-06-30',
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), '수학');
    await tester.enterText(find.byType(TextField).at(1), '수열과 극한 1~3단원');
    await tester.enterText(find.byType(TextField).at(2), '개념 정리 후 대표 문제');
    await tester.tap(find.text('높음'));
    await tester.ensureVisible(find.text('저장하고 계속'));
    await tester.tap(find.text('저장하고 계속'));
    await tester.pumpAndSettle();

    expect(find.text('plan-generation-route'), findsOneWidget);
    expect(repository.lastSubjectScopes, const [
      SubjectScopeInput(
        subjectName: '수학',
        examRange: '수열과 극한 1~3단원',
        preferredMethodNote: '개념 정리 후 대표 문제',
        priority: 'HIGH',
      ),
    ]);
  });
}

class _FakeExamPlanRepository implements ExamPlanRepository {
  ExamPlanInput? lastExamPlanInput;
  List<SubjectScopeInput>? lastSubjectScopes;

  @override
  Future<UserProfile> saveExamPlan(ExamPlanInput input) async {
    lastExamPlanInput = input;

    return UserProfile(
      id: 1,
      name: '김민지',
      email: 'minji@example.com',
      targetExamType: input.targetExamType,
      targetExamLabel: input.targetExamLabel,
      examDate: DateTime.parse(input.examDate),
      onboardingCompleted: false,
    );
  }

  @override
  Future<void> saveSubjectScopes(List<SubjectScopeInput> inputs) async {
    lastSubjectScopes = inputs;
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
