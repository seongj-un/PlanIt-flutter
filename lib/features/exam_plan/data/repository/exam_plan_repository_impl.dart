import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/exam_plan_input.dart';
import '../../domain/model/exam_plan_result.dart';
import '../../domain/model/subject_scope_input.dart';
import '../../domain/repository/exam_plan_repository.dart';
import '../datasource/exam_plan_remote_data_source.dart';
import '../dto/exam_plan_request_dto.dart';
import '../dto/subject_scope_request_dto.dart';

final examPlanRepositoryProvider = Provider<ExamPlanRepository>((ref) {
  return ExamPlanRepositoryImpl(
    remoteDataSource: ref.watch(examPlanRemoteDataSourceProvider),
  );
});

class ExamPlanRepositoryImpl implements ExamPlanRepository {
  const ExamPlanRepositoryImpl({
    required ExamPlanRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ExamPlanRemoteDataSource _remoteDataSource;

  @override
  Future<ExamPlanResult> saveExamPlan(ExamPlanInput input) async {
    final response = await _remoteDataSource.saveExamPlan(
      ExamPlanRequestDto.fromDomain(input),
    );
    return response.toDomain();
  }

  @override
  Future<void> saveSubjectScopes(List<SubjectScopeInput> inputs) {
    return _remoteDataSource.saveSubjectScopes(
      inputs.map(SubjectScopeRequestDto.fromDomain).toList(),
    );
  }
}
