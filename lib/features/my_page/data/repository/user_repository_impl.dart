import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/user_profile.dart';
import '../../domain/repository/user_repository.dart';
import '../datasource/user_remote_data_source.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDataSource: ref.watch(userRemoteDataSourceProvider),
  );
});

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({required UserRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> getCurrentUser() async {
    final profile = await _remoteDataSource.getCurrentUser();
    return profile.toDomain();
  }
}
