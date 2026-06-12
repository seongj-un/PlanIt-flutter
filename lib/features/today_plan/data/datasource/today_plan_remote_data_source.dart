import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_providers.dart';
import '../dto/today_plan_dto.dart';
import '../dto/today_plan_progress_dto.dart';
import '../dto/toggle_plan_item_request_dto.dart';
import '../dto/update_today_plan_request_dto.dart';
import '../../domain/model/today_plan.dart';

final todayPlanRemoteDataSourceProvider =
    Provider<TodayPlanRemoteDataSource>((ref) {
      return TodayPlanRemoteDataSource(apiClient: ref.watch(apiClientProvider));
    });

class TodayPlanRemoteDataSource {
  const TodayPlanRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<TodayPlanDto> getTodayPlan() {
    return _apiClient.get<TodayPlanDto>(
      '/plans/today',
      parser: TodayPlanDto.fromJson,
    );
  }

  Future<TodayPlanProgressDto> getTodayProgress() {
    return _apiClient.get<TodayPlanProgressDto>(
      '/plans/today/progress',
      parser: TodayPlanProgressDto.fromJson,
    );
  }

  Future<TodayPlanUpdateResult> updateTodayPlan(UpdateTodayPlanRequestDto request) {
    return _apiClient.put<TodayPlanUpdateResult>(
      '/plans/today',
      data: request.toJson(),
      parser: _parseUpdateResult,
    );
  }

  Future<TodayPlanToggleResult> togglePlanItem(
    int planItemId,
    TogglePlanItemRequestDto request,
  ) {
    return _apiClient.patch<TodayPlanToggleResult>(
      '/plans/today/items/$planItemId',
      data: request.toJson(),
      parser: _parseToggleResult,
    );
  }

  Future<TodayPlanCompletionResult> completeTodayPlan() {
    return _apiClient.post<TodayPlanCompletionResult>(
      '/plans/today/complete',
      parser: _parseCompletionResult,
    );
  }
}

TodayPlanUpdateResult _parseUpdateResult(Object? json) {
  final map = _asMap(json);
  final updated = map['updated'];
  if (updated is! bool) {
    throw _invalidTodayPlanException('Today plan update result is missing updated.');
  }
  return TodayPlanUpdateResult(
    planId: _requireInt(map, 'planId'),
    updated: updated,
    itemCount: _requireInt(map, 'itemCount'),
  );
}

TodayPlanToggleResult _parseToggleResult(Object? json) {
  final map = _asMap(json);
  final completed = map['completed'];
  if (completed is! bool) {
    throw _invalidTodayPlanException('Today plan toggle result is missing completed.');
  }
  return TodayPlanToggleResult(
    planItemId: _requireInt(map, 'planItemId'),
    completed: completed,
    completedCount: _requireInt(map, 'completedCount'),
    totalCount: _requireInt(map, 'totalCount'),
    sproutAwarded: _requireInt(map, 'sproutAwarded'),
  );
}

TodayPlanCompletionResult _parseCompletionResult(Object? json) {
  final map = _asMap(json);
  final completed = map['completed'];
  final attendanceRecorded = map['attendanceRecorded'];
  if (completed is! bool || attendanceRecorded is! bool) {
    throw _invalidTodayPlanException(
      'Today plan completion result is missing completion flags.',
    );
  }
  return TodayPlanCompletionResult(
    planId: _requireInt(map, 'planId'),
    completed: completed,
    attendanceRecorded: attendanceRecorded,
    streakDays: _requireInt(map, 'streakDays'),
  );
}

Map<String, Object?> _asMap(Object? json) {
  if (json is! Map) {
    throw _invalidTodayPlanException(
      'Today plan mutation payload must be a JSON object.',
    );
  }

  return Map<String, Object?>.from(json);
}

int _requireInt(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is num) {
    return value.toInt();
  }

  throw _invalidTodayPlanException(
    'Today plan mutation field $key has an unexpected type.',
  );
}

AppException _invalidTodayPlanException(String message) {
  return AppException(code: 'INVALID_API_RESPONSE', message: message);
}
