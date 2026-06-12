class HistoryMonth {
  const HistoryMonth({
    required this.month,
    required this.stats,
    required this.days,
  });

  final String month;
  final HistoryMonthStats stats;
  final List<HistoryDaySummary> days;
}

class HistoryMonthStats {
  const HistoryMonthStats({
    required this.completedPlans,
    required this.incompletePlans,
  });

  final int completedPlans;
  final int incompletePlans;
}

class HistoryDaySummary {
  const HistoryDaySummary({
    required this.date,
    required this.completedCount,
    required this.totalCount,
    required this.completed,
    required this.subjects,
  });

  final String date;
  final int completedCount;
  final int totalCount;
  final bool completed;
  final List<String> subjects;
}
