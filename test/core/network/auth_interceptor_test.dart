import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/network/api_client.dart';
import 'package:planit_flutter/core/network/auth_interceptor.dart';
import 'package:planit_flutter/core/network/refresh_coordinator.dart';
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
      final adapter = _FakeBackendAdapter(refreshGate: refreshGate);
      final refreshClient = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
      dio.interceptors.add(
        AuthInterceptor(
          client: dio,
          sessionRepository: repository,
          refreshCoordinator: RefreshCoordinator(),
          refreshClient: refreshClient,
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
      refreshGate.complete();

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
  });
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
  _FakeBackendAdapter({required this.refreshGate});

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

      if (authHeader == 'Bearer refreshed-access') {
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
