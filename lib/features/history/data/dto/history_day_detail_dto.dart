import '../../../../core/error/app_exception.dart';
import '../../domain/model/history_day_detail.dart';

class HistoryDayDetailDto {
  const HistoryDayDetailDto({
    required this.date,
    required this.completedCount,
    required this.totalCount,
    required this.items,
  });

  factory HistoryDayDetailDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'History detail payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    final rawItems = map['items'];
    if (rawItems is! List) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'History detail items must be a list.',
      );
    }

    return HistoryDayDetailDto(
      date: _requireString(map, 'date'),
      completedCount: _requireInt(map, 'completedCount'),
      totalCount: _requireInt(map, 'totalCount'),
      items: rawItems.map(HistoryDayDetailItemDto.fromJson).toList(growable: false),
    );
  }

  final String date;
  final int completedCount;
  final int totalCount;
  final List<HistoryDayDetailItemDto> items;

  HistoryDayDetail toDomain() {
    return HistoryDayDetail(
      date: date,
      completedCount: completedCount,
      totalCount: totalCount,
      items: items.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}

class HistoryDayDetailItemDto {
  const HistoryDayDetailItemDto({
    required this.subjectName,
    required this.examRange,
    required this.studyMethod,
    required this.completed,
  });

  factory HistoryDayDetailItemDto.fromJson(Object? json) {
    final map = _asMap(json);
    final completed = map['completed'];
    if (completed is! bool) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'History detail item completed must be a boolean.',
      );
    }

    return HistoryDayDetailItemDto(
      subjectName: _requireString(map, 'subjectName'),
      examRange: _requireString(map, 'examRange'),
      studyMethod: _requireString(map, 'studyMethod'),
      completed: completed,
    );
  }

  final String subjectName;
  final String examRange;
  final String studyMethod;
  final bool completed;

  HistoryDayDetailItem toDomain() {
    return HistoryDayDetailItem(
      subjectName: subjectName,
      examRange: examRange,
      studyMethod: studyMethod,
      completed: completed,
    );
  }
}

Map<String, Object?> _asMap(Object? json) {
  if (json is! Map) {
    throw const AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Nested history detail payload must be a JSON object.',
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
    message: 'History detail field $key has an unexpected type.',
  );
}

String _requireString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }

  throw AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'History detail field $key has an unexpected type.',
  );
}
