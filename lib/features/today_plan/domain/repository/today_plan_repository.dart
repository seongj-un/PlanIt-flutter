import '../model/today_plan.dart';
import '../model/today_plan_progress.dart';

abstract interface class TodayPlanRepository {
  Future<TodayPlan> getTodayPlan();

  Future<TodayPlanProgress> getTodayProgress();

  Future<TodayPlanUpdateResult> updateTodayPlan({
    required List<TodayPlanEditableItem> items,
    required List<int> deletedPlanItemIds,
  });

  Future<TodayPlanToggleResult> togglePlanItem({
    required int planItemId,
    required bool completed,
  });

  Future<TodayPlanCompletionResult> completeTodayPlan();
}
