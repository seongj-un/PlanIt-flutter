import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/features/today_plan/domain/model/today_plan.dart';
import 'package:planit_flutter/features/today_plan/domain/model/today_plan_progress.dart';
import 'package:planit_flutter/features/today_plan/domain/repository/today_plan_repository.dart';
import 'package:planit_flutter/features/today_plan/presentation/controllers/today_plan_edit_controller.dart';

void main() {
  test('submits edited items and deleted ids through the repository', () async {
    final repository = _FakeTodayPlanRepository();
    final controller = TodayPlanEditController(repository: repository);

    final result = await controller.submit(
      items: const [
        TodayPlanEditableItem(
          planItemId: 9001,
          subjectName: '수학',
          examRange: '수열과 극한 3장 이상',
          studyMethod: '대표 문제 15문제',
          priority: 'HIGH',
        ),
        TodayPlanEditableItem(
          subjectName: '국어',
          examRange: '독해 유형 20문제',
          studyMethod: '핵심 문장 표시',
          priority: 'MEDIUM',
        ),
      ],
      deletedPlanItemIds: const [9005],
    );

    expect(result, isTrue);
    expect(repository.lastUpdatedItems.length, 2);
    expect(repository.lastDeletedPlanItemIds, [9005]);
    expect(controller.state.isSuccess, isTrue);
  });
}

class _FakeTodayPlanRepository implements TodayPlanRepository {
  List<TodayPlanEditableItem> lastUpdatedItems = const [];
  List<int> lastDeletedPlanItemIds = const [];

  @override
  Future<TodayPlanCompletionResult> completeTodayPlan() {
    throw UnimplementedError();
  }

  @override
  Future<TodayPlan> getTodayPlan() {
    throw UnimplementedError();
  }

  @override
  Future<TodayPlanProgress> getTodayProgress() {
    throw UnimplementedError();
  }

  @override
  Future<TodayPlanToggleResult> togglePlanItem({
    required int planItemId,
    required bool completed,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TodayPlanUpdateResult> updateTodayPlan({
    required List<TodayPlanEditableItem> items,
    required List<int> deletedPlanItemIds,
  }) async {
    lastUpdatedItems = items;
    lastDeletedPlanItemIds = deletedPlanItemIds;
    return TodayPlanUpdateResult(planId: 101, updated: true, itemCount: items.length);
  }
}
