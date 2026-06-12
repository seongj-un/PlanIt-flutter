import '../../domain/model/exam_plan_input.dart';

class ExamPlanRequestDto {
  const ExamPlanRequestDto({
    required this.targetExamType,
    required this.targetExamLabel,
    required this.examDate,
  });

  factory ExamPlanRequestDto.fromDomain(ExamPlanInput input) {
    return ExamPlanRequestDto(
      targetExamType: input.targetExamType,
      targetExamLabel: input.targetExamLabel,
      examDate: input.examDate,
    );
  }

  final String targetExamType;
  final String targetExamLabel;
  final String examDate;

  Map<String, Object?> toJson() {
    return {
      'targetExamType': targetExamType,
      'targetExamLabel': targetExamLabel,
      'examDate': examDate,
    };
  }
}
