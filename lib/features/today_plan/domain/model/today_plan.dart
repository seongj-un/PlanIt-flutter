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

  TodayPlan copyWith({
    int? planId,
    String? planDate,
    String? status,
    List<TodayPlanItem>? items,
  }) {
    return TodayPlan(
      planId: planId ?? this.planId,
      planDate: planDate ?? this.planDate,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
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

  TodayPlanItem copyWith({
    int? planItemId,
    String? subjectName,
    String? examRange,
    String? studyMethod,
    String? priority,
    String? status,
    int? estimatedMinutes,
  }) {
    return TodayPlanItem(
      planItemId: planItemId ?? this.planItemId,
      subjectName: subjectName ?? this.subjectName,
      examRange: examRange ?? this.examRange,
      studyMethod: studyMethod ?? this.studyMethod,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}

class TodayPlanEditableItem {
  const TodayPlanEditableItem({
    this.planItemId,
    required this.subjectName,
    required this.examRange,
    required this.studyMethod,
    required this.priority,
  });

  factory TodayPlanEditableItem.fromPlanItem(TodayPlanItem item) {
    return TodayPlanEditableItem(
      planItemId: item.planItemId,
      subjectName: item.subjectName,
      examRange: item.examRange,
      studyMethod: item.studyMethod,
      priority: item.priority,
    );
  }

  final int? planItemId;
  final String subjectName;
  final String examRange;
  final String studyMethod;
  final String priority;
}

class TodayPlanUpdateResult {
  const TodayPlanUpdateResult({
    required this.planId,
    required this.updated,
    required this.itemCount,
  });

  final int planId;
  final bool updated;
  final int itemCount;
}

class TodayPlanToggleResult {
  const TodayPlanToggleResult({
    required this.planItemId,
    required this.completed,
    required this.completedCount,
    required this.totalCount,
    required this.sproutAwarded,
  });

  final int planItemId;
  final bool completed;
  final int completedCount;
  final int totalCount;
  final int sproutAwarded;
}

class TodayPlanCompletionResult {
  const TodayPlanCompletionResult({
    required this.planId,
    required this.completed,
    required this.attendanceRecorded,
    required this.streakDays,
  });

  final int planId;
  final bool completed;
  final bool attendanceRecorded;
  final int streakDays;
}
