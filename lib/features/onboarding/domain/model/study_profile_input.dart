class StudyProfileInput {
  const StudyProfileInput({
    required this.usualStudyHoursPerDay,
    required this.preferredStudyMethod,
  });

  final int usualStudyHoursPerDay;
  final String preferredStudyMethod;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is StudyProfileInput &&
        other.usualStudyHoursPerDay == usualStudyHoursPerDay &&
        other.preferredStudyMethod == preferredStudyMethod;
  }

  @override
  int get hashCode => Object.hash(usualStudyHoursPerDay, preferredStudyMethod);
}
