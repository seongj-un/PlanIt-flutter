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

  TodayPlanProgress copyWith({
    int? completedCount,
    int? totalCount,
    List<TodayPlanProgressItem>? completedItems,
    List<TodayPlanProgressItem>? remainingItems,
    int? sproutCount,
    int? sproutPerPlanItem,
  }) {
    return TodayPlanProgress(
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      completedItems: completedItems ?? this.completedItems,
      remainingItems: remainingItems ?? this.remainingItems,
      sproutCount: sproutCount ?? this.sproutCount,
      sproutPerPlanItem: sproutPerPlanItem ?? this.sproutPerPlanItem,
    );
  }
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
