import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planit_flutter/app/router/route_paths.dart';
import 'package:planit_flutter/features/history/data/repository/history_repository_impl.dart';
import 'package:planit_flutter/features/history/domain/model/history_day_detail.dart';
import 'package:planit_flutter/features/history/domain/model/history_month.dart';
import 'package:planit_flutter/features/history/domain/repository/history_repository.dart';
import 'package:planit_flutter/features/history/presentation/controllers/history_controller.dart';
import 'package:planit_flutter/features/history/presentation/pages/history_detail_page.dart';
import 'package:planit_flutter/features/history/presentation/pages/history_page.dart';

void main() {
  testWidgets('moves from month list to a selected day detail', (tester) async {
    final repository = _FakeHistoryRepository();
    final router = GoRouter(
      initialLocation: RoutePaths.history,
      routes: [
        GoRoute(
          path: RoutePaths.history,
          builder: (context, state) => const HistoryPage(),
          routes: [
            GoRoute(
              path: ':date',
              builder: (context, state) => HistoryDetailPage(
                date: state.pathParameters['date']!,
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyRepositoryProvider.overrideWithValue(repository),
          historyInitialMonthProvider.overrideWithValue('2026-06'),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026-06-01'), findsOneWidget);
    await tester.tap(find.text('2026-06-01'));
    await tester.pumpAndSettle();

    expect(find.text('미분과 적분 1단원'), findsOneWidget);
    expect(find.text('개념 정리 후 10문제'), findsOneWidget);
  });
}

class _FakeHistoryRepository implements HistoryRepository {
  @override
  Future<HistoryDayDetail> getDayDetail(String date) async {
    return const HistoryDayDetail(
      date: '2026-06-01',
      completedCount: 4,
      totalCount: 5,
      items: [
        HistoryDayDetailItem(
          subjectName: '수학',
          examRange: '미분과 적분 1단원',
          studyMethod: '개념 정리 후 10문제',
          completed: true,
        ),
      ],
    );
  }

  @override
  Future<HistoryMonth> getMonth(String month) async {
    return const HistoryMonth(
      month: '2026-06',
      stats: HistoryMonthStats(completedPlans: 42, incompletePlans: 8),
      days: [
        HistoryDaySummary(
          date: '2026-06-01',
          completedCount: 4,
          totalCount: 5,
          completed: true,
          subjects: ['수학', '영어', '국어', '과학'],
        ),
      ],
    );
  }
}
