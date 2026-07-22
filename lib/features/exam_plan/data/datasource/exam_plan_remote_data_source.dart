import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_providers.dart';
import '../dto/active_exam_plan_response_dto.dart';
import '../dto/exam_plan_request_dto.dart';
import '../dto/subject_scope_request_dto.dart';

final examPlanRemoteDataSourceProvider = Provider<ExamPlanRemoteDataSource>((
  ref,
) {
  return ExamPlanRemoteDataSource(apiClient: ref.watch(apiClientProvider));
});

class ExamPlanRemoteDataSource {
  const ExamPlanRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ActiveExamPlanResponseDto> saveExamPlan(ExamPlanRequestDto request) {
    return _apiClient.put<ActiveExamPlanResponseDto>(
      '/exam-plans/active',
      data: request.toJson(),
      parser: ActiveExamPlanResponseDto.fromJson,
    );
  }

  Future<void> saveSubjectScopes(List<SubjectScopeRequestDto> requests) async {
    await _apiClient.put<Object>(
      '/exam-plans/active/scopes',
      data: {'scopes': requests.map((request) => request.toJson()).toList()},
      parser: (_) => const Object(),
    );
  }
}
