import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/dashboard_summary.dart';
import '../../domain/repository/dashboard_repository.dart';
import '../datasource/dashboard_remote_data_source.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
  );
});

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({
    required DashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    final response = await _remoteDataSource.getDashboardSummary();
    return response.toDomain();
  }
}
