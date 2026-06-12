class SubjectScopeInput {
  const SubjectScopeInput({
    required this.subjectName,
    required this.examRange,
    required this.preferredMethodNote,
    required this.priority,
  });

  final String subjectName;
  final String examRange;
  final String preferredMethodNote;
  final String priority;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SubjectScopeInput &&
        other.subjectName == subjectName &&
        other.examRange == examRange &&
        other.preferredMethodNote == preferredMethodNote &&
        other.priority == priority;
  }

  @override
  int get hashCode =>
      Object.hash(subjectName, examRange, preferredMethodNote, priority);
}
