import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/today_plan.dart';
import '../../domain/model/today_plan_progress.dart';
import '../../domain/repository/today_plan_repository.dart';
import '../datasource/today_plan_remote_data_source.dart';
import '../dto/toggle_plan_item_request_dto.dart';
import '../dto/update_today_plan_request_dto.dart';

final todayPlanRepositoryProvider = Provider<TodayPlanRepository>((ref) {
  return TodayPlanRepositoryImpl(
    remoteDataSource: ref.watch(todayPlanRemoteDataSourceProvider),
  );
});

class TodayPlanRepositoryImpl implements TodayPlanRepository {
  const TodayPlanRepositoryImpl({
    required TodayPlanRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final TodayPlanRemoteDataSource _remoteDataSource;

  @override
  Future<TodayPlan> getTodayPlan() async {
    final response = await _remoteDataSource.getTodayPlan();
    return response.toDomain();
  }

  @override
  Future<TodayPlanProgress> getTodayProgress() async {
    final response = await _remoteDataSource.getTodayProgress();
    return response.toDomain();
  }

  @override
  Future<TodayPlanUpdateResult> updateTodayPlan({
    required List<TodayPlanEditableItem> items,
    required List<int> deletedPlanItemIds,
  }) {
    return _remoteDataSource.updateTodayPlan(
      UpdateTodayPlanRequestDto.fromDomain(
        items: items,
        deletedPlanItemIds: deletedPlanItemIds,
      ),
    );
  }

  @override
  Future<TodayPlanToggleResult> togglePlanItem({
    required int planItemId,
    required bool completed,
  }) {
    return _remoteDataSource.togglePlanItem(
      planItemId,
      TogglePlanItemRequestDto(completed: completed),
    );
  }

  @override
  Future<TodayPlanCompletionResult> completeTodayPlan() {
    return _remoteDataSource.completeTodayPlan();
  }
}
