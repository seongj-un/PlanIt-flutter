import '../../domain/model/subject_scope_input.dart';

class SubjectScopeRequestDto {
  const SubjectScopeRequestDto({
    required this.subjectName,
    required this.examRange,
    required this.preferredMethodNote,
    required this.priority,
  });

  factory SubjectScopeRequestDto.fromDomain(SubjectScopeInput input) {
    return SubjectScopeRequestDto(
      subjectName: input.subjectName,
      examRange: input.examRange,
      preferredMethodNote: input.preferredMethodNote,
      priority: input.priority,
    );
  }

  final String subjectName;
  final String examRange;
  final String preferredMethodNote;
  final String priority;

  Map<String, Object?> toJson() {
    return {
      'subjectName': subjectName,
      'examRange': examRange,
      'preferredMethodNote': preferredMethodNote,
      'priority': priority,
    };
  }
}
