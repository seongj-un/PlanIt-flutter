import '../../../../core/error/app_exception.dart';
import '../../domain/model/today_plan_progress.dart';

class TodayPlanProgressDto {
  const TodayPlanProgressDto({
    required this.completedCount,
    required this.totalCount,
    required this.completedItems,
    required this.remainingItems,
    required this.sproutCount,
    required this.sproutPerPlanItem,
  });

  factory TodayPlanProgressDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Today plan progress payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    final rawCompletedItems = map['completedItems'];
    final rawRemainingItems = map['remainingItems'];
    if (rawCompletedItems is! List || rawRemainingItems is! List) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Today plan progress lists must be arrays.',
      );
    }

    return TodayPlanProgressDto(
      completedCount: _requireInt(map, 'completedCount'),
      totalCount: _requireInt(map, 'totalCount'),
      completedItems: rawCompletedItems
          .map((item) => TodayPlanProgressItemDto.fromJson(item))
          .toList(growable: false),
      remainingItems: rawRemainingItems
          .map((item) => TodayPlanProgressItemDto.fromJson(item))
          .toList(growable: false),
      sproutCount: _requireInt(map, 'sproutCount'),
      sproutPerPlanItem: _requireInt(map, 'sproutPerPlanItem'),
    );
  }

  final int completedCount;
  final int totalCount;
  final List<TodayPlanProgressItemDto> completedItems;
  final List<TodayPlanProgressItemDto> remainingItems;
  final int sproutCount;
  final int sproutPerPlanItem;

  TodayPlanProgress toDomain() {
    return TodayPlanProgress(
      completedCount: completedCount,
      totalCount: totalCount,
      completedItems: completedItems
          .map((item) => item.toDomain())
          .toList(growable: false),
      remainingItems: remainingItems
          .map((item) => item.toDomain())
          .toList(growable: false),
      sproutCount: sproutCount,
      sproutPerPlanItem: sproutPerPlanItem,
    );
  }
}

class TodayPlanProgressItemDto {
  const TodayPlanProgressItemDto({
    required this.planItemId,
    required this.subjectName,
    required this.label,
  });

  factory TodayPlanProgressItemDto.fromJson(Object? json) {
    final map = _asMap(json);
    return TodayPlanProgressItemDto(
      planItemId: _requireInt(map, 'planItemId'),
      subjectName: _requireString(map, 'subjectName'),
      label: _requireString(map, 'label'),
    );
  }

  final int planItemId;
  final String subjectName;
  final String label;

  TodayPlanProgressItem toDomain() {
    return TodayPlanProgressItem(
      planItemId: planItemId,
      subjectName: subjectName,
      label: label,
    );
  }
}

Map<String, Object?> _asMap(Object? json) {
  if (json is! Map) {
    throw const AppException(
      code: 'INVALID_API_RESPONSE',
      message: 'Nested today plan progress payload must be a JSON object.',
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
    message: 'Today plan progress field $key has an unexpected type.',
  );
}

String _requireString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }

  throw AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'Today plan progress field $key has an unexpected type.',
  );
}
