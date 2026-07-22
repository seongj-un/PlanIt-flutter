/// Result of saving the active exam plan.
///
/// `PUT /exam-plans/active` returns only the exam-plan fields (not a full user
/// profile), so the client merges these into the cached session user.
class ExamPlanResult {
  const ExamPlanResult({
    this.targetExamType,
    this.targetExamLabel,
    this.examDate,
  });

  final String? targetExamType;
  final String? targetExamLabel;
  final DateTime? examDate;
}
