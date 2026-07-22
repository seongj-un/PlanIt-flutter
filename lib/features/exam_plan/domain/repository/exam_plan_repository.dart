import '../model/exam_plan_input.dart';
import '../model/exam_plan_result.dart';
import '../model/subject_scope_input.dart';

abstract interface class ExamPlanRepository {
  Future<ExamPlanResult> saveExamPlan(ExamPlanInput input);

  Future<void> saveSubjectScopes(List<SubjectScopeInput> inputs);
}
