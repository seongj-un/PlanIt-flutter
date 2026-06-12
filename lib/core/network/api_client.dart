import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import 'api_response.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> delete<T>(
    String path, {
    Object? data,
    JsonParser<T>? parser,
    Map<String, Object?>? queryParameters,
    Options? options,
  }) {
    return _request(
      path,
      method: 'DELETE',
      data: data,
      parser: parser,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<T> get<T>(
    String path, {
    required JsonParser<T> parser,
    Map<String, Object?>? queryParameters,
    Options? options,
  }) {
    return _request(
      path,
      method: 'GET',
      parser: parser,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<T> patch<T>(
    String path, {
    Object? data,
    required JsonParser<T> parser,
    Map<String, Object?>? queryParameters,
    Options? options,
  }) {
    return _request(
      path,
      method: 'PATCH',
      data: data,
      parser: parser,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    required JsonParser<T> parser,
    Map<String, Object?>? queryParameters,
    Options? options,
  }) {
    return _request(
      path,
      method: 'POST',
      data: data,
      parser: parser,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    required JsonParser<T> parser,
    Map<String, Object?>? queryParameters,
    Options? options,
  }) {
    return _request(
      path,
      method: 'PUT',
      data: data,
      parser: parser,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<T> _request<T>(
    String path, {
    required String method,
    Object? data,
    JsonParser<T>? parser,
    Map<String, Object?>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(method: method),
      );

      if (response.statusCode == 204) {
        return (null as T);
      }

      final body = response.data;
      if (body is! Map<String, Object?>) {
        throw const AppException(
          code: 'INVALID_API_RESPONSE',
          message: 'Response body is not a valid API envelope.',
        );
      }

      final apiResponse = ApiResponse<T>.fromJson(body, dataParser: parser);
      return apiResponse.requireData();
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    final nestedError = error.error;
    if (nestedError is AppException) {
      return nestedError;
    }

    final data = error.response?.data;
    if (data is Map<String, Object?>) {
      try {
        final apiResponse = ApiResponse<Object?>.fromJson(data);
        final payload = apiResponse.error;
        if (payload != null) {
          return ApiErrorException.fromPayload(payload, cause: error);
        }
      } on AppException catch (appException) {
        return appException;
      }
    }

    return AppException(
      code: error.response?.statusCode?.toString(),
      message: error.message ?? 'Network request failed.',
      cause: error,
    );
  }
}
