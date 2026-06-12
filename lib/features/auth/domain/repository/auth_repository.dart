import '../model/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser> login({required String email, required String password});

  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
  });
}
