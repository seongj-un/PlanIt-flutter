import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_config.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

final appRuntimeConfigProvider = Provider<AppRuntimeConfig>((ref) {
  throw UnimplementedError('Override appRuntimeConfigProvider in bootstrap().');
});

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(appRuntimeConfigProvider);
  final router = AppRouter.createRouter();
  ref.onDispose(router.dispose);
  return router;
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

class PlanItApp extends ConsumerWidget {
  const PlanItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'PlanIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}

class AppRuntimeConfig {
  const AppRuntimeConfig({required this.apiConfig});

  factory AppRuntimeConfig.fromEnvironment() {
    return AppRuntimeConfig(apiConfig: ApiConfig.fromEnvironment());
  }

  final ApiConfig apiConfig;
}
