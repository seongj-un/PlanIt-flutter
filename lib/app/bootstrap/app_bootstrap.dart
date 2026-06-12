import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_config.dart';
import '../../core/network/network_providers.dart';
import '../../features/my_page/data/repository/user_repository_impl.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

final appRuntimeConfigProvider = Provider<AppRuntimeConfig>((ref) {
  throw UnimplementedError('Override appRuntimeConfigProvider in bootstrap().');
});

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(appRuntimeConfigProvider);
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(sessionControllerProvider, (_, __) {
    refreshNotifier.value++;
  });
  ref.onDispose(refreshNotifier.dispose);

  Future<void>.microtask(() {
    unawaited(
      ref
          .read(sessionControllerProvider.notifier)
          .restoreAuthenticatedSession(
            fetchCurrentUser: ref.read(userRepositoryProvider).getCurrentUser,
          ),
    );
  });

  final router = AppRouter.createRouter(
    refreshListenable: refreshNotifier,
    sessionSnapshotProvider: () => ref.read(sessionControllerProvider),
  );
  ref.onDispose(router.dispose);
  return router;
});

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final runtimeConfig = AppRuntimeConfig.fromEnvironment();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appRuntimeConfigProvider.overrideWithValue(runtimeConfig),
        sharedPreferencesInstanceProvider.overrideWithValue(sharedPreferences),
      ],
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
