import 'package:flutter/material.dart';

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    required this.completedCount,
    required this.totalCount,
    required this.sproutCount,
    required this.sproutPerPlanItem,
    super.key,
  });

  final int completedCount;
  final int totalCount;
  final int sproutCount;
  final int sproutPerPlanItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$completedCount / $totalCount 완료',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '새싹 $sproutCount개 · 항목당 $sproutPerPlanItem개',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
