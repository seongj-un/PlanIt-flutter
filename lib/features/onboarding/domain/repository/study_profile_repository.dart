import '../../../my_page/domain/model/user_profile.dart';
import '../model/study_profile_input.dart';

abstract interface class StudyProfileRepository {
  Future<UserProfile> saveStudyProfile(StudyProfileInput input);
}
