import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/features/exam_plan/data/dto/subject_scope_request_dto.dart';
import 'package:planit_flutter/features/exam_plan/domain/model/subject_scope_input.dart';

void main() {
  test('serializes to the backend subject-scope schema', () {
    final dto = SubjectScopeRequestDto.fromDomain(
      const SubjectScopeInput(
        subjectName: '수학',
        examRange: '수열과 극한 1~3단원',
        preferredMethodNote: '개념 정리 후 대표 문제',
        priority: 'HIGH',
      ),
    );

    expect(dto.toJson(), {
      'subjectName': '수학',
      'rawRangeText': '수열과 극한 1~3단원',
      'preferredMethodNote': '개념 정리 후 대표 문제',
      'difficulty': 'HIGH',
      'unitType': 'CUSTOM',
      'totalUnits': 10,
      'remainingUnits': 10,
    });
  });
}
