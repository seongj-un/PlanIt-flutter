import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/section_card.dart';
import '../controllers/history_controller.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(historyControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyControllerProvider);
    final month = state.month;

    if (state.isLoading && month == null) {
      return const AppScaffold(
        body: AppLoadingView(
          title: '기록 불러오는 중',
          message: '월별 학습 기록을 준비하고 있어요.',
        ),
      );
    }

    if (month == null) {
      return AppScaffold(
        body: AppLoadingView(
          title: '기록을 불러올 수 없어요',
          message: state.errorMessage ?? '잠시 후 다시 시도해주세요.',
          isLoading: false,
          actionLabel: '다시 시도',
          onAction: () {
            ref.read(historyControllerProvider.notifier).load(forceRefresh: true);
          },
        ),
      );
    }

    return AppScaffold(
      body: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${month.month} 학습 기록',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                onPressed: () {
                  ref
                      .read(historyControllerProvider.notifier)
                      .changeMonth(formatPreviousMonth(state.currentMonth));
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                onPressed: () {
                  ref
                      .read(historyControllerProvider.notifier)
                      .changeMonth(formatNextMonth(state.currentMonth));
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: '월간 요약',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '완료 ${month.stats.completedPlans}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    '미완료 ${month.stats.incompletePlans}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final day in month.days) ...[
            Card(
              child: ListTile(
                onTap: () {
                  context.go('/history/${day.date}');
                },
                title: Text(day.date),
                subtitle: Text(day.subjects.join(', ')),
                trailing: Text('${day.completedCount}/${day.totalCount}'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
