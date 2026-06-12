import '../../domain/model/today_plan.dart';

class UpdateTodayPlanRequestDto {
  const UpdateTodayPlanRequestDto({
    required this.items,
    required this.deletedPlanItemIds,
  });

  factory UpdateTodayPlanRequestDto.fromDomain({
    required List<TodayPlanEditableItem> items,
    required List<int> deletedPlanItemIds,
  }) {
    return UpdateTodayPlanRequestDto(
      items: items.map(_TodayPlanEditableItemDto.fromDomain).toList(growable: false),
      deletedPlanItemIds: deletedPlanItemIds,
    );
  }

  final List<_TodayPlanEditableItemDto> items;
  final List<int> deletedPlanItemIds;

  Map<String, Object?> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'deletedPlanItemIds': deletedPlanItemIds,
    };
  }
}

class _TodayPlanEditableItemDto {
  const _TodayPlanEditableItemDto({
    this.planItemId,
    required this.subjectName,
    required this.examRange,
    required this.studyMethod,
    required this.priority,
  });

  factory _TodayPlanEditableItemDto.fromDomain(TodayPlanEditableItem item) {
    return _TodayPlanEditableItemDto(
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

  Map<String, Object?> toJson() {
    return {
      if (planItemId != null) 'planItemId': planItemId,
      'subjectName': subjectName,
      'examRange': examRange,
      'studyMethod': studyMethod,
      'priority': priority,
    };
  }
}
