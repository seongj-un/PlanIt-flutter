class TodayPlan {
  const TodayPlan({
    required this.planId,
    required this.planDate,
    required this.status,
    required this.items,
  });

  final int planId;
  final String planDate;
  final String status;
  final List<TodayPlanItem> items;
}

class TodayPlanItem {
  const TodayPlanItem({
    required this.planItemId,
    required this.subjectName,
    required this.examRange,
    required this.studyMethod,
    required this.priority,
    required this.status,
    required this.estimatedMinutes,
  });

  final int planItemId;
  final String subjectName;
  final String examRange;
  final String studyMethod;
  final String priority;
  final String status;
  final int estimatedMinutes;

  bool get completed => status == 'COMPLETED';
}
