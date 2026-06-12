import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../session/session_repository.dart';
import '../session/session_tokens.dart';
import 'api_response.dart';
import 'refresh_coordinator.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio client,
    required Dio refreshClient,
    required SessionRepository sessionRepository,
    required RefreshCoordinator refreshCoordinator,
  }) : _client = client,
       _refreshClient = refreshClient,
       _sessionRepository = sessionRepository,
       _refreshCoordinator = refreshCoordinator;

  static const _retryKey = 'auth.retry';

  final Dio _client;
  final Dio _refreshClient;
  final SessionRepository _sessionRepository;
  final RefreshCoordinator _refreshCoordinator;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;
    if (statusCode != 401 ||
        _shouldSkipRefresh(requestOptions) ||
        requestOptions.extra[_retryKey] == true) {
      if (statusCode == 401 && requestOptions.extra[_retryKey] == true) {
        await _sessionRepository.clear();
      }
      handler.next(err);
      return;
    }

    final existingTokens = await _sessionRepository.readTokens();
    final refreshToken = existingTokens?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _sessionRepository.clear();
      handler.next(err);
      return;
    }

    try {
      await _refreshCoordinator.run(() async {
        final latestTokens = await _sessionRepository.readTokens();
        final latestRefreshToken = latestTokens?.refreshToken ?? refreshToken;
        final refreshedTokens = await _refreshTokens(latestRefreshToken);
        await _sessionRepository.saveTokens(refreshedTokens);
      });

      final refreshedTokens = await _sessionRepository.readTokens();
      final accessToken = refreshedTokens?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw const AppException(
          code: 'TOKEN_REFRESH_FAILED',
          message: 'Refresh completed without a usable access token.',
        );
      }

      final retryOptions = requestOptions.copyWith(
        headers: <String, Object?>{
          ...requestOptions.headers,
          'Authorization': 'Bearer $accessToken',
        },
        extra: <String, Object?>{...requestOptions.extra, _retryKey: true},
      );
      final response = await _client.fetch<Object?>(retryOptions);
      handler.resolve(response);
    } catch (error) {
      await _sessionRepository.clear();
      handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: error,
          response: err.response,
          type: err.type,
          message: error is AppException
              ? error.message
              : 'Token refresh failed.',
        ),
      );
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_shouldAttachToken(options)) {
      handler.next(options);
      return;
    }

    final tokens = await _sessionRepository.readTokens();
    final accessToken = tokens?.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  Future<SessionTokens> _refreshTokens(String refreshToken) async {
    final response = await _refreshClient.post<Object?>(
      '/auth/refresh',
      data: <String, Object?>{'refreshToken': refreshToken},
    );
    final body = response.data;
    if (body is! Map<String, Object?>) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Refresh response body is not a valid API envelope.',
      );
    }

    final apiResponse = ApiResponse<Map<String, Object?>>.fromJson(
      body,
      dataParser: (json) => json as Map<String, Object?>,
    );
    final data = apiResponse.requireData();
    final accessToken = data['accessToken'] as String? ?? '';
    final nextRefreshToken = data['refreshToken'] as String? ?? refreshToken;
    final expiresIn = data['expiresIn'] as num? ?? 0;

    return SessionTokens(
      accessToken: accessToken,
      refreshToken: nextRefreshToken,
      expiresAt: DateTime.now().toUtc().add(
        Duration(seconds: expiresIn.toInt()),
      ),
    );
  }

  bool _shouldAttachToken(RequestOptions options) {
    return options.headers.containsKey('Authorization') == false &&
        _shouldSkipRefresh(options) == false;
  }

  bool _shouldSkipRefresh(RequestOptions options) {
    return options.path == '/auth/refresh';
  }
}
