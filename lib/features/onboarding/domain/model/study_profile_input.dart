class StudyProfileInput {
  const StudyProfileInput({
    required this.age,
    required this.schoolLevel,
    required this.usualStudyHoursPerDay,
    required this.preferredStudyMethod,
  });

  final int age;
  final String schoolLevel;
  final int usualStudyHoursPerDay;
  final String preferredStudyMethod;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is StudyProfileInput &&
        other.age == age &&
        other.schoolLevel == schoolLevel &&
        other.usualStudyHoursPerDay == usualStudyHoursPerDay &&
        other.preferredStudyMethod == preferredStudyMethod;
  }

  @override
  int get hashCode => Object.hash(
    age,
    schoolLevel,
    usualStudyHoursPerDay,
    preferredStudyMethod,
  );
}
