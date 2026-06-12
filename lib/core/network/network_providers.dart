import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/bootstrap/app_bootstrap.dart';
import '../session/session_controller.dart';
import '../session/session_repository.dart';
import '../storage/preferences_service.dart';
import '../storage/secure_storage_service.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';
import 'refresh_coordinator.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ref.watch(appRuntimeConfigProvider).apiConfig;
});

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return FlutterSecureStorageService(ref.watch(flutterSecureStorageProvider));
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

final preferencesServiceProvider = FutureProvider<PreferencesService>((
  ref,
) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return SharedPreferencesService(preferences);
});

final sessionRepositoryProvider = FutureProvider<SessionRepository>((
  ref,
) async {
  final preferencesService = await ref.watch(preferencesServiceProvider.future);

  return SessionRepository(
    secureStorage: ref.watch(secureStorageServiceProvider),
    preferencesService: preferencesService,
  );
});

final sessionControllerProvider = FutureProvider<SessionController>((
  ref,
) async {
  final repository = await ref.watch(sessionRepositoryProvider.future);
  final controller = SessionController(repository);
  ref.onDispose(controller.dispose);
  return controller;
});

final refreshCoordinatorProvider = Provider<RefreshCoordinator>((ref) {
  return RefreshCoordinator();
});

final refreshDioProvider = FutureProvider<Dio>((ref) async {
  final config = ref.watch(apiConfigProvider);

  return Dio(config.toBaseOptions());
});

final dioProvider = FutureProvider<Dio>((ref) async {
  final config = ref.watch(apiConfigProvider);
  final repository = await ref.watch(sessionRepositoryProvider.future);
  final refreshDio = await ref.watch(refreshDioProvider.future);
  final dio = Dio(config.toBaseOptions());

  dio.interceptors.add(
    AuthInterceptor(
      client: dio,
      refreshClient: refreshDio,
      sessionRepository: repository,
      refreshCoordinator: ref.watch(refreshCoordinatorProvider),
    ),
  );

  return dio;
});

final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final dio = await ref.watch(dioProvider.future);
  return ApiClient(dio);
});
