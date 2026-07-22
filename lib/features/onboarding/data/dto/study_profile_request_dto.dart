import '../../domain/model/study_profile_input.dart';

class StudyProfileRequestDto {
  const StudyProfileRequestDto({
    required this.usualStudyHoursPerDay,
    required this.preferredStudyMethod,
  });

  factory StudyProfileRequestDto.fromDomain(StudyProfileInput input) {
    return StudyProfileRequestDto(
      usualStudyHoursPerDay: input.usualStudyHoursPerDay,
      preferredStudyMethod: input.preferredStudyMethod,
    );
  }

  final int usualStudyHoursPerDay;
  final String preferredStudyMethod;

  Map<String, Object?> toJson() {
    return {
      'usualStudyHoursPerDay': usualStudyHoursPerDay,
      'preferredStudyMethod': preferredStudyMethod,
    };
  }
}
