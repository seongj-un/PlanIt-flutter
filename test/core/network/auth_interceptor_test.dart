import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/error/app_exception.dart';
import 'package:planit_flutter/core/network/api_client.dart';
import 'package:planit_flutter/core/network/api_response.dart';
import 'package:planit_flutter/core/network/auth_interceptor.dart';
import 'package:planit_flutter/core/network/refresh_coordinator.dart';
import 'package:planit_flutter/core/network/session_refresh_service.dart';
import 'package:planit_flutter/core/session/session_repository.dart';
import 'package:planit_flutter/core/session/session_tokens.dart';
import 'package:planit_flutter/core/storage/preferences_service.dart';
import 'package:planit_flutter/core/storage/secure_storage_service.dart';

void main() {
  group('AuthInterceptor', () {
    test('deduplicates refresh across concurrent 401 responses', () async {
      final secureStorage = _InMemorySecureStorageService(
        SessionTokens(
          accessToken: 'expired-access',
          refreshToken: 'refresh-token',
          expiresAt: DateTime.utc(2026, 6, 12, 9),
        ),
      );
      final preferences = _InMemoryPreferencesService();
      final repository = SessionRepository(
        secureStorage: secureStorage,
        preferencesService: preferences,
      );
      final refreshGate = Completer<void>();
      final adapter = _FakeBackendAdapter(
        scenario: _FakeBackendScenario.successAfterRefresh,
        refreshGate: refreshGate,
      );
      final refreshClient = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          client: dio,
          sessionRepository: repository,
          refreshCoordinator: RefreshCoordinator(),
          sessionRefreshService: SessionRefreshService(
            refreshClient: refreshClient,
          ),
        ),
      );
      final apiClient = ApiClient(dio);

      final first = apiClient.get<Map<String, Object?>>(
        '/protected',
        parser: (json) => json as Map<String, Object?>,
      );
      final second = apiClient.get<Map<String, Object?>>(
        '/protected',
        parser: (json) => json as Map<String, Object?>,
      );

      await Future<void>.delayed(Duration.zero);
      if (!refreshGate.isCompleted) {
        refreshGate.complete();
      }

      final responses = await Future.wait<Map<String, Object?>>([
        first,
        second,
      ]);

      expect(responses, [
        {'value': 'ok'},
        {'value': 'ok'},
      ]);
      expect(adapter.refreshRequestCount, 1);
      expect(adapter.protectedRequestAuthHeaders, [
        'Bearer expired-access',
        'Bearer expired-access',
        'Bearer refreshed-access',
        'Bearer refreshed-access',
      ]);
      expect(
        (await repository.restore()).tokens?.accessToken,
        'refreshed-access',
      );
    });

    test('clears session when refresh request fails', () async {
      final harness = _Harness(scenario: _FakeBackendScenario.refreshFails);

      await expectLater(
        harness.apiClient.get<Map<String, Object?>>(
          '/protected',
          parser: _mapParser,
        ),
        throwsA(
          isA<ApiErrorException>().having(
            (e) => e.code,
            'code',
            'REFRESH_REVOKED',
          ),
        ),
      );

      expect((await harness.repository.restore()).tokens, isNull);
      expect(harness.adapter.refreshRequestCount, 1);
    });

    test('clears session when retried request still returns 401', () async {
      final harness = _Harness(
        scenario: _FakeBackendScenario.retryStillUnauthorized,
      );

      await expectLater(
        harness.apiClient.get<Map<String, Object?>>(
          '/protected',
          parser: _mapParser,
        ),
        throwsA(
          isA<ApiErrorException>().having(
            (e) => e.code,
            'code',
            'UNAUTHORIZED',
          ),
        ),
      );

      expect((await harness.repository.restore()).tokens, isNull);
      expect(harness.adapter.refreshRequestCount, 1);
    });

    test(
      'does not attempt refresh when no refresh token is available',
      () async {
        final harness = _Harness(
          scenario: _FakeBackendScenario.successAfterRefresh,
          initialTokens: SessionTokens(
            accessToken: 'expired-access',
            refreshToken: '',
            expiresAt: DateTime.utc(2026, 6, 12, 9),
          ),
        );

        await expectLater(
          harness.apiClient.get<Map<String, Object?>>(
            '/protected',
            parser: _mapParser,
          ),
          throwsA(
            isA<ApiErrorException>().having(
              (e) => e.code,
              'code',
              'UNAUTHORIZED',
            ),
          ),
        );

        expect(harness.adapter.refreshRequestCount, 0);
        expect((await harness.repository.restore()).tokens, isNull);
      },
    );

    test('turns malformed refresh payload into app exception', () async {
      final harness = _Harness(
        scenario: _FakeBackendScenario.malformedRefreshPayload,
      );

      await expectLater(
        harness.apiClient.get<Map<String, Object?>>(
          '/protected',
          parser: _mapParser,
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            'INVALID_API_RESPONSE',
          ),
        ),
      );

      expect(harness.adapter.refreshRequestCount, 1);
      expect((await harness.repository.restore()).tokens, isNull);
    });
  });
}

