import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../session/session_repository.dart';
import 'refresh_coordinator.dart';
import 'session_refresh_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio client,
    required SessionRepository sessionRepository,
    required RefreshCoordinator refreshCoordinator,
    required SessionRefreshService sessionRefreshService,
  }) : _client = client,
       _sessionRepository = sessionRepository,
       _refreshCoordinator = refreshCoordinator,
       _sessionRefreshService = sessionRefreshService;

  static const _retryKey = 'auth.retry';

  final Dio _client;
  final SessionRepository _sessionRepository;
  final RefreshCoordinator _refreshCoordinator;
  final SessionRefreshService _sessionRefreshService;

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
        final refreshedTokens = await _sessionRefreshService.refresh(
          refreshToken: latestRefreshToken,
        );
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
    } on AppException catch (error) {
      await _sessionRepository.clear();
      handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: error,
          response: err.response,
          type: err.type,
          message: error.message,
        ),
      );
    } catch (error) {
      await _sessionRepository.clear();
      handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: error,
          response: err.response,
          type: err.type,
          message: 'Token refresh failed.',
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

  bool _shouldAttachToken(RequestOptions options) {
    return options.headers.containsKey('Authorization') == false &&
        _shouldSkipRefresh(options) == false;
  }

  bool _shouldSkipRefresh(RequestOptions options) {
    return _normalizePath(options.path) == SessionRefreshService.refreshPath;
  }

  String _normalizePath(String path) {
    final parsed = Uri.tryParse(path);
    if (parsed != null && parsed.hasScheme) {
      return parsed.path;
    }

    return Uri.parse(path).path;
  }
}
