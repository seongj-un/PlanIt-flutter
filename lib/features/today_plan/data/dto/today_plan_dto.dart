import '../../../../core/error/app_exception.dart';
import '../../domain/model/today_plan.dart';

class TodayPlanDto {
  const TodayPlanDto({
    required this.planId,
    required this.planDate,
    required this.status,
    required this.items,
  });

  factory TodayPlanDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Today plan payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    final rawItems = map['items'];
    if (rawItems is! List) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Today plan items must be a list.',
      );
    }

    return TodayPlanDto(
      planId: _requireInt(map, 'planId'),
      planDate: _requireString(map, 'planDate'),
      status: _requireString(map, 'status'),
      items: rawItems
          .map((item) => TodayPlanItemDto.fromJson(item))
          .toList(growable: false),
    );
  }

  final int planId;
  final String planDate;
  final String status;
  final List<TodayPlanItemDto> items;

  TodayPlan toDomain() {
    return TodayPlan(
      planId: planId,
      planDate: planDate,
      status: status,
      items: items.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}

class TodayPlanItemDto {
  const TodayPlanItemDto({
    required this.planItemId,
    required this.subjectName,
    required this.examRange,
    required this.studyMethod,
    required this.priority,
    required this.status,
    required this.estimatedMinutes,
  });

  factory TodayPlanItemDto.fromJson(Object? json) {
    final map = _asMap(json);
    return TodayPlanItemDto(
      planItemId: _requireInt(map, 'planItemId'),
      subjectName: _requireString(map, 'subjectName'),
      examRange: _requireString(map, 'examRange'),
      studyMethod: _requireString(map, 'studyMethod'),
      priority: _requireString(map, 'priority'),
      status: _requireString(map, 'status'),
      estimatedMinutes: _requireInt(map, 'estimatedMinutes'),
    );
  }

  final int planItemId;
  final String subjectName;
  final String examRange;
  final String studyMethod;
  final String priority;
  final String status;
  final int estimatedMinutes;

  TodayPlanItem toDomain() {
    return TodayPlanItem(
      planItemId: planItemId,
      subjectName: subjectName,
      examRange: examRange,
      studyMethod: studyMethod,
      priority: priority,
      status: status,
      estimatedMinutes: estimatedMinutes,
    );
  }
}

Map<String, Object?> _asMap(Object? json) {
  if (json is! Map) {
    throw const AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Nested today plan payload must be a JSON object.',
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
    message: 'Today plan field $key has an unexpected type.',
  );
}

String _requireString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }

  throw AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'Today plan field $key has an unexpected type.',
  );
}
