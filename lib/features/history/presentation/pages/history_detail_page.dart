import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_loading_view.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/plan_item_tile.dart';
import '../controllers/history_controller.dart';

class HistoryDetailPage extends ConsumerStatefulWidget {
  const HistoryDetailPage({required this.date, super.key});

  final String date;

  @override
  ConsumerState<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends ConsumerState<HistoryDetailPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(historyControllerProvider.notifier).selectDate(widget.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyControllerProvider);
    final detail = state.detail;

    if (state.isDetailLoading && detail == null) {
      return const AppScaffold(
        title: '기록 상세',
        body: AppLoadingView(
          title: '상세 기록 불러오는 중',
          message: '선택한 날짜의 학습 내역을 가져오고 있어요.',
        ),
      );
    }

    if (detail == null || detail.date != widget.date) {
      return AppScaffold(
        title: '기록 상세',
        body: AppLoadingView(
          title: '상세 기록을 불러올 수 없어요',
          message: state.errorMessage ?? '잠시 후 다시 시도해주세요.',
          isLoading: false,
          actionLabel: '다시 시도',
          onAction: () {
            ref.read(historyControllerProvider.notifier).selectDate(widget.date);
          },
        ),
      );
    }

    return AppScaffold(
      title: widget.date,
      body: ListView(
        children: [
          Text(
            '${detail.completedCount} / ${detail.totalCount} 완료',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          for (final item in detail.items) ...[
            PlanItemTile(
              subjectName: item.subjectName,
              primaryText: item.examRange,
              secondaryText: item.studyMethod,
              isCompleted: item.completed,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
