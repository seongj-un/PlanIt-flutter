import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../session/session_tokens.dart';
import 'api_response.dart';

class SessionRefreshService {
  SessionRefreshService({required Dio refreshClient, DateTime Function()? now})
    : _refreshClient = refreshClient,
      _now = now ?? DateTime.now;

  static const refreshPath = '/auth/refresh';

  final Dio _refreshClient;
  final DateTime Function() _now;

  Future<SessionTokens> refresh({required String refreshToken}) async {
    final response = await _refreshClient.post<Object?>(
      refreshPath,
      data: <String, Object?>{'refreshToken': refreshToken},
      options: Options(validateStatus: (_) => true),
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
    if (apiResponse.success == false) {
      throw ApiErrorException.fromPayload(
        apiResponse.error ??
            const ApiErrorPayload(
              code: 'INVALID_API_RESPONSE',
              message: 'Refresh response did not include an error payload.',
            ),
      );
    }

    final data = apiResponse.requireData();
    final accessToken = _requireString(
      data,
      key: 'accessToken',
      message: 'Refresh response is missing accessToken.',
    );
    final nextRefreshToken =
        _readOptionalString(data, key: 'refreshToken') ?? refreshToken;
    final expiresIn = _requireIntSeconds(
      data,
      key: 'expiresIn',
      message: 'Refresh response is missing expiresIn.',
    );

    return SessionTokens(
      accessToken: accessToken,
      refreshToken: nextRefreshToken,
      expiresAt: _now().toUtc().add(Duration(seconds: expiresIn)),
    );
  }

  String _requireString(
    Map<String, Object?> json, {
    required String key,
    required String message,
  }) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }

    throw AppException(code: 'INVALID_API_RESPONSE', message: message);
  }

  String? _readOptionalString(
    Map<String, Object?> json, {
    required String key,
  }) {
    final value = json[key];
    if (value == null) {
      return null;
    }
    if (value is String && value.isNotEmpty) {
      return value;
    }

    throw AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Refresh response field $key had an unexpected type.',
    );
  }

  int _requireIntSeconds(
    Map<String, Object?> json, {
    required String key,
    required String message,
  }) {
    final value = json[key];
    if (value is num) {
      return value.toInt();
    }

    throw AppException(code: 'INVALID_API_RESPONSE', message: message);
  }
}
