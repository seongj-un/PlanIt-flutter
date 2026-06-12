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
import 'package:planit_flutter/features/my_page/presentation/pages/my_page.dart';

void main() {
  testWidgets('renders profile summary and logs out to the welcome route', (
    tester,
  ) async {
    final repository = _FakeUserRepository();
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
        onboardingCompleted: true,
      ),
    );
    final router = GoRouter(
      initialLocation: RoutePaths.myPage,
      routes: [
        GoRoute(
          path: RoutePaths.myPage,
          builder: (context, state) => const MyPagePage(),
        ),
        GoRoute(
          path: RoutePaths.welcome,
          builder: (context, state) =>
              const Scaffold(body: Text('welcome-route')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(repository),
          sessionControllerProvider.overrideWith((ref) => sessionController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('김민지'), findsOneWidget);
    expect(find.text('minji@example.com'), findsOneWidget);

    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();

    expect(find.text('welcome-route'), findsOneWidget);
  });
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<UserProfile> getCurrentUser() async {
    return const UserProfile(
      id: 1,
      name: '김민지',
      email: 'minji@example.com',
      preferredStudyMethod: 'BALANCED',
      usualStudyHoursPerDay: 4,
      onboardingCompleted: true,
    );
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
