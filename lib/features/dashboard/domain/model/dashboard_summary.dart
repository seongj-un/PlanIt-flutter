class DashboardSummary {
  const DashboardSummary({
    required this.userName,
    required this.nextExam,
    required this.todayPlanPreview,
    required this.rewards,
    required this.attendance,
  });

  final String userName;
  final DashboardExamSummary nextExam;
  final DashboardTodayPlanPreview todayPlanPreview;
  final DashboardRewards rewards;
  final DashboardAttendance attendance;
}

class DashboardExamSummary {
  const DashboardExamSummary({
    required this.label,
    required this.date,
    required this.dDay,
  });

  final String label;
  final String date;
  final int dDay;
}

class DashboardTodayPlanPreview {
  const DashboardTodayPlanPreview({
    required this.planDate,
    required this.completedCount,
    required this.totalCount,
    required this.progressPercent,
    required this.items,
  });

  final String planDate;
  final int completedCount;
  final int totalCount;
  final int progressPercent;
  final List<DashboardTodayPlanPreviewItem> items;
}

class DashboardTodayPlanPreviewItem {
  const DashboardTodayPlanPreviewItem({
    required this.planItemId,
    required this.subjectName,
    required this.scopeSummary,
    required this.completed,
  });

  final int planItemId;
  final String subjectName;
  final String scopeSummary;
  final bool completed;
}

class DashboardRewards {
  const DashboardRewards({required this.sproutCount, required this.earnedToday});

  final int sproutCount;
  final int earnedToday;
}

class DashboardAttendance {
  const DashboardAttendance({
    required this.streakDays,
    required this.calendar,
  });

  final int streakDays;
  final List<DashboardAttendanceDay> calendar;
}

class DashboardAttendanceDay {
  const DashboardAttendanceDay({required this.date, required this.completed});

  final String date;
  final bool completed;
}
