import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/history_day_detail.dart';
import '../../domain/model/history_month.dart';
import '../../domain/repository/history_repository.dart';
import '../datasource/history_remote_data_source.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(
    remoteDataSource: ref.watch(historyRemoteDataSourceProvider),
  );
});

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl({
    required HistoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final HistoryRemoteDataSource _remoteDataSource;

  @override
  Future<HistoryDayDetail> getDayDetail(String date) async {
    final response = await _remoteDataSource.getDayDetail(date);
    return response.toDomain();
  }

  @override
  Future<HistoryMonth> getMonth(String month) async {
    final response = await _remoteDataSource.getMonth(month);
    return response.toDomain();
  }
}
