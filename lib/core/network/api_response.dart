import '../error/app_exception.dart';
import '../../shared/models/api_field_error.dart';

typedef JsonParser<T> = T Function(Object? json);

class ApiResponse<T> {
  const ApiResponse({required this.success, this.data, this.error, this.meta});

  factory ApiResponse.fromJson(
    Map<String, Object?> json, {
    JsonParser<T>? dataParser,
  }) {
    final rawSuccess = json['success'];
    if (rawSuccess is! bool) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Response is missing a boolean success flag.',
      );
    }

    final rawData = json['data'];
    final rawError = json['error'];
    final rawMeta = json['meta'];
    Map<String, Object?>? meta;

    if (rawMeta != null) {
      if (rawMeta is! Map) {
        throw const AppException(
          code: 'INVALID_API_RESPONSE',
          message: 'Response meta must be a JSON object when present.',
        );
      }
      meta = Map<String, Object?>.from(rawMeta);
    }

    return ApiResponse<T>(
      success: rawSuccess,
      data: rawSuccess ? _parseData(rawData, dataParser) : null,
      error: rawSuccess ? null : _parseError(rawError),
      meta: meta,
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

T? _parseData<T>(Object? rawData, JsonParser<T>? dataParser) {
  if (dataParser == null) {
    try {
      return rawData as T?;
    } catch (error) {
      throw AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Response data had an unexpected shape.',
        cause: error,
      );
    }
  }

  try {
    return dataParser(rawData);
  } catch (error) {
    throw AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Response data could not be parsed.',
      cause: error,
    );
  }
}

ApiErrorPayload _parseError(Object? rawError) {
  if (rawError is! Map) {
    throw const AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Failed API responses must include an error object.',
    );
  }

  try {
    return ApiErrorPayload.fromJson(Map<String, Object?>.from(rawError));
  } catch (error) {
    if (error is AppException) {
      rethrow;
    }

    throw AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Response error payload could not be parsed.',
      cause: error,
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
    final rawCode = json['code'];
    final rawMessage = json['message'];
    if (rawCode is! String || rawCode.isEmpty) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Error payload is missing a valid code.',
      );
    }
    if (rawMessage is! String || rawMessage.isEmpty) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Error payload is missing a valid message.',
      );
    }

    final rawFieldErrors = json['fieldErrors'];

    return ApiErrorPayload(
      code: rawCode,
      message: rawMessage,
      fieldErrors: _parseFieldErrors(rawFieldErrors),
    );
  }

  final String code;
  final String message;
  final List<ApiFieldError> fieldErrors;
}

List<ApiFieldError> _parseFieldErrors(Object? rawFieldErrors) {
  if (rawFieldErrors == null) {
    return const <ApiFieldError>[];
  }

  if (rawFieldErrors is! List) {
    throw const AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'fieldErrors must be a list when present.',
    );
  }

  return rawFieldErrors
      .map<ApiFieldError>((item) {
        if (item is! Map) {
          throw const AppException(
            code: 'INVALID_API_RESPONSE',
            message: 'fieldErrors entries must be JSON objects.',
          );
        }

        return ApiFieldError.fromJson(Map<String, Object?>.from(item));
      })
      .toList(growable: false);
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
