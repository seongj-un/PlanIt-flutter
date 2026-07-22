import '../../../../core/error/app_exception.dart';
import '../../domain/model/exam_plan_result.dart';

/// Parses the `PUT /exam-plans/active` response:
/// `{ id, targetExamType, targetExamLabel, examDate, status }`.
class ActiveExamPlanResponseDto {
  const ActiveExamPlanResponseDto({
    this.targetExamType,
    this.targetExamLabel,
    this.examDate,
  });

  factory ActiveExamPlanResponseDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Exam plan payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    return ActiveExamPlanResponseDto(
      targetExamType: _readOptionalString(map, 'targetExamType'),
      targetExamLabel: _readOptionalString(map, 'targetExamLabel'),
      examDate: _readOptionalDate(map, 'examDate'),
    );
  }

  final String? targetExamType;
  final String? targetExamLabel;
  final DateTime? examDate;

  ExamPlanResult toDomain() {
    return ExamPlanResult(
      targetExamType: targetExamType,
      targetExamLabel: targetExamLabel,
      examDate: examDate,
    );
  }

  static DateTime? _readOptionalDate(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is! String || value.isEmpty) {
      throw AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Exam plan field $key has an unexpected type.',
      );
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Exam plan field $key is not a valid ISO date.',
      );
    }

    return parsed;
  }

  static String? _readOptionalString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value.isEmpty ? null : value;
    }

    throw AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Exam plan field $key has an unexpected type.',
    );
  }
}
