import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/network/api_response.dart';
import 'package:planit_flutter/features/today_plan/domain/model/today_plan.dart';
import 'package:planit_flutter/features/today_plan/domain/model/today_plan_progress.dart';
import 'package:planit_flutter/features/today_plan/domain/repository/today_plan_repository.dart';
import 'package:planit_flutter/features/today_plan/presentation/controllers/today_plan_controller.dart';

void main() {
  test('loads today plan detail and progress together', () async {
    final repository = _FakeTodayPlanRepository();
    final controller = TodayPlanController(repository: repository);

    await controller.load();

    expect(repository.getTodayPlanCallCount, 1);
    expect(repository.getTodayProgressCallCount, 1);
    expect(controller.state.isLoading, isFalse);
    expect(controller.state.plan?.planId, 101);
    expect(controller.state.plan?.items.length, 2);
    expect(controller.state.progress?.completedCount, 1);
    expect(controller.state.progress?.sproutCount, 12);
  });

  test('optimistically toggles a plan item and keeps server progress counts', () async {
    final repository = _FakeTodayPlanRepository();
    final controller = TodayPlanController(repository: repository);
    await controller.load();

    await controller.toggleItem(planItemId: 9001, completed: true);

    expect(repository.toggleCallCount, 1);
    expect(controller.state.plan?.items.first.completed, isTrue);
    expect(controller.state.progress?.completedCount, 2);
    expect(controller.state.progress?.sproutCount, 13);
  });

  test('rolls back the optimistic toggle when the server request fails', () async {
    final repository = _FakeTodayPlanRepository();
    repository.toggleError = const ApiErrorException(
      code: 'BAD_REQUEST',
      message: '체크 상태를 바꾸지 못했어요.',
    );
    final controller = TodayPlanController(repository: repository);
    await controller.load();

    await controller.toggleItem(planItemId: 9001, completed: true);

    expect(controller.state.plan?.items.first.completed, isFalse);
    expect(controller.state.progress?.completedCount, 1);
    expect(controller.state.errorMessage, '체크 상태를 바꾸지 못했어요.');
  });

  test('surfaces completion conflict when unfinished items remain', () async {
    final repository = _FakeTodayPlanRepository();
    repository.completeError = const ApiErrorException(
      code: '409',
      message: '미완료 항목이 남아 있어요.',
    );
    final controller = TodayPlanController(repository: repository);
    await controller.load();

    final result = await controller.completeTodayPlan();

    expect(result, isFalse);
    expect(repository.completeCallCount, 1);
    expect(controller.state.errorMessage, '미완료 항목이 남아 있어요.');
  });
}

class _FakeTodayPlanRepository implements TodayPlanRepository {
  int getTodayPlanCallCount = 0;
  int getTodayProgressCallCount = 0;
  int toggleCallCount = 0;
  int completeCallCount = 0;
  Object? toggleError;
  Object? completeError;

  @override
  Future<TodayPlan> getTodayPlan() async {
    getTodayPlanCallCount += 1;
    return const TodayPlan(
      planId: 101,
      planDate: '2026-06-04',
      status: 'PENDING',
      items: [
        TodayPlanItem(
          planItemId: 9001,
          subjectName: '수학',
          examRange: '수열과 극한 3장 이상',
          studyMethod: '개념 정리 후 대표 문제 15문제',
          priority: 'HIGH',
          status: 'PENDING',
          estimatedMinutes: 70,
        ),
        TodayPlanItem(
          planItemId: 9002,
          subjectName: '영어',
          examRange: '빈칸 추론 유형 15문제',
          studyMethod: '근거 문장 밑줄 표시',
          priority: 'HIGH',
          status: 'COMPLETED',
          estimatedMinutes: 50,
        ),
      ],
    );
  }

  @override
  Future<TodayPlanProgress> getTodayProgress() async {
    getTodayProgressCallCount += 1;
    return const TodayPlanProgress(
      completedCount: 1,
      totalCount: 2,
      completedItems: [
        TodayPlanProgressItem(
          planItemId: 9002,
          subjectName: '영어',
          label: '빈칸 추론 유형 15문제',
        ),
      ],
      remainingItems: [
        TodayPlanProgressItem(
          planItemId: 9001,
          subjectName: '수학',
          label: '수열과 극한 3장 이상',
        ),
      ],
      sproutCount: 12,
      sproutPerPlanItem: 1,
    );
  }

  @override
  Future<TodayPlanToggleResult> togglePlanItem({
    required int planItemId,
    required bool completed,
  }) async {
    toggleCallCount += 1;
    final error = toggleError;
    if (error != null) {
      throw error;
    }

    return TodayPlanToggleResult(
      planItemId: planItemId,
      completed: completed,
      completedCount: completed ? 2 : 0,
      totalCount: 2,
      sproutAwarded: completed ? 1 : -1,
    );
  }

  @override
  Future<TodayPlanCompletionResult> completeTodayPlan() async {
    completeCallCount += 1;
    final error = completeError;
    if (error != null) {
      throw error;
    }

    return const TodayPlanCompletionResult(
      planId: 101,
      completed: true,
      attendanceRecorded: true,
      streakDays: 7,
    );
  }

  @override
  Future<TodayPlanUpdateResult> updateTodayPlan({
    required List<TodayPlanEditableItem> items,
    required List<int> deletedPlanItemIds,
  }) {
    throw UnimplementedError();
  }
}
