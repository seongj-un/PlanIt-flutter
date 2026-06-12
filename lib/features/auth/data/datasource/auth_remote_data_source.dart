import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_providers.dart';
import '../dto/auth_response_dto.dart';
import '../dto/login_request_dto.dart';
import '../dto/signup_request_dto.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResponseDto> login(LoginRequestDto request) {
    return _apiClient.post<AuthResponseDto>(
      '/auth/login',
      data: request.toJson(),
      parser: AuthResponseDto.fromJson,
    );
  }

  Future<AuthResponseDto> signup(SignupRequestDto request) {
    return _apiClient.post<AuthResponseDto>(
      '/auth/signup',
      data: request.toJson(),
      parser: AuthResponseDto.fromJson,
    );
  }
}
