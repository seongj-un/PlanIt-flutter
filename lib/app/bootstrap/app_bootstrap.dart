import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import '../theme/app_theme.dart';

const _defaultApiBaseUrl = 'http://localhost:8080';

final appRuntimeConfigProvider = Provider<AppRuntimeConfig>((ref) {
  throw UnimplementedError('Override appRuntimeConfigProvider in bootstrap().');
});

void bootstrap() {
  final runtimeConfig = AppRuntimeConfig.fromEnvironment();

  runApp(
    ProviderScope(
      overrides: [appRuntimeConfigProvider.overrideWithValue(runtimeConfig)],
      child: const PlanItApp(),
    ),
  );
}

class PlanItApp extends StatelessWidget {
  const PlanItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PlanIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: AppRouter.createRouter(),
    );
  }
}

class AppRuntimeConfig {
  const AppRuntimeConfig({required this.apiConfig});

  factory AppRuntimeConfig.fromEnvironment() {
    return const AppRuntimeConfig(apiConfig: ApiConfig.fromEnvironment());
  }

  final ApiConfig apiConfig;
}

class ApiConfig {
  const ApiConfig({required this.baseUrl});

  const ApiConfig.fromEnvironment()
    : baseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: _defaultApiBaseUrl,
      );

  final String baseUrl;
}
