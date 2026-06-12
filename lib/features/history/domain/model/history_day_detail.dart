class HistoryDayDetail {
  const HistoryDayDetail({
    required this.date,
    required this.completedCount,
    required this.totalCount,
    required this.items,
  });

  final String date;
  final int completedCount;
  final int totalCount;
  final List<HistoryDayDetailItem> items;
}

class HistoryDayDetailItem {
  const HistoryDayDetailItem({
    required this.subjectName,
    required this.examRange,
    required this.studyMethod,
    required this.completed,
  });

  final String subjectName;
  final String examRange;
  final String studyMethod;
  final bool completed;
}
