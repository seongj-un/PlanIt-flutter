import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/plan_item_tile.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/progress_summary_card.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../today_plan/presentation/controllers/today_plan_controller.dart';
import '../controllers/dashboard_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(dashboardControllerProvider.notifier).load();
      ref.read(todayPlanControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final todayPlanState = ref.watch(todayPlanControllerProvider);

    if (dashboardState.isLoading || todayPlanState.isLoading) {
      return const AppScaffold(
        body: AppLoadingView(
          title: '홈 준비 중',
          message: '오늘 학습 정보를 불러오고 있어요.',
        ),
      );
    }

    final dashboard = dashboardState.summary;
    final todayPlan = todayPlanState.plan;
    final progress = todayPlanState.progress;
    final errorMessage =
        dashboardState.errorMessage ?? todayPlanState.errorMessage;

    if (dashboard == null || todayPlan == null || progress == null) {
      return AppScaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '아직 학습 플랜이 없어요',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? '플랜을 만들면 오늘 할 공부가 여기에 표시돼요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: '플랜 만들기',
                  onPressed: () => context.go(RoutePaths.subjectScope),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref
                        .read(dashboardControllerProvider.notifier)
                        .load(forceRefresh: true);
                    ref
                        .read(todayPlanControllerProvider.notifier)
                        .load(forceRefresh: true);
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      body: ListView(
        children: [
          Text(
            '${dashboard.userName}님의 오늘 학습',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '다음 시험까지 ${dashboard.nextExam.dDay}일 남았어요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: '다음 시험',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              ),
              child: Text('D-${dashboard.nextExam.dDay}'),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dashboard.nextExam.label,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Text(
                  dashboard.nextExam.date,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: '오늘 플랜',
            subtitle: todayPlan.planDate,
            trailing: TextButton(
              onPressed: () {
                context.go(RoutePaths.todayPlanDetail);
              },
              child: const Text('자세히 보기'),
            ),
            child: Column(
              children: [
                ProgressSummaryCard(
                  completedCount: progress.completedCount,
                  totalCount: progress.totalCount,
                  sproutCount: progress.sproutCount,
                  sproutPerPlanItem: progress.sproutPerPlanItem,
                ),
                const SizedBox(height: 14),
                for (final item in todayPlan.items.take(3)) ...[
                  PlanItemTile(
                    subjectName: item.subjectName,
                    primaryText: item.examRange,
                    secondaryText: item.studyMethod,
                    statusLabel: item.priority,
                    isCompleted: item.completed,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SectionCard(
                  title: '새싹',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '새싹 ${dashboard.rewards.sproutCount}개',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '오늘 ${dashboard.rewards.earnedToday}개 획득',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SectionCard(
                  title: '출석',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dashboard.attendance.streakDays}일 연속',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${dashboard.attendance.calendar.length}일 기록됨',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
