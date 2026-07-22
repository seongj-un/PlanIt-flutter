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

  // Access the storage sequentially (never via Future.wait). The web
  // implementation of flutter_secure_storage lazily derives its encryption key
  // and deadlocks when concurrent read/write/delete calls race on that
  // initialization, which hangs the auth interceptor before any request is
  // sent. Sequential access is safe on every platform.
  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _expiresAtKey);
  }

  @override
  Future<SessionTokens?> readTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final expiresAtRaw = await _storage.read(key: _expiresAtKey);

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
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
    await _storage.write(
      key: _expiresAtKey,
      value: tokens.expiresAt.toUtc().toIso8601String(),
    );
  }
}
