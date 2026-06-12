import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/session/session_controller.dart';
import '../../../my_page/domain/model/user_profile.dart';
import '../../domain/model/auth_user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_data_source.dart';
import '../dto/auth_response_dto.dart';
import '../dto/login_request_dto.dart';
import '../dto/signup_request_dto.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    sessionController: ref.watch(sessionControllerNotifierProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SessionController sessionController,
    DateTime Function()? now,
  }) : _remoteDataSource = remoteDataSource,
       _sessionController = sessionController,
       _now = now ?? DateTime.now;

  final AuthRemoteDataSource _remoteDataSource;
  final SessionController _sessionController;
  final DateTime Function() _now;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      LoginRequestDto(email: email, password: password),
    );

    await _persistSession(response);
    return response.toDomain();
  }

  @override
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.signup(
      SignupRequestDto(name: name, email: email, password: password),
    );

    await _persistSession(response);
    return response.toDomain();
  }

  Future<void> _persistSession(AuthResponseDto response) {
    return _sessionController.save(
      tokens: response.toSessionTokens(_now().toUtc()),
      activeJobId: _sessionController.state.activeJobId,
      userProfile: _toUserProfile(response.toDomain()),
    );
  }

  UserProfile _toUserProfile(AuthUser user) {
    return UserProfile(
      id: user.id,
      name: user.name,
      email: user.email,
      onboardingCompleted: user.onboardingCompleted,
    );
  }
}
