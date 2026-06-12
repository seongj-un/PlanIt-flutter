import '../../../../core/error/app_exception.dart';
import '../../../../core/session/session_tokens.dart';
import '../../domain/model/auth_user.dart';

class AuthResponseDto {
  const AuthResponseDto._(this._user, this._tokens);

  factory AuthResponseDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Auth response payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);

    return AuthResponseDto._(
      _AuthUserDto.fromJson(map['user']),
      _AuthTokensDto.fromJson(map['tokens']),
    );
  }

  final _AuthUserDto _user;
  final _AuthTokensDto _tokens;

  AuthUser toDomain() => _user.toDomain();

  SessionTokens toSessionTokens(DateTime issuedAtUtc) {
    return _tokens.toSessionTokens(issuedAtUtc);
  }
}

class _AuthUserDto {
  const _AuthUserDto({
    required this.id,
    required this.name,
    this.email,
    required this.onboardingCompleted,
  });

  factory _AuthUserDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Auth user payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    final id = map['id'];
    final name = map['name'];
    final onboardingCompleted = map['onboardingCompleted'];

    if (id is! int ||
        name is! String ||
        name.isEmpty ||
        onboardingCompleted is! bool) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Auth user payload is missing required fields.',
      );
    }

    final rawEmail = map['email'];

    return _AuthUserDto(
      id: id,
      name: name,
      email: rawEmail is String && rawEmail.isNotEmpty ? rawEmail : null,
      onboardingCompleted: onboardingCompleted,
    );
  }

  final int id;
  final String name;
  final String? email;
  final bool onboardingCompleted;

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      onboardingCompleted: onboardingCompleted,
    );
  }
}

class _AuthTokensDto {
  const _AuthTokensDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory _AuthTokensDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Auth tokens payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    final accessToken = map['accessToken'];
    final refreshToken = map['refreshToken'];
    final expiresIn = map['expiresIn'];

    if (accessToken is! String ||
        accessToken.isEmpty ||
        refreshToken is! String ||
        refreshToken.isEmpty ||
        expiresIn is! int) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Auth tokens payload is missing required fields.',
      );
    }

    return _AuthTokensDto(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );
  }

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  SessionTokens toSessionTokens(DateTime issuedAtUtc) {
    return SessionTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: issuedAtUtc.add(Duration(seconds: expiresIn)),
    );
  }
}
