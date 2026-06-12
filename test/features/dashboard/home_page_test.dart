import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/features/dashboard/data/repository/dashboard_repository_impl.dart';
import 'package:planit_flutter/features/dashboard/domain/model/dashboard_summary.dart';
import 'package:planit_flutter/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:planit_flutter/features/dashboard/presentation/pages/home_page.dart';
import 'package:planit_flutter/features/today_plan/data/repository/today_plan_repository_impl.dart';
import 'package:planit_flutter/features/today_plan/domain/model/today_plan.dart';
import 'package:planit_flutter/features/today_plan/domain/model/today_plan_progress.dart';
import 'package:planit_flutter/features/today_plan/domain/repository/today_plan_repository.dart';

void main() {
  testWidgets('renders dashboard summary and today plan preview', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(
            _FakeDashboardRepository(),
          ),
          todayPlanRepositoryProvider.overrideWithValue(
            _FakeTodayPlanRepository(),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('민지님의 오늘 학습'), findsOneWidget);
    expect(find.text('수능'), findsOneWidget);
    expect(find.text('D-23'), findsOneWidget);
    expect(find.text('2 / 4 완료'), findsOneWidget);
    expect(find.text('수학'), findsWidgets);
    expect(find.text('국어'), findsWidgets);
  });
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> getDashboardSummary() async {
    return DashboardSummary(
      userName: '민지',
      nextExam: const DashboardExamSummary(
        label: '수능',
        date: '2026-06-12',
        dDay: 23,
      ),
      todayPlanPreview: const DashboardTodayPlanPreview(
        planDate: '2026-06-04',
        completedCount: 2,
        totalCount: 4,
        progressPercent: 50,
        items: [
          DashboardTodayPlanPreviewItem(
            planItemId: 9001,
            subjectName: '수학',
            scopeSummary: '수열과 극한: 개념 정리 + 문제 15문제',
            completed: false,
          ),
          DashboardTodayPlanPreviewItem(
            planItemId: 9002,
            subjectName: '국어',
            scopeSummary: '독해 유형 20문제',
            completed: true,
          ),
        ],
      ),
      rewards: const DashboardRewards(sproutCount: 12, earnedToday: 2),
      attendance: const DashboardAttendance(
        streakDays: 7,
        calendar: [
          DashboardAttendanceDay(date: '2026-06-01', completed: true),
          DashboardAttendanceDay(date: '2026-06-02', completed: true),
        ],
      ),
    );
  }
}

class _FakeTodayPlanRepository implements TodayPlanRepository {
  @override
  Future<TodayPlan> getTodayPlan() async {
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
          subjectName: '국어',
          examRange: '독해 유형 20문제',
          studyMethod: '핵심 문장 근거 표시',
          priority: 'MEDIUM',
          status: 'COMPLETED',
          estimatedMinutes: 45,
        ),
      ],
    );
  }

  @override
  Future<TodayPlanProgress> getTodayProgress() async {
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
