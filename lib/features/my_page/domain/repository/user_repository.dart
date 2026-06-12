import '../model/user_profile.dart';

abstract interface class UserRepository {
  Future<UserProfile> getCurrentUser();
}
