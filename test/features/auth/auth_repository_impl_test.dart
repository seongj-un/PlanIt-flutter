import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/session/session_controller.dart';
import 'package:planit_flutter/core/session/session_repository.dart';
import 'package:planit_flutter/core/session/session_tokens.dart';
import 'package:planit_flutter/core/storage/preferences_service.dart';
import 'package:planit_flutter/core/storage/secure_storage_service.dart';
import 'package:planit_flutter/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:planit_flutter/features/auth/data/dto/auth_response_dto.dart';
import 'package:planit_flutter/features/auth/data/dto/login_request_dto.dart';
import 'package:planit_flutter/features/auth/data/dto/signup_request_dto.dart';
import 'package:planit_flutter/features/auth/data/repository/auth_repository_impl.dart';
import 'package:planit_flutter/features/my_page/domain/model/user_profile.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('login persists session tokens with expiresIn conversion', () async {
      final remoteDataSource = _FakeAuthRemoteDataSource(
        loginResponse: AuthResponseDto.fromJson(const {
          'user': {'id': 1, 'name': '김민지', 'onboardingCompleted': true},
          'tokens': {
            'accessToken': 'login-access-token',
            'refreshToken': 'login-refresh-token',
            'expiresIn': 3600,
          },
        }),
      );
      final secureStorage = _InMemorySecureStorageService();
      final preferences = _InMemoryPreferencesService();
      await preferences.saveActiveJobId('job-123');
      final controller = SessionController(
        SessionRepository(
          secureStorage: secureStorage,
          preferencesService: preferences,
        ),
      );
      await controller.saveActiveJobId('job-123');
      final repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
        sessionController: controller,
        now: () => DateTime.utc(2026, 6, 12, 0, 0, 0),
      );

      await repository.login(email: 'minji@example.com', password: 'P@ssw0rd!');

      expect(remoteDataSource.lastLoginRequest?.email, 'minji@example.com');
      expect(
        controller.state.tokens,
        SessionTokens(
          accessToken: 'login-access-token',
          refreshToken: 'login-refresh-token',
          expiresAt: DateTime.utc(2026, 6, 12, 1, 0, 0),
        ),
      );
      expect(
        controller.state.userProfile,
        const UserProfile(
          id: 1,
          name: '김민지',
          email: null,
          onboardingCompleted: true,
        ),
      );
      expect(controller.state.activeJobId, 'job-123');
      expect(await secureStorage.readTokens(), controller.state.tokens);
    });

    test('signup persists session tokens and returns the auth user', () async {
      final remoteDataSource = _FakeAuthRemoteDataSource(
        signupResponse: AuthResponseDto.fromJson(const {
          'user': {
            'id': 2,
            'name': '김민지',
            'email': 'minji@example.com',
            'onboardingCompleted': false,
          },
          'tokens': {
            'accessToken': 'signup-access-token',
            'refreshToken': 'signup-refresh-token',
            'expiresIn': 1800,
          },
        }),
      );
      final controller = SessionController(
        SessionRepository(
          secureStorage: _InMemorySecureStorageService(),
          preferencesService: _InMemoryPreferencesService(),
        ),
      );
      final repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
        sessionController: controller,
        now: () => DateTime.utc(2026, 6, 12, 3, 0, 0),
      );

      final user = await repository.signup(
        name: '김민지',
        email: 'minji@example.com',
        password: 'P@ssw0rd!',
      );

      expect(remoteDataSource.lastSignupRequest?.name, '김민지');
      expect(user.id, 2);
      expect(user.onboardingCompleted, isFalse);
      expect(
        controller.state.tokens,
        SessionTokens(
          accessToken: 'signup-access-token',
          refreshToken: 'signup-refresh-token',
          expiresAt: DateTime.utc(2026, 6, 12, 3, 30, 0),
        ),
      );
      expect(
        controller.state.userProfile,
        const UserProfile(
          id: 2,
          name: '김민지',
          email: 'minji@example.com',
          onboardingCompleted: false,
        ),
      );
    });
  });
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  _FakeAuthRemoteDataSource({this.loginResponse, this.signupResponse});

  final AuthResponseDto? loginResponse;
  final AuthResponseDto? signupResponse;
  LoginRequestDto? lastLoginRequest;
  SignupRequestDto? lastSignupRequest;

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    lastLoginRequest = request;
    return loginResponse!;
  }

  @override
  Future<AuthResponseDto> signup(SignupRequestDto request) async {
    lastSignupRequest = request;
    return signupResponse!;
  }
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
