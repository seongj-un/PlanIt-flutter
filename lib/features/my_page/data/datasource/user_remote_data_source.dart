import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_providers.dart';
import '../dto/user_profile_dto.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(apiClient: ref.watch(apiClientProvider));
});

class UserRemoteDataSource {
  const UserRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UserProfileDto> getCurrentUser() {
    return _apiClient.get<UserProfileDto>(
      '/users/me',
      parser: UserProfileDto.fromJson,
    );
  }
}
