import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/features/exam_plan/data/dto/active_exam_plan_response_dto.dart';

void main() {
  test('parses the PUT /exam-plans/active response shape', () {
    // Exact payload the backend returns (not a user profile).
    final dto = ActiveExamPlanResponseDto.fromJson(<String, Object?>{
      'id': 1,
      'targetExamType': 'CSAT',
      'targetExamLabel': '수능',
      'examDate': '2026-07-30',
      'status': 'ACTIVE',
    });

    final result = dto.toDomain();
    expect(result.targetExamType, 'CSAT');
    expect(result.targetExamLabel, '수능');
    expect(result.examDate, DateTime.parse('2026-07-30'));
  });
}
