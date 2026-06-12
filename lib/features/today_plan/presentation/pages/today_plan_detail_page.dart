import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/plan_item_tile.dart';
import '../../../../shared/widgets/progress_summary_card.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../controllers/today_plan_controller.dart';

class TodayPlanDetailPage extends ConsumerStatefulWidget {
  const TodayPlanDetailPage({super.key});

  @override
  ConsumerState<TodayPlanDetailPage> createState() => _TodayPlanDetailPageState();
}

class _TodayPlanDetailPageState extends ConsumerState<TodayPlanDetailPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(todayPlanControllerProvider.notifier).load();
      ref.read(dashboardControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todayPlanControllerProvider);
    final plan = state.plan;
    final progress = state.progress;

    if (state.isLoading) {
      return const AppScaffold(
        title: '오늘 플랜',
        body: AppLoadingView(
          title: '오늘 플랜 준비 중',
          message: '상세 항목을 불러오고 있어요.',
        ),
      );
    }

    if (plan == null || progress == null) {
      return AppScaffold(
        title: '오늘 플랜',
        body: AppLoadingView(
          title: '오늘 플랜을 불러올 수 없어요',
          message: state.errorMessage ?? '잠시 후 다시 시도해주세요.',
          isLoading: false,
          actionLabel: '다시 시도',
          onAction: () {
            ref.read(todayPlanControllerProvider.notifier).load(forceRefresh: true);
          },
        ),
      );
    }

    return AppScaffold(
      title: '오늘 플랜',
      body: ListView(
        children: [
          Text(plan.planDate, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ProgressSummaryCard(
            completedCount: progress.completedCount,
            totalCount: progress.totalCount,
            sproutCount: progress.sproutCount,
            sproutPerPlanItem: progress.sproutPerPlanItem,
          ),
          const SizedBox(height: 16),
          for (final item in plan.items) ...[
            PlanItemTile(
              subjectName: item.subjectName,
              primaryText: item.examRange,
              secondaryText:
                  '${item.studyMethod} · ${item.estimatedMinutes}분',
              statusLabel: item.priority,
              isCompleted: item.completed,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
