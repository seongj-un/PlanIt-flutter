import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/plan_generation_input.dart';
import '../../domain/model/plan_generation_status.dart';
import '../../domain/repository/plan_generation_repository.dart';
import '../datasource/plan_generation_remote_data_source.dart';
import '../dto/plan_generation_request_dto.dart';

final planGenerationRepositoryProvider =
    Provider<PlanGenerationRepository>((ref) {
      return PlanGenerationRepositoryImpl(
        remoteDataSource: ref.watch(planGenerationRemoteDataSourceProvider),
      );
    });

class PlanGenerationRepositoryImpl implements PlanGenerationRepository {
  const PlanGenerationRepositoryImpl({
    required PlanGenerationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PlanGenerationRemoteDataSource _remoteDataSource;

  @override
  Future<PlanGenerationStatus> createJob(PlanGenerationInput input) async {
    final response = await _remoteDataSource.createJob(
      PlanGenerationRequestDto.fromDomain(input),
    );
    return response.toDomain();
  }

  @override
  Future<PlanGenerationStatus> fetchStatus(String jobId) async {
    final response = await _remoteDataSource.fetchStatus(jobId);
    return response.toDomain();
  }
}
