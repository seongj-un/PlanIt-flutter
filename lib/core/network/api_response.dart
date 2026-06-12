import '../error/app_exception.dart';
import '../../shared/models/api_field_error.dart';

typedef JsonParser<T> = T Function(Object? json);

class ApiResponse<T> {
  const ApiResponse({required this.success, this.data, this.error, this.meta});

  factory ApiResponse.fromJson(
    Map<String, Object?> json, {
    JsonParser<T>? dataParser,
  }) {
    final success = json['success'] == true;
    final rawData = json['data'];
    final rawError = json['error'];

    return ApiResponse<T>(
      success: success,
      data: success && dataParser != null ? dataParser(rawData) : rawData as T?,
      error: rawError is Map<String, Object?>
          ? ApiErrorPayload.fromJson(rawError)
          : null,
      meta: json['meta'] as Map<String, Object?>?,
    );
  }

  final bool success;
  final T? data;
  final ApiErrorPayload? error;
  final Map<String, Object?>? meta;

  T requireData() {
    if (success && data != null) {
      return data as T;
    }

    throw ApiErrorException.fromPayload(
      error ??
          const ApiErrorPayload(
            code: 'INVALID_API_RESPONSE',
            message: 'Response body did not contain data.',
          ),
    );
  }
}

class ApiErrorPayload {
  const ApiErrorPayload({
    required this.code,
    required this.message,
    this.fieldErrors = const <ApiFieldError>[],
  });

  factory ApiErrorPayload.fromJson(Map<String, Object?> json) {
    final rawFieldErrors = json['fieldErrors'];

    return ApiErrorPayload(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'Unknown error',
      fieldErrors: rawFieldErrors is List
          ? rawFieldErrors
                .whereType<Map<String, Object?>>()
                .map(ApiFieldError.fromJson)
                .toList(growable: false)
          : const <ApiFieldError>[],
    );
  }

  final String code;
  final String message;
  final List<ApiFieldError> fieldErrors;
}

class ApiErrorException extends AppException {
  const ApiErrorException({
    required super.message,
    required super.code,
    this.fieldErrors = const <ApiFieldError>[],
    super.cause,
  });

  factory ApiErrorException.fromPayload(
    ApiErrorPayload payload, {
    Object? cause,
  }) {
    return ApiErrorException(
      message: payload.message,
      code: payload.code,
      fieldErrors: payload.fieldErrors,
      cause: cause,
    );
  }

  final List<ApiFieldError> fieldErrors;
}
