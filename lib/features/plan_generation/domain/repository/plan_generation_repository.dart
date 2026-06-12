import '../model/plan_generation_input.dart';
import '../model/plan_generation_status.dart';

abstract interface class PlanGenerationRepository {
  Future<PlanGenerationStatus> createJob(PlanGenerationInput input);

  Future<PlanGenerationStatus> fetchStatus(String jobId);
}
