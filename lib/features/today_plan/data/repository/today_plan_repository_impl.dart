import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/today_plan.dart';
import '../../domain/model/today_plan_progress.dart';
import '../../domain/repository/today_plan_repository.dart';
import '../datasource/today_plan_remote_data_source.dart';

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
}
