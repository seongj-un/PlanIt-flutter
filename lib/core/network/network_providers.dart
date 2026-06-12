import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/bootstrap/app_bootstrap.dart';
import '../session/session_controller.dart';
import '../session/session_repository.dart';
import '../session/session_snapshot.dart';
import '../storage/preferences_service.dart';
import '../storage/secure_storage_service.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';
import 'refresh_coordinator.dart';
import 'session_refresh_service.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ref.watch(appRuntimeConfigProvider).apiConfig;
});

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return FlutterSecureStorageService(ref.watch(flutterSecureStorageProvider));
});

final sharedPreferencesInstanceProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Override sharedPreferencesInstanceProvider during app bootstrap.',
  );
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return SharedPreferencesService(ref.watch(sharedPreferencesInstanceProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    secureStorage: ref.watch(secureStorageServiceProvider),
    preferencesService: ref.watch(preferencesServiceProvider),
  );
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionSnapshot>((ref) {
      return SessionController(ref.watch(sessionRepositoryProvider));
    });

final sessionControllerNotifierProvider = Provider<SessionController>((ref) {
  return ref.watch(sessionControllerProvider.notifier);
});

final refreshCoordinatorProvider = Provider<RefreshCoordinator>((ref) {
  return RefreshCoordinator();
});

final refreshDioProvider = Provider<Dio>((ref) {
  return Dio(ref.watch(apiConfigProvider).toBaseOptions());
});

final sessionRefreshServiceProvider = Provider<SessionRefreshService>((ref) {
  return SessionRefreshService(refreshClient: ref.watch(refreshDioProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(apiConfigProvider);
  final repository = ref.watch(sessionRepositoryProvider);
  final dio = Dio(config.toBaseOptions());

  dio.interceptors.add(
    AuthInterceptor(
      client: dio,
      sessionRepository: repository,
      refreshCoordinator: ref.watch(refreshCoordinatorProvider),
      sessionRefreshService: ref.watch(sessionRefreshServiceProvider),
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