Map<String, Object?> _mapParser(Object? json) => json as Map<String, Object?>;

class _Harness {
  _Harness({
    required _FakeBackendScenario scenario,
    SessionTokens? initialTokens,
  }) : adapter = _FakeBackendAdapter(scenario: scenario),
       repository = SessionRepository(
         secureStorage: _InMemorySecureStorageService(
           initialTokens ??
               SessionTokens(
                 accessToken: 'expired-access',
                 refreshToken: 'refresh-token',
                 expiresAt: DateTime.utc(2026, 6, 12, 9),
               ),
         ),
         preferencesService: _InMemoryPreferencesService(),
       ),
       refreshClient = Dio(BaseOptions(baseUrl: 'https://api.test')),
       dio = Dio(BaseOptions(baseUrl: 'https://api.test')) {
    refreshClient.httpClientAdapter = adapter;
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        client: dio,
        sessionRepository: repository,
        refreshCoordinator: RefreshCoordinator(),
        sessionRefreshService: SessionRefreshService(
          refreshClient: refreshClient,
        ),
      ),
    );
    apiClient = ApiClient(dio);
  }

  final _FakeBackendAdapter adapter;
  final SessionRepository repository;
  final Dio refreshClient;
  final Dio dio;
  late final ApiClient apiClient;
}

enum _FakeBackendScenario {
  successAfterRefresh,
  refreshFails,
  retryStillUnauthorized,
  malformedRefreshPayload,
}

class _InMemorySecureStorageService implements SecureStorageService {
  _InMemorySecureStorageService(this._tokens);

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
  @override
  Future<void> clearActiveJobId() async {}

  @override
  Future<String?> readActiveJobId() async => null;

  @override
  Future<void> saveActiveJobId(String jobId) async {}
}

class _FakeBackendAdapter implements HttpClientAdapter {
  _FakeBackendAdapter({required this.scenario, Completer<void>? refreshGate})
    : refreshGate = refreshGate ?? Completer<void>()
        ..complete();

  final _FakeBackendScenario scenario;
  final Completer<void> refreshGate;
  final List<String?> protectedRequestAuthHeaders = <String?>[];
  int refreshRequestCount = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/protected') {
      final authHeader = options.headers['Authorization'] as String?;
      protectedRequestAuthHeaders.add(authHeader);

      if (authHeader == 'Bearer refreshed-access' &&
          scenario == _FakeBackendScenario.successAfterRefresh) {
        return _jsonResponse(200, {
          'success': true,
          'data': {'value': 'ok'},
        });
      }

      return _jsonResponse(401, {
        'success': false,
        'error': {'code': 'UNAUTHORIZED', 'message': 'Access token expired.'},
      });
    }

    if (options.path == '/auth/refresh') {
      refreshRequestCount += 1;
      await refreshGate.future;

      if (scenario == _FakeBackendScenario.refreshFails) {
        return _jsonResponse(401, {
          'success': false,
          'error': {
            'code': 'REFRESH_REVOKED',
            'message': 'Refresh token is no longer valid.',
          },
        });
      }

      if (scenario == _FakeBackendScenario.malformedRefreshPayload) {
        return _jsonResponse(200, {
          'success': true,
          'data': {'expiresIn': 'oops'},
        });
      }

      return _jsonResponse(200, {
        'success': true,
        'data': {'accessToken': 'refreshed-access', 'expiresIn': 3600},
      });
    }

    throw UnsupportedError('Unhandled path ${options.path}');
  }

  ResponseBody _jsonResponse(int statusCode, Map<String, Object?> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }
}
