import '../../../../core/error/app_exception.dart';
import '../../domain/model/dashboard_summary.dart';

class DashboardDto {
  const DashboardDto._({
    required this.userName,
    required _DashboardExamDto nextExam,
    required _DashboardTodayPlanDto todayPlan,
    required _DashboardRewardsDto rewards,
    required _DashboardAttendanceDto attendance,
  }) : _nextExam = nextExam,
       _todayPlan = todayPlan,
       _rewards = rewards,
       _attendance = attendance;

  factory DashboardDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Dashboard payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    final userName = map['userName'];
    if (userName is! String || userName.isEmpty) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Dashboard payload is missing userName.',
      );
    }

    return DashboardDto._(
      userName: userName,
      nextExam: _DashboardExamDto.fromJson(map['nextExam']),
      todayPlan: _DashboardTodayPlanDto.fromJson(map['todayPlan']),
      rewards: _DashboardRewardsDto.fromJson(map['rewards']),
      attendance: _DashboardAttendanceDto.fromJson(map['attendance']),
    );
  }

  final String userName;
  final _DashboardExamDto _nextExam;
  final _DashboardTodayPlanDto _todayPlan;
  final _DashboardRewardsDto _rewards;
  final _DashboardAttendanceDto _attendance;

  DashboardSummary toDomain() {
    return DashboardSummary(
      userName: userName,
      nextExam: _nextExam.toDomain(),
      todayPlanPreview: _todayPlan.toDomain(),
      rewards: _rewards.toDomain(),
      attendance: _attendance.toDomain(),
    );
  }
}

class _DashboardExamDto {
  const _DashboardExamDto({
    required this.label,
    required this.date,
    required this.dDay,
  });

  factory _DashboardExamDto.fromJson(Object? json) {
    final map = _asMap(json);
    return _DashboardExamDto(
      label: _requireString(map, 'label'),
      date: _requireString(map, 'date'),
      dDay: _requireInt(map, 'dDay'),
    );
  }

  final String label;
  final String date;
  final int dDay;

  DashboardExamSummary toDomain() {
    return DashboardExamSummary(label: label, date: date, dDay: dDay);
  }
}

class _DashboardTodayPlanDto {
  const _DashboardTodayPlanDto({
    required this.planDate,
    required this.completedCount,
    required this.totalCount,
    required this.progressPercent,
    required this.items,
  });

  factory _DashboardTodayPlanDto.fromJson(Object? json) {
    final map = _asMap(json);
    final rawItems = map['items'];
    if (rawItems is! List) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Dashboard todayPlan items must be a list.',
      );
    }

    return _DashboardTodayPlanDto(
      planDate: _requireString(map, 'planDate'),
      completedCount: _requireInt(map, 'completedCount'),
      totalCount: _requireInt(map, 'totalCount'),
      progressPercent: _requireInt(map, 'progressPercent'),
      items: rawItems
          .map((item) => _DashboardTodayPlanItemDto.fromJson(item))
          .toList(growable: false),
    );
  }

  final String planDate;
  final int completedCount;
  final int totalCount;
  final int progressPercent;
  final List<_DashboardTodayPlanItemDto> items;

  DashboardTodayPlanPreview toDomain() {
    return DashboardTodayPlanPreview(
      planDate: planDate,
      completedCount: completedCount,
      totalCount: totalCount,
      progressPercent: progressPercent,
      items: items.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}

class _DashboardTodayPlanItemDto {
  const _DashboardTodayPlanItemDto({
    required this.planItemId,
    required this.subjectName,
    required this.scopeSummary,
    required this.completed,
  });

  factory _DashboardTodayPlanItemDto.fromJson(Object? json) {
    final map = _asMap(json);
    final completed = map['completed'];
    if (completed is! bool) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Dashboard todayPlan item completed must be a boolean.',
      );
    }

    return _DashboardTodayPlanItemDto(
      planItemId: _requireInt(map, 'planItemId'),
      subjectName: _requireString(map, 'subjectName'),
      scopeSummary: _requireString(map, 'scopeSummary'),
      completed: completed,
    );
  }

  final int planItemId;
  final String subjectName;
  final String scopeSummary;
  final bool completed;

  DashboardTodayPlanPreviewItem toDomain() {
    return DashboardTodayPlanPreviewItem(
      planItemId: planItemId,
      subjectName: subjectName,
      scopeSummary: scopeSummary,
      completed: completed,
    );
  }
}

class _DashboardRewardsDto {
  const _DashboardRewardsDto({
    required this.sproutCount,
    required this.earnedToday,
  });

  factory _DashboardRewardsDto.fromJson(Object? json) {
    final map = _asMap(json);
    return _DashboardRewardsDto(
      sproutCount: _requireInt(map, 'sproutCount'),
      earnedToday: _requireInt(map, 'earnedToday'),
    );
  }

  final int sproutCount;
  final int earnedToday;

  DashboardRewards toDomain() {
    return DashboardRewards(
      sproutCount: sproutCount,
      earnedToday: earnedToday,
    );
  }
}

class _DashboardAttendanceDto {
  const _DashboardAttendanceDto({
    required this.streakDays,
    required this.calendar,
  });

  factory _DashboardAttendanceDto.fromJson(Object? json) {
    final map = _asMap(json);
    final rawCalendar = map['calendar'];
    if (rawCalendar is! List) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Dashboard attendance calendar must be a list.',
      );
    }

    return _DashboardAttendanceDto(
      streakDays: _requireInt(map, 'streakDays'),
      calendar: rawCalendar
          .map((item) => _DashboardAttendanceDayDto.fromJson(item))
          .toList(growable: false),
    );
  }

  final int streakDays;
  final List<_DashboardAttendanceDayDto> calendar;

  DashboardAttendance toDomain() {
    return DashboardAttendance(
      streakDays: streakDays,
      calendar: calendar.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}

class _DashboardAttendanceDayDto {
  const _DashboardAttendanceDayDto({
    required this.date,
    required this.completed,
  });

  factory _DashboardAttendanceDayDto.fromJson(Object? json) {
    final map = _asMap(json);
    final completed = map['completed'];
    if (completed is! bool) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Dashboard attendance day completed must be a boolean.',
      );
    }

    return _DashboardAttendanceDayDto(
      date: _requireString(map, 'date'),
      completed: completed,
    );
  }

  final String date;
  final bool completed;

  DashboardAttendanceDay toDomain() {
    return DashboardAttendanceDay(date: date, completed: completed);
  }
}

Map<String, Object?> _asMap(Object? json) {
  if (json is! Map) {
    throw const AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Nested dashboard payload must be a JSON object.',
    );
  }

  return Map<String, Object?>.from(json);
}

int _requireInt(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is num) {
    return value.toInt();
  }

  throw AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'Dashboard field $key has an unexpected type.',
  );
}

String _requireString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }

  throw AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'Dashboard field $key has an unexpected type.',
  );
}
