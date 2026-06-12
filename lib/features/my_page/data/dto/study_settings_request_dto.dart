class StudySettingsRequestDto {
  const StudySettingsRequestDto({
    required this.usualStudyHoursPerDay,
    required this.preferredStudyMethod,
  });

  final int usualStudyHoursPerDay;
  final String preferredStudyMethod;

  Map<String, Object?> toJson() {
    return {
      'usualStudyHoursPerDay': usualStudyHoursPerDay,
      'preferredStudyMethod': preferredStudyMethod,
    };
  }
}
