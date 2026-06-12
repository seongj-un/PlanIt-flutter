import '../../../../core/error/app_exception.dart';
import '../../domain/model/history_month.dart';

class HistoryMonthDto {
  const HistoryMonthDto({
    required this.month,
    required this.stats,
    required this.days,
  });

  factory HistoryMonthDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'History month payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    final rawDays = map['days'];
    if (rawDays is! List) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'History month days must be a list.',
      );
    }

    return HistoryMonthDto(
      month: _requireString(map, 'month'),
      stats: HistoryMonthStatsDto.fromJson(map['stats']),
      days: rawDays.map(HistoryDaySummaryDto.fromJson).toList(growable: false),
    );
  }

  final String month;
  final HistoryMonthStatsDto stats;
  final List<HistoryDaySummaryDto> days;

  HistoryMonth toDomain() {
    return HistoryMonth(
      month: month,
      stats: stats.toDomain(),
      days: days.map((day) => day.toDomain()).toList(growable: false),
    );
  }
}

class HistoryMonthStatsDto {
  const HistoryMonthStatsDto({
    required this.completedPlans,
    required this.incompletePlans,
  });

  factory HistoryMonthStatsDto.fromJson(Object? json) {
    final map = _asMap(json);
    return HistoryMonthStatsDto(
      completedPlans: _requireInt(map, 'completedPlans'),
      incompletePlans: _requireInt(map, 'incompletePlans'),
    );
  }

  final int completedPlans;
  final int incompletePlans;

  HistoryMonthStats toDomain() {
    return HistoryMonthStats(
      completedPlans: completedPlans,
      incompletePlans: incompletePlans,
    );
  }
}

class HistoryDaySummaryDto {
  const HistoryDaySummaryDto({
    required this.date,
    required this.completedCount,
    required this.totalCount,
    required this.completed,
    required this.subjects,
  });

  factory HistoryDaySummaryDto.fromJson(Object? json) {
    final map = _asMap(json);
    final completed = map['completed'];
    final rawSubjects = map['subjects'];
    if (completed is! bool || rawSubjects is! List) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'History day summary payload has invalid fields.',
      );
    }

    return HistoryDaySummaryDto(
      date: _requireString(map, 'date'),
      completedCount: _requireInt(map, 'completedCount'),
      totalCount: _requireInt(map, 'totalCount'),
      completed: completed,
      subjects: rawSubjects.map((item) => item.toString()).toList(growable: false),
    );
  }

  final String date;
  final int completedCount;
  final int totalCount;
  final bool completed;
  final List<String> subjects;

  HistoryDaySummary toDomain() {
    return HistoryDaySummary(
      date: date,
      completedCount: completedCount,
      totalCount: totalCount,
      completed: completed,
      subjects: subjects,
    );
  }
}

Map<String, Object?> _asMap(Object? json) {
  if (json is! Map) {
    throw const AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Nested history payload must be a JSON object.',
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
    message: 'History field $key has an unexpected type.',
  );
}

String _requireString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }

  throw AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'History field $key has an unexpected type.',
  );
}
