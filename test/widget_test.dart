import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/app/bootstrap/app_bootstrap.dart';
import 'package:planit_flutter/core/network/api_config.dart';
import 'package:planit_flutter/core/network/network_providers.dart';
import 'package:planit_flutter/core/session/session_controller.dart';
import 'package:planit_flutter/core/session/session_snapshot.dart';
import 'package:planit_flutter/core/session/session_tokens.dart';
import 'package:planit_flutter/core/session/session_repository.dart';
import 'package:planit_flutter/core/storage/preferences_service.dart';
import 'package:planit_flutter/core/storage/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AppRuntimeConfig.fromEnvironment requires API_BASE_URL', () {
    expect(AppRuntimeConfig.fromEnvironment, throwsStateError);
  });

  testWidgets('App starts on the splash route with injected runtime config', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRuntimeConfigProvider.overrideWithValue(
            const AppRuntimeConfig(
              apiConfig: ApiConfig(baseUrl: 'https://api.test'),
            ),
          ),
          sharedPreferencesInstanceProvider.overrideWithValue(
            sharedPreferences,
          ),
        ],
        child: const PlanItApp(),
      ),
    );

    expect(find.text('Splash'), findsOneWidget);
    expect(find.text('Preparing your study plan...'), findsOneWidget);
  });

  testWidgets('Splash exposes retry action after restore failure', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();
    var retryCalls = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRuntimeConfigProvider.overrideWithValue(
            const AppRuntimeConfig(
              apiConfig: ApiConfig(baseUrl: 'https://api.test'),
            ),
          ),
          sharedPreferencesInstanceProvider.overrideWithValue(
            sharedPreferences,
          ),
          sessionControllerProvider.overrideWith((ref) {
            return _FakeSessionController(
              SessionSnapshot(
                status: SessionStatus.restoreFailed,
                tokens: SessionTokens(
                  accessToken: 'access-token',
                  refreshToken: 'refresh-token',
                  expiresAt: DateTime.utc(2026, 6, 12, 12),
                ),
              ),
            );
          }),
          sessionRestoreActionProvider.overrideWithValue(() async {
            retryCalls += 1;
          }),
        ],
        child: const PlanItApp(),
      ),
    );

    await tester.pump();

    expect(
      find.text('We could not restore your session. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    final callsBeforeTap = retryCalls;

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(retryCalls, callsBeforeTap + 1);
  });
}

class _FakeSessionController extends SessionController {
  _FakeSessionController(SessionSnapshot initialState)
    : super(
        SessionRepository(
          secureStorage: _InMemorySecureStorageService(),
          preferencesService: _InMemoryPreferencesService(),
        ),
      ) {
    state = initialState;
  }
}

class _InMemorySecureStorageService implements SecureStorageService {
  @override
  Future<void> clearTokens() async {}

  @override
  Future<SessionTokens?> readTokens() async => null;

  @override
  Future<void> saveTokens(SessionTokens tokens) async {}
}

class _InMemoryPreferencesService implements PreferencesService {
  @override
  Future<void> clearActiveJobId() async {}

  @override
  Future<String?> readActiveJobId() async => null;

  @override
  Future<void> saveActiveJobId(String jobId) async {}
}
