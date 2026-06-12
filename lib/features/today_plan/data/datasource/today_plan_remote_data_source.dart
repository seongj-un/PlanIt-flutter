import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_providers.dart';
import '../dto/today_plan_dto.dart';
import '../dto/today_plan_progress_dto.dart';

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
}
