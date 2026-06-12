import '../../domain/model/study_profile_input.dart';

class StudyProfileRequestDto {
  const StudyProfileRequestDto({
    required this.age,
    required this.schoolLevel,
    required this.usualStudyHoursPerDay,
    required this.preferredStudyMethod,
  });

  factory StudyProfileRequestDto.fromDomain(StudyProfileInput input) {
    return StudyProfileRequestDto(
      age: input.age,
      schoolLevel: input.schoolLevel,
      usualStudyHoursPerDay: input.usualStudyHoursPerDay,
      preferredStudyMethod: input.preferredStudyMethod,
    );
  }

  final int age;
  final String schoolLevel;
  final int usualStudyHoursPerDay;
  final String preferredStudyMethod;

  Map<String, Object?> toJson() {
    return {
      'age': age,
      'schoolLevel': schoolLevel,
      'usualStudyHoursPerDay': usualStudyHoursPerDay,
      'preferredStudyMethod': preferredStudyMethod,
    };
  }
}
