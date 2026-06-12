import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_providers.dart';
import '../../../my_page/data/dto/user_profile_dto.dart';
import '../dto/study_profile_request_dto.dart';

final studyProfileRemoteDataSourceProvider =
    Provider<StudyProfileRemoteDataSource>((ref) {
      return StudyProfileRemoteDataSource(
        apiClient: ref.watch(apiClientProvider),
      );
    });

class StudyProfileRemoteDataSource {
  const StudyProfileRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UserProfileDto> saveStudyProfile(StudyProfileRequestDto request) {
    return _apiClient.put<UserProfileDto>(
      '/users/me/study-profile',
      data: request.toJson(),
      parser: UserProfileDto.fromJson,
    );
  }
}
