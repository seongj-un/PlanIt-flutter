import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_providers.dart';
import '../dto/dashboard_dto.dart';

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
      return DashboardRemoteDataSource(apiClient: ref.watch(apiClientProvider));
    });

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<DashboardDto> getDashboardSummary() {
    return _apiClient.get<DashboardDto>(
      '/dashboard',
      parser: DashboardDto.fromJson,
    );
  }
}
