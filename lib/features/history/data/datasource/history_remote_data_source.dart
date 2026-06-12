import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_providers.dart';
import '../dto/history_day_detail_dto.dart';
import '../dto/history_month_dto.dart';

final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) {
  return HistoryRemoteDataSource(apiClient: ref.watch(apiClientProvider));
});

class HistoryRemoteDataSource {
  const HistoryRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<HistoryMonthDto> getMonth(String month) {
    return _apiClient.get<HistoryMonthDto>(
      '/plans/history',
      queryParameters: {'month': month},
      parser: HistoryMonthDto.fromJson,
    );
  }

  Future<HistoryDayDetailDto> getDayDetail(String date) {
    return _apiClient.get<HistoryDayDetailDto>(
      '/plans/history/$date',
      parser: HistoryDayDetailDto.fromJson,
    );
  }
}
