import '../storage/preferences_service.dart';
import '../storage/secure_storage_service.dart';
import 'session_snapshot.dart';
import 'session_tokens.dart';

class SessionRepository {
  SessionRepository({
    required SecureStorageService secureStorage,
    required PreferencesService preferencesService,
  }) : _secureStorage = secureStorage,
       _preferencesService = preferencesService;

  final SecureStorageService _secureStorage;
  final PreferencesService _preferencesService;

  Future<void> clear() async {
    await Future.wait<void>([
      _secureStorage.clearTokens(),
      _preferencesService.clearActiveJobId(),
    ]);
  }

  Future<String?> readActiveJobId() {
    return _preferencesService.readActiveJobId();
  }

  Future<SessionTokens?> readTokens() {
    return _secureStorage.readTokens();
  }

  Future<SessionSnapshot> restore() async {
    final values = await Future.wait<Object?>([
      _secureStorage.readTokens(),
      _preferencesService.readActiveJobId(),
    ]);

    return SessionSnapshot(
      tokens: values[0] as SessionTokens?,
      activeJobId: values[1] as String?,
    );
  }

  Future<void> save({
    required SessionTokens tokens,
    String? activeJobId,
  }) async {
    await _secureStorage.saveTokens(tokens);

    if (activeJobId == null || activeJobId.isEmpty) {
      await _preferencesService.clearActiveJobId();
      return;
    }

    await _preferencesService.saveActiveJobId(activeJobId);
  }

  Future<void> saveActiveJobId(String jobId) {
    return _preferencesService.saveActiveJobId(jobId);
  }

  Future<void> saveTokens(SessionTokens tokens) {
    return _secureStorage.saveTokens(tokens);
  }
}
