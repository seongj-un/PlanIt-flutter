import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/app/router/app_redirect_logic.dart';
import 'package:planit_flutter/core/session/session_snapshot.dart';
import 'package:planit_flutter/core/session/session_tokens.dart';
import 'package:planit_flutter/features/my_page/domain/model/user_profile.dart';

void main() {
  group('AppRedirectLogic', () {
    test('redirects splash to home after automatic login succeeds', () {
      final redirect = AppRedirectLogic.resolve(
        location: '/',
        session: SessionSnapshot(
          status: SessionStatus.authenticated,
          tokens: _tokens,
          userProfile: const UserProfile(
            id: 1,
            name: '김민지',
            email: 'minji@example.com',
            onboardingCompleted: true,
          ),
        ),
      );

      expect(redirect, '/home');
    });

    test('redirects splash to welcome after automatic login fails', () {
      final redirect = AppRedirectLogic.resolve(
        location: '/',
        session: const SessionSnapshot(status: SessionStatus.unauthenticated),
      );

      expect(redirect, '/welcome');
    });

    test('redirects authenticated users with incomplete onboarding', () {
      final redirect = AppRedirectLogic.resolve(
        location: '/home',
        session: SessionSnapshot(
          status: SessionStatus.authenticated,
          tokens: _tokens,
          userProfile: const UserProfile(
            id: 1,
            name: '김민지',
            email: 'minji@example.com',
            onboardingCompleted: false,
          ),
        ),
      );

      expect(redirect, '/study-profile');
    });

    test(
      'redirects incomplete onboarding with active job id to plan generation loading',
      () {
        final redirect = AppRedirectLogic.resolve(
          location: '/exam-plan',
          session: SessionSnapshot(
            status: SessionStatus.authenticated,
            tokens: _tokens,
            activeJobId: 'job-123',
            userProfile: const UserProfile(
              id: 1,
              name: '김민지',
              email: 'minji@example.com',
              onboardingCompleted: false,
            ),
          ),
        );

        expect(redirect, '/plan-generation-loading');
      },
    );

    test('allows incomplete onboarding users to stay on exam plan route', () {
      final redirect = AppRedirectLogic.resolve(
        location: '/exam-plan',
        session: SessionSnapshot(
          status: SessionStatus.authenticated,
          tokens: _tokens,
          userProfile: const UserProfile(
            id: 1,
            name: '김민지',
            email: 'minji@example.com',
            onboardingCompleted: false,
          ),
        ),
      );

      expect(redirect, isNull);
    });

    test(
      'allows incomplete onboarding users to stay on subject scope route',
      () {
        final redirect = AppRedirectLogic.resolve(
          location: '/subject-scope',
          session: SessionSnapshot(
            status: SessionStatus.authenticated,
            tokens: _tokens,
            userProfile: const UserProfile(
              id: 1,
              name: '김민지',
              email: 'minji@example.com',
              onboardingCompleted: false,
            ),
          ),
        );

        expect(redirect, isNull);
      },
    );

    test(
      'allows incomplete onboarding users to stay on plan generation loading route before job id exists',
      () {
        final redirect = AppRedirectLogic.resolve(
          location: '/plan-generation-loading',
          session: SessionSnapshot(
            status: SessionStatus.authenticated,
            tokens: _tokens,
            userProfile: const UserProfile(
              id: 1,
              name: '김민지',
              email: 'minji@example.com',
              onboardingCompleted: false,
            ),
          ),
        );

        expect(redirect, isNull);
      },
    );

    test('redirects authenticated users away from auth routes to home', () {
      final redirect = AppRedirectLogic.resolve(
        location: '/login',
        session: SessionSnapshot(
          status: SessionStatus.authenticated,
          tokens: _tokens,
          userProfile: const UserProfile(
            id: 1,
            name: '김민지',
            email: 'minji@example.com',
            onboardingCompleted: true,
          ),
        ),
      );

      expect(redirect, '/home');
    });

    test('keeps restore-failed users with a session on splash', () {
      final redirect = AppRedirectLogic.resolve(
        location: '/',
        session: SessionSnapshot(
          status: SessionStatus.restoreFailed,
          tokens: _tokens,
        ),
      );

      expect(redirect, isNull);
    });
  });
}

final _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  expiresAt: DateTime.utc(2026, 6, 12, 12),
);
