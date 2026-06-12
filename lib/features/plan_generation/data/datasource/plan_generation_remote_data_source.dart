import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_providers.dart';
import '../dto/plan_generation_request_dto.dart';
import '../dto/plan_generation_status_dto.dart';

final planGenerationRemoteDataSourceProvider =
    Provider<PlanGenerationRemoteDataSource>((ref) {
      return PlanGenerationRemoteDataSource(
        apiClient: ref.watch(apiClientProvider),
      );
    });

class PlanGenerationRemoteDataSource {
  const PlanGenerationRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PlanGenerationStatusDto> createJob(PlanGenerationRequestDto request) {
    return _apiClient.post<PlanGenerationStatusDto>(
      '/plan-generation-jobs',
      data: request.toJson(),
      parser: PlanGenerationStatusDto.fromJson,
    );
  }

  Future<PlanGenerationStatusDto> fetchStatus(String jobId) {
    return _apiClient.get<PlanGenerationStatusDto>(
      '/plan-generation-jobs/$jobId',
      parser: PlanGenerationStatusDto.fromJson,
    );
  }
}
