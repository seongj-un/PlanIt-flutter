import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PreferencesService {
  Future<String?> readActiveJobId();

  Future<void> saveActiveJobId(String jobId);

  Future<void> clearActiveJobId();
}

class SharedPreferencesService implements PreferencesService {
  SharedPreferencesService(this._preferences);

  static const _activeJobIdKey = 'session.activeJobId';

  final SharedPreferences _preferences;

  @override
  Future<void> clearActiveJobId() async {
    await _preferences.remove(_activeJobIdKey);
  }

  @override
  Future<String?> readActiveJobId() async {
    return _preferences.getString(_activeJobIdKey);
  }

  @override
  Future<void> saveActiveJobId(String jobId) async {
    await _preferences.setString(_activeJobIdKey, jobId);
  }
}
