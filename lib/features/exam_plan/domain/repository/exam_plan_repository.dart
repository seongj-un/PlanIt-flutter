import '../../../my_page/domain/model/user_profile.dart';
import '../model/exam_plan_input.dart';
import '../model/subject_scope_input.dart';

abstract interface class ExamPlanRepository {
  Future<UserProfile> saveExamPlan(ExamPlanInput input);

  Future<void> saveSubjectScopes(List<SubjectScopeInput> inputs);
}
