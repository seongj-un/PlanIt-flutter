class PlanGenerationInput {
  const PlanGenerationInput({
    required this.subjects,
    required this.preferredStudyMethod,
    required this.difficultSubjects,
    required this.dailyMaxStudyHours,
  });

  final List<PlanGenerationSubjectInput> subjects;
  final String preferredStudyMethod;
  final List<String> difficultSubjects;
  final int dailyMaxStudyHours;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PlanGenerationInput &&
        _listEquals(other.subjects, subjects) &&
        other.preferredStudyMethod == preferredStudyMethod &&
        _listEquals(other.difficultSubjects, difficultSubjects) &&
        other.dailyMaxStudyHours == dailyMaxStudyHours;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(subjects),
    preferredStudyMethod,
    Object.hashAll(difficultSubjects),
    dailyMaxStudyHours,
  );
}

class PlanGenerationSubjectInput {
  const PlanGenerationSubjectInput({
    required this.subjectName,
    required this.examRange,
    required this.preferredMethodNote,
    required this.difficulty,
  });

  final String subjectName;
  final String examRange;
  final String preferredMethodNote;
  final String difficulty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PlanGenerationSubjectInput &&
        other.subjectName == subjectName &&
        other.examRange == examRange &&
        other.preferredMethodNote == preferredMethodNote &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode =>
      Object.hash(subjectName, examRange, preferredMethodNote, difficulty);
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}
