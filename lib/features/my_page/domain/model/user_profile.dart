class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.onboardingCompleted,
    this.age,
    this.schoolLevel,
    this.targetExamType,
    this.targetExamLabel,
    this.examDate,
    this.usualStudyHoursPerDay,
    this.preferredStudyMethod,
    this.sproutCount,
    this.attendanceStreakDays,
  });

  final int id;
  final String name;
  final String? email;
  final int? age;
  final String? schoolLevel;
  final String? targetExamType;
  final String? targetExamLabel;
  final DateTime? examDate;
  final int? usualStudyHoursPerDay;
  final String? preferredStudyMethod;
  final int? sproutCount;
  final int? attendanceStreakDays;
  final bool onboardingCompleted;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.age == age &&
        other.schoolLevel == schoolLevel &&
        other.targetExamType == targetExamType &&
        other.targetExamLabel == targetExamLabel &&
        other.examDate == examDate &&
        other.usualStudyHoursPerDay == usualStudyHoursPerDay &&
        other.preferredStudyMethod == preferredStudyMethod &&
        other.sproutCount == sproutCount &&
        other.attendanceStreakDays == attendanceStreakDays &&
        other.onboardingCompleted == onboardingCompleted;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    age,
    schoolLevel,
    targetExamType,
    targetExamLabel,
    examDate,
    usualStudyHoursPerDay,
    preferredStudyMethod,
    sproutCount,
    attendanceStreakDays,
    onboardingCompleted,
  );
}
