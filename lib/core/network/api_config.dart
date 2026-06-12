import 'package:dio/dio.dart';

class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
  });

  factory ApiConfig.fromEnvironment() {
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

    if (configuredBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is not configured. Pass it with --dart-define=API_BASE_URL=<value>.',
      );
    }

    return const ApiConfig(baseUrl: configuredBaseUrl);
  }

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  BaseOptions toBaseOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      responseType: ResponseType.json,
      headers: const <String, Object?>{
        Headers.contentTypeHeader: Headers.jsonContentType,
      },
    );
  }
}
