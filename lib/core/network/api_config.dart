class ApiConfig {
  const ApiConfig({required this.baseUrl});

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
}
