class ExamPlanInput {
  const ExamPlanInput({
    required this.targetExamType,
    required this.targetExamLabel,
    required this.examDate,
  });

  final String targetExamType;
  final String targetExamLabel;
  final String examDate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ExamPlanInput &&
        other.targetExamType == targetExamType &&
        other.targetExamLabel == targetExamLabel &&
        other.examDate == examDate;
  }

  @override
  int get hashCode => Object.hash(targetExamType, targetExamLabel, examDate);
}
