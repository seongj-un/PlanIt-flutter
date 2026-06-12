import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../session/session_tokens.dart';

abstract interface class SecureStorageService {
  Future<SessionTokens?> readTokens();

  Future<void> saveTokens(SessionTokens tokens);

  Future<void> clearTokens();
}

class FlutterSecureStorageService implements SecureStorageService {
  FlutterSecureStorageService(this._storage);

  static const _accessTokenKey = 'session.accessToken';
  static const _refreshTokenKey = 'session.refreshToken';
  static const _expiresAtKey = 'session.expiresAt';

  final FlutterSecureStorage _storage;

  @override
  Future<void> clearTokens() async {
    await Future.wait<void>([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiresAtKey),
    ]);
  }

  @override
  Future<SessionTokens?> readTokens() async {
    final values = await Future.wait<String?>([
      _storage.read(key: _accessTokenKey),
      _storage.read(key: _refreshTokenKey),
      _storage.read(key: _expiresAtKey),
    ]);
    final accessToken = values[0];
    final refreshToken = values[1];
    final expiresAtRaw = values[2];

    if (accessToken == null || refreshToken == null || expiresAtRaw == null) {
      return null;
    }

    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) {
      await clearTokens();
      return null;
    }

    return SessionTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt.toUtc(),
    );
  }

  @override
  Future<void> saveTokens(SessionTokens tokens) async {
    await Future.wait<void>([
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
      _storage.write(
        key: _expiresAtKey,
        value: tokens.expiresAt.toUtc().toIso8601String(),
      ),
    ]);
  }
}
