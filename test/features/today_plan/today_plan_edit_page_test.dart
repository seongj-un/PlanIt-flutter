import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planit_flutter/app/router/route_paths.dart';
import 'package:planit_flutter/features/today_plan/data/repository/today_plan_repository_impl.dart';
import 'package:planit_flutter/features/today_plan/domain/model/today_plan.dart';
import 'package:planit_flutter/features/today_plan/domain/model/today_plan_progress.dart';
import 'package:planit_flutter/features/today_plan/domain/repository/today_plan_repository.dart';
import 'package:planit_flutter/features/today_plan/presentation/pages/today_plan_edit_page.dart';

void main() {
  testWidgets('edits an item, saves, and returns to the detail route', (tester) async {
    final repository = _FakeTodayPlanRepository();
    final router = GoRouter(
      initialLocation: RoutePaths.todayPlanEdit,
      routes: [
        GoRoute(
          path: RoutePaths.todayPlanEdit,
          builder: (context, state) => TodayPlanEditPage(
            initialPlan: const TodayPlan(
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
              ],
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.todayPlanDetail,
          builder: (context, state) =>
              const Scaffold(body: Text('today-plan-detail-route')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayPlanRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '수학 심화');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(repository.lastUpdatedItems.single.subjectName, '수학 심화');
    expect(find.text('today-plan-detail-route'), findsOneWidget);
  });
}

class _FakeTodayPlanRepository implements TodayPlanRepository {
  List<TodayPlanEditableItem> lastUpdatedItems = const [];

  @override
  Future<TodayPlanCompletionResult> completeTodayPlan() {
    throw UnimplementedError();
  }

  @override
  Future<TodayPlan> getTodayPlan() async {
    return const TodayPlan(
      planId: 101,
      planDate: '2026-06-04',
      status: 'PENDING',
      items: [],
    );
  }

  @override
  Future<TodayPlanProgress> getTodayProgress() async {
    return const TodayPlanProgress(
      completedCount: 0,
      totalCount: 1,
      completedItems: [],
      remainingItems: [],
      sproutCount: 12,
      sproutPerPlanItem: 1,
    );
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
    return TodayPlanUpdateResult(planId: 101, updated: true, itemCount: items.length);
  }
}
