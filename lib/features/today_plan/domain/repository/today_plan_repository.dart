import '../model/today_plan.dart';
import '../model/today_plan_progress.dart';

abstract interface class TodayPlanRepository {
  Future<TodayPlan> getTodayPlan();

  Future<TodayPlanProgress> getTodayProgress();
}
