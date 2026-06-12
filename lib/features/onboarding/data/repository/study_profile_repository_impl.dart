import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../my_page/domain/model/user_profile.dart';
import '../../domain/model/study_profile_input.dart';
import '../../domain/repository/study_profile_repository.dart';
import '../datasource/study_profile_remote_data_source.dart';
import '../dto/study_profile_request_dto.dart';

final studyProfileRepositoryProvider = Provider<StudyProfileRepository>((ref) {
  return StudyProfileRepositoryImpl(
    remoteDataSource: ref.watch(studyProfileRemoteDataSourceProvider),
  );
});

class StudyProfileRepositoryImpl implements StudyProfileRepository {
  const StudyProfileRepositoryImpl({
    required StudyProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final StudyProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> saveStudyProfile(StudyProfileInput input) async {
    final response = await _remoteDataSource.saveStudyProfile(
      StudyProfileRequestDto.fromDomain(input),
    );
    return response.toDomain();
  }
}
