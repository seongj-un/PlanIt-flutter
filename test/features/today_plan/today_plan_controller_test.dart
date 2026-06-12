import 'package:flutter_test/flutter_test.dart';
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
    expect(controller.state.progress?.completedCount, 2);
    expect(controller.state.progress?.sproutCount, 12);
  });
}

class _FakeTodayPlanRepository implements TodayPlanRepository {
  int getTodayPlanCallCount = 0;
  int getTodayProgressCallCount = 0;

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
          status: 'PENDING',
          estimatedMinutes: 50,
        ),
      ],
    );
  }

  @override
  Future<TodayPlanProgress> getTodayProgress() async {
    getTodayProgressCallCount += 1;
    return const TodayPlanProgress(
      completedCount: 2,
      totalCount: 4,
      completedItems: [
        TodayPlanProgressItem(
          planItemId: 9002,
          subjectName: '국어',
          label: '독해 유형 20문제',
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
}
