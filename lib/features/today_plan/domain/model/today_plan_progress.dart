class TodayPlanProgress {
  const TodayPlanProgress({
    required this.completedCount,
    required this.totalCount,
    required this.completedItems,
    required this.remainingItems,
    required this.sproutCount,
    required this.sproutPerPlanItem,
  });

  final int completedCount;
  final int totalCount;
  final List<TodayPlanProgressItem> completedItems;
  final List<TodayPlanProgressItem> remainingItems;
  final int sproutCount;
  final int sproutPerPlanItem;
}

class TodayPlanProgressItem {
  const TodayPlanProgressItem({
    required this.planItemId,
    required this.subjectName,
    required this.label,
  });

  final int planItemId;
  final String subjectName;
  final String label;
}
