import '../../../../core/error/app_exception.dart';
import '../../domain/model/plan_generation_status.dart';

class PlanGenerationStatusDto {
  const PlanGenerationStatusDto({
    required this.jobId,
    required this.status,
    this.estimatedSeconds,
    this.progressPercent,
    this.message,
    this.planDate,
    this.planId,
    this.dashboardAvailable,
  });

  factory PlanGenerationStatusDto.fromJson(Object? json) {
    if (json is! Map) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Plan generation status payload must be a JSON object.',
      );
    }

    final map = Map<String, Object?>.from(json);
    final jobId = map['jobId'];
    final status = map['status'];

    if (jobId is! String || jobId.isEmpty || status is! String || status.isEmpty) {
      throw const AppException(
        code: 'INVALID_API_RESPONSE',
        message: 'Plan generation status payload is missing required fields.',
      );
    }

    return PlanGenerationStatusDto(
      jobId: jobId,
      status: _parseStatus(status),
      estimatedSeconds: _readOptionalInt(map, 'estimatedSeconds'),
      progressPercent: _readOptionalInt(map, 'progressPercent'),
      message: _readOptionalString(map, 'message'),
      planDate: _readOptionalString(map, 'planDate'),
      planId: _readOptionalInt(map, 'planId'),
      dashboardAvailable: _readOptionalBool(map, 'dashboardAvailable'),
    );
  }

  final String jobId;
  final PlanGenerationJobStatus status;
  final int? estimatedSeconds;
  final int? progressPercent;
  final String? message;
  final String? planDate;
  final int? planId;
  final bool? dashboardAvailable;

  PlanGenerationStatus toDomain() {
    return PlanGenerationStatus(
      jobId: jobId,
      status: status,
      estimatedSeconds: estimatedSeconds,
      progressPercent: progressPercent,
      message: message,
      planDate: planDate,
      planId: planId,
      dashboardAvailable: dashboardAvailable,
    );
  }
}

PlanGenerationJobStatus _parseStatus(String value) {
  switch (value) {
    case 'PENDING':
      return PlanGenerationJobStatus.pending;
    case 'RUNNING':
      return PlanGenerationJobStatus.running;
    case 'COMPLETED':
      return PlanGenerationJobStatus.completed;
    case 'FAILED':
      return PlanGenerationJobStatus.failed;
  }

  throw const AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'Plan generation status has an unexpected value.',
  );
}

int? _readOptionalInt(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toInt();
  }

  throw AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'Plan generation field $key has an unexpected type.',
  );
}

String? _readOptionalString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value.isEmpty ? null : value;
  }

  throw AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'Plan generation field $key has an unexpected type.',
  );
}

bool? _readOptionalBool(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }

  throw AppException(
    code: 'INVALID_API_RESPONSE',
    message: 'Plan generation field $key has an unexpected type.',
  );
}
