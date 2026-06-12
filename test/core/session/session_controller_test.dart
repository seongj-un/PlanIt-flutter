import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/session/session_controller.dart';
import 'package:planit_flutter/core/session/session_repository.dart';
import 'package:planit_flutter/core/session/session_snapshot.dart';
import 'package:planit_flutter/core/session/session_tokens.dart';
import 'package:planit_flutter/core/storage/preferences_service.dart';
import 'package:planit_flutter/core/storage/secure_storage_service.dart';
import 'package:planit_flutter/features/my_page/domain/model/user_profile.dart';

void main() {
  group('SessionController', () {
    test('restore reads saved tokens and active job id', () async {
      final secureStorage = _InMemorySecureStorageService();
      final preferences = _InMemoryPreferencesService();
      final tokens = SessionTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        expiresAt: DateTime.utc(2026, 6, 12, 9),
      );

      await secureStorage.saveTokens(tokens);
      await preferences.saveActiveJobId('job-123');

      final repository = SessionRepository(
        secureStorage: secureStorage,
        preferencesService: preferences,
      );
      final controller = SessionController(repository);

      final snapshot = await controller.restore();

      expect(snapshot.tokens, tokens);
      expect(snapshot.activeJobId, 'job-123');
      expect(controller.state.tokens, tokens);
      expect(controller.state.activeJobId, 'job-123');
      expect(controller.state.status, SessionStatus.restoring);
    });

    test('save persists tokens and clear removes the session', () async {
      final secureStorage = _InMemorySecureStorageService();
      final preferences = _InMemoryPreferencesService();
      final repository = SessionRepository(
        secureStorage: secureStorage,
        preferencesService: preferences,
      );
      final controller = SessionController(repository);
      final tokens = SessionTokens(
        accessToken: 'next-access',
        refreshToken: 'next-refresh',
        expiresAt: DateTime.utc(2026, 6, 12, 10),
      );

      await controller.save(tokens: tokens, activeJobId: 'job-456');

      expect(await secureStorage.readTokens(), tokens);
      expect(await preferences.readActiveJobId(), 'job-456');
      expect(controller.state.tokens, tokens);

      await controller.clear();

      expect(await secureStorage.readTokens(), isNull);
      expect(await preferences.readActiveJobId(), isNull);
      expect(controller.state.isAuthenticated, isFalse);
      expect(controller.state.activeJobId, isNull);
      expect(controller.state.status, SessionStatus.unauthenticated);
    });

    test(
      'restoreAuthenticatedSession clears persisted session on failure',
      () async {
        final secureStorage = _InMemorySecureStorageService();
        final preferences = _InMemoryPreferencesService();
        final repository = SessionRepository(
          secureStorage: secureStorage,
          preferencesService: preferences,
        );
        final controller = SessionController(repository);
        final tokens = SessionTokens(
          accessToken: 'persisted-access',
          refreshToken: 'persisted-refresh',
          expiresAt: DateTime.utc(2026, 6, 12, 11),
        );

        await secureStorage.saveTokens(tokens);
        await preferences.saveActiveJobId('job-123');

        final snapshot = await controller.restoreAuthenticatedSession(
          refreshSession: (tokens) async => throw Exception('refresh failed'),
          fetchCurrentUser: () async => throw Exception('unauthorized'),
        );

        expect(snapshot.status, SessionStatus.unauthenticated);
        expect(snapshot.tokens, isNull);
        expect(snapshot.activeJobId, isNull);
        expect(await secureStorage.readTokens(), isNull);
        expect(await preferences.readActiveJobId(), isNull);
      },
    );

    test(
      'restoreAuthenticatedSession completes session with current user',
      () async {
        final secureStorage = _InMemorySecureStorageService();
        final preferences = _InMemoryPreferencesService();
        final repository = SessionRepository(
          secureStorage: secureStorage,
          preferencesService: preferences,
        );
        final controller = SessionController(repository);
        final tokens = SessionTokens(
          accessToken: 'persisted-access',
          refreshToken: 'persisted-refresh',
          expiresAt: DateTime.utc(2026, 6, 12, 11),
        );
        const userProfile = UserProfile(
          id: 1,
          name: '김민지',
          email: 'minji@example.com',
          onboardingCompleted: false,
        );

        await secureStorage.saveTokens(tokens);
        await preferences.saveActiveJobId('job-123');

        final steps = <String>[];
        final refreshedTokens = SessionTokens(
          accessToken: 'refreshed-access',
          refreshToken: 'refreshed-refresh',
          expiresAt: DateTime.utc(2026, 6, 12, 12),
        );

        final snapshot = await controller.restoreAuthenticatedSession(
          refreshSession: (persistedTokens) async {
            steps.add('refresh');
            expect(persistedTokens, tokens);
            expect(await secureStorage.readTokens(), tokens);
            return refreshedTokens;
          },
          fetchCurrentUser: () async {
            steps.add('fetch-user');
            expect(await secureStorage.readTokens(), refreshedTokens);
            return userProfile;
          },
        );

        expect(snapshot.status, SessionStatus.authenticated);
        expect(snapshot.tokens, refreshedTokens);
        expect(snapshot.activeJobId, 'job-123');
        expect(snapshot.userProfile, userProfile);
        expect(await secureStorage.readTokens(), refreshedTokens);
        expect(steps, <String>['refresh', 'fetch-user']);
      },
    );
  });
}

class _InMemorySecureStorageService implements SecureStorageService {
  SessionTokens? _tokens;

  @override
  Future<void> clearTokens() async {
    _tokens = null;
  }

  @override
  Future<SessionTokens?> readTokens() async => _tokens;

  @override
  Future<void> saveTokens(SessionTokens tokens) async {
    _tokens = tokens;
  }
}

class _InMemoryPreferencesService implements PreferencesService {
  String? _activeJobId;

  @override
  Future<void> clearActiveJobId() async {
    _activeJobId = null;
  }

  @override
  Future<String?> readActiveJobId() async => _activeJobId;

  @override
  Future<void> saveActiveJobId(String jobId) async {
    _activeJobId = jobId;
  }
}
